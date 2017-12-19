#include "Message.h"

module SenderC {
    uses { 
        interface Boot;
        interface Timer<TMilli> as TimerRead;
        interface Leds;
        interface Read<uint16_t> as ReadTemperature;
        interface Read<uint16_t> as ReadHumidity;
        interface Read<uint16_t> as ReadLightIntensity;
        interface Packet;
        interface PacketAcknowledgements;
        interface AMSend;
        interface Receive as ReceiveInterval;
        interface SplitControl as RadioControl;
        interface GlobalTime<TMilli>;
        interface StdControl;
    }
}

implementation {
    bool sendBusy;
    message_t sendBuf;
    uint8_t singleReadCounter;              // counter for three sensors reading
    uint8_t readCounter;                    // counter for 0~NREADINGS
    uint8_t seqCounter;                     // simply increase by 1 when sending a packet
    uint32_t globalTime;

    // current local state
    Sensor_Msg local;
    Sensor_Msg localQueue[QUEUE_LENGTH];
    uint8_t headPos;                        // queue head pointer
    uint8_t tailPos;                        // queue tail pointer + 1

    // GBN implement
    uint8_t cal_pos(uint8_t pos, uint8_t alias) {
        return (pos + alias) >= QUEUE_LENGTH ? pos + alias : pos + alias - QUEUE_LENGTH;
    }
    task void send() {
        if (!sendBusy && (headPos != tailPos)) {
            if(sizeof local <= call AMSend.maxPayloadLength()) {
                call PacketAcknowledgements.requestAck(&sendBuf);
                memcpy(call AMSend.getPayload(&sendBuf, sizeof(local)), localQueue + headPos, sizeof local);
                // TODO: Change addr
                if (call AMSend.send(AM_BROADCAST_ADDR, &sendBuf, sizeof local) == SUCCESS) {
                    sendBusy = TRUE;
                    report_sent();
                }
                else
                    post send();
            }
            else
                report_problem();
        }
    }

    // timer start
    void start_read_timer() {
        call TimerRead.startPeriodic(local.interval);
        singleReadCounter = 0;
        readCounter = 0;
    }

    // Use LEDs to report various status issues.
    void report_problem() { call Leds.led0Toggle(); }
    void report_sent() { call Leds.led1Toggle(); }
    void report_received() { call Leds.led2Toggle(); }

    event void Boot.booted() {
        // initialize status flags
        sendBusy = FALSE;
        seqCounter = 0;

        // initialize queue
        headPos = 0;
        tailPos = 0;

        // initialize local Sensor_Msg
        local.interval = DEFAULT_INTERVAL;
        local.nodeid = TOS_NODE_ID;
        local.seqNumber = seqCounter;
        
        // start time sync service
        call StdControl.start();

        // start radio service
        if (call RadioControl.start() != SUCCESS)
            report_problem();
    }

    event void RadioControl.startDone(error_t err) {
        if (err == SUCCESS) {
            start_read_timer();
        } else {
            call RadioControl.start();
        }
    }
    event void RadioControl.stopDone(error_t err) {}
    
    event void TimerRead.fired() {
        // read data and add it to queue
        if (readCounter == NREADINGS) {
            if(sizeof local <= call AMSend.maxPayloadLength()) {
                // add to queue
                localQueue[tailPos] = local;
                tailPos = cal_pos(tailPos, 1);
                post send();
                if (tailPos == headPos)
                    report_problem();
            }
            else
                report_problem();
            
            readCounter = 0;
        }
        else {
            // time sync
            if (call GlobalTime.getGlobalTime(&globalTime) == SUCCESS) {
                call Leds.led2Off();
                local.collectTime[readCounter] = globalTime;
            }
            else {
                call Leds.led2On();
                local.collectTime[readCounter] = call GlobalTime.getLocalTime();
            }
            
            // multi sensors read
            if (call ReadTemperature.read() != SUCCESS)
                report_problem();
            if (call ReadHumidity.read() != SUCCESS)
                report_problem();
            if (call ReadLightIntensity.read() != SUCCESS)
                report_problem();
        }
    }

    event void AMSend.sendDone(message_t* msg, error_t err) {
        if (err == SUCCESS) {
            report_sent();
            sendBusy = FALSE;
            if(call PacketAcknowledgements.wasAcked(msg))
                headPos = cal_pos(headPos, 1);
                post send();
            else
                post send();
        }
        else
            report_problem();
    }

    event void ReadTemperature.readDone(error_t err, uint16_t data) {
        if (err == SUCCESS) {
            if (readCounter < NREADINGS && singleReadCounter < SENSOR_TYPES) {
                local.temperature[readCounter] = data;
                singleReadCounter++;
            }
            if (singleReadCounter >= SENSOR_TYPES) {
                readCounter++;
                singleReadCounter = 0;
            }
        }
        else {
            data = 0xffff;
            report_problem();
        }
    }

    event void ReadHumidity.readDone(error_t err, uint16_t data) {
        if (err == SUCCESS) {
            if (readCounter < NREADINGS && singleReadCounter < SENSOR_TYPES) {
                local.humidity[readCounter] = data;
                singleReadCounter++;
            }
            if (singleReadCounter >= SENSOR_TYPES) {
                readCounter++;
                singleReadCounter = 0;
            }
        }
        else {
            data = 0xffff;
            report_problem();
        }
    }

    event void ReadLightIntensity.readDone(error_t err, uint16_t data) {
        if (err == SUCCESS) {
            if (readCounter < NREADINGS && singleReadCounter < SENSOR_TYPES) {
                local.lightIntensity[readCounter] = data;
                singleReadCounter++;
            }
            if (singleReadCounter >= SENSOR_TYPES) {
                readCounter++;
                singleReadCounter = 0;
            }
        }
        else {
            data = 0xffff;
            report_problem();
        }
    }

    event message_t* ReceiveInterval.receive(message_t* msg, void* payload, uint8_t len) {
        report_received();
        // TODO: update interval
    }

    // TODO: packet jump here
    // better find all nodes in the network and send to only nodeid < TOS_NODE_ID
}