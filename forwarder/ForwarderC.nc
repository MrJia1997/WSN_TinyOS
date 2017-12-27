#include "Message.h"

module ForwarderC {
    uses { 
        interface Boot;
        interface Timer<TMilli> as TimerRead;
        interface Leds;
        interface Read<uint16_t> as ReadTemperature;
        interface Read<uint16_t> as ReadHumidity;
        interface Read<uint16_t> as ReadLightIntensity;
        interface Packet;
        interface PacketAcknowledgements;
        interface AMSend as DataSend;
        interface AMSend as IntervalAckSend;
        interface Receive as ReceiveInterval;
        interface Receive as ReceiveSensorMsg;
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
    uint32_t globalTime;

    // current local state
    Sensor_Msg local;
    Sensor_Msg localQueue[QUEUE_LENGTH];
    uint8_t headPos;                        // queue head pointer
    uint8_t tailPos;                        // queue tail pointer + 1
    bool queueFull;

    // Use LEDs to report various status issues.
    void report_problem() { call Leds.led0On(); }
    void report_sent() { call Leds.led1Toggle(); }
    void report_received() { call Leds.led2Toggle(); }

    // GBN implement
    uint8_t cal_pos(uint8_t pos, uint8_t alias) {
        return (pos + alias) >= QUEUE_LENGTH ? pos + alias : pos + alias - QUEUE_LENGTH;
    }
    task void send() {
        if (headPos != tailPos || queueFull) {
            if(sizeof local <= call DataSend.maxPayloadLength()) {
                call Leds.led1On();
                memcpy(call DataSend.getPayload(&sendBuf, sizeof(local)), localQueue + headPos, sizeof local);
                if (call PacketAcknowledgements.requestAck(&sendBuf) != SUCCESS)
                    report_problem();
                sendBusy = TRUE;
                // TODO: Change addr
                if (call DataSend.send(ROOT_ID, &sendBuf, sizeof local) != SUCCESS) {
                    post send();
                }             
            }
            else
                report_problem();
        }
        else {
            call Leds.led1Off();
            sendBusy = FALSE;
        }    
    }

    // timer start
    void start_read_timer() {
        call TimerRead.startPeriodic(local.interval);
        singleReadCounter = 0;
        readCounter = 0;
    }

    event void Boot.booted() {
        // initialize status flags
        sendBusy = FALSE;

        // initialize queue
        headPos = 0;
        tailPos = 0;
        queueFull = FALSE;

        // initialize local Sensor_Msg
        local.interval = DEFAULT_INTERVAL;
        local.nodeid = TOS_NODE_ID;
        local.seqNumber = 0;
        
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
        if (queueFull)
            return;

        // read data and add it to queue
        if (readCounter == NREADINGS) {
            // add to queue
            localQueue[tailPos] = local;
            tailPos = cal_pos(tailPos, 1);
            local.seqNumber++;
            if (tailPos == headPos) {
                queueFull = TRUE;
                report_problem();
            }
            if (!sendBusy)
                post send();
            // reset read counter
            readCounter = 0;
        }
        else {
            if (singleReadCounter != 0) {
                return;
            }
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

    event void DataSend.sendDone(message_t* msg, error_t err) {
        if (err == SUCCESS) {
            if(call PacketAcknowledgements.wasAcked(msg)) {
                headPos = cal_pos(headPos, 1);
                queueFull = FALSE;
            }
                
            post send();
        }
        else
            report_problem();
    }

    event void IntervalAckSend.sendDone(message_t* msg, error_t err) {
        if (err != SUCCESS) {
            report_problem();
        }
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
        Interval_Msg *rcvPayload;
        Ack_Interval_Msg* sndPayload;
        report_received();
        // update interval
        if (len != sizeof(Interval_Msg)) {
            report_problem();
            report_received();
            return NULL;
        }
        rcvPayload = (Interval_Msg*)payload;
        local.interval = rcvPayload->interval;
        
        sndPayload = (Ack_Interval_Msg*)(call Packet.getPayload(&sendBuf, sizeof(Ack_Interval_Msg)));
        sndPayload -> isReceived = 1;
        if (call IntervalAckSend.send(ROOT_ID, &sendBuf, sizeof(Ack_Interval_Msg)) != SUCCESS) {
            call Leds.led0Toggle();
        }

        call TimerRead.stop();
        start_read_timer();
        return msg;
    }

    event message_t* ReceiveSensorMsg.receive(message_t* msg, void* payload, uint8_t len) {
        Sensor_Msg *rcvPayload;
        report_received();
        if (queueFull)
            return NULL;
        if (len != sizeof(Sensor_Msg)) {
            report_problem();
            report_received();
            return NULL;
        }
        rcvPayload = (Sensor_Msg*)payload;
        // add to queue
        memcpy(localQueue + tailPos, rcvPayload, sizeof(Sensor_Msg));
        tailPos = cal_pos(tailPos, 1);
        if (tailPos == headPos) {
            queueFull = TRUE;
            report_problem();
        }
        if (!sendBusy)
            post send();
        
        report_received();
        return msg;
    }
    // better find all nodes in the network and send to only nodeid < TOS_NODE_ID
}