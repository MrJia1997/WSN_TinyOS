#include "Message.h"

module SenderC {
    uses { 
        interface Boot;
        interface Timer<TMilli>;
        interface Leds;
        interface Read<uint16_t> as ReadTemperature;
        interface Read<uint16_t> as ReadHumidity;
        interface Read<uint16_t> as ReadLightIntensity;
        interface Packet;
        interface AMSend;
        interface Receive as ReceiveTimeSync;
        interface Receive as ReceiveInterval;
        interface SplitControl as RadioControl;
    }
}

implementation {
    bool sendBusy;
    message_t sendBuf;
    uint8_t singleReadCounter;              // counter for three sensors reading
    uint8_t readCounter;                    // counter for 0~NREADINGS
    uint8_t seqCounter;                     // simply increase by 1 when sending a packet

    // current local state
    Sensor_Msg local;

    // Use LEDs to report various status issues.
    void report_problem() { call Leds.led0Toggle(); }
    void report_sent() { call Leds.led1Toggle(); }
    void report_received() { call Leds.led2Toggle(); }

    event void Boot.booted() {
        sendBusy = FALSE;
        seqCounter = 0;
        local.interval = DEFAULT_INTERVAL;
        local.nodeid = TOS_NODE_ID;
        local.seqNumber = seqCounter;
        if (call RadioControl.start() != SUCCESS)
            report_problem();
    }

    void startTimer() {
        call Timer.startPeriodic(local.interval);
        singleReadCounter = 0;
        readCounter = 0;
    }

    event void RadioControl.startDone(error_t err) {
        if (err == SUCCESS) {
            startTimer();
        } else {
            call RadioControl.start();
        }
    }
    event void RadioControl.stopDone(error_t err) {}
    
    event void Timer.fired() {
        // send packet
        if (readCounter == NREADINGS) {
            if (!sendBusy) {
                if(sizeof local <= call AMSend.maxPayloadLength()) {
                    memcpy(call AMSend.getPayload(&sendBuf, sizeof(local)), &local, sizeof local);
                    if (call AMSend.send(AM_BROADCAST_ADDR, &sendBuf, sizeof local) == SUCCESS) {
                        sendBusy = TRUE;
                        report_sent();
                    }
                }
                else
                    report_problem();
            }
            readCounter = 0;
            local.seqNumber = ++seqCounter;
            // TODO: maybe a sync here?
        }

        // multi sensors read
        if (call ReadTemperature.read() != SUCCESS)
            report_problem();
        if (call ReadHumidity.read() != SUCCESS)
            report_problem();
        if (call ReadLightIntensity.read() != SUCCESS)
            report_problem();
    }

    event void AMSend.sendDone(message_t* msg, error_t err) {
        if (err == SUCCESS)
            report_sent();
        else
            report_problem();

        sendBusy = FALSE;
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
            data = 0xffff
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
            data = 0xffff
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
            data = 0xffff
            report_problem();
        }
    }

    event message_t* ReceiveTimeSync.receive(message_t* msg, void* payload, uint8_t len) {
        report_received();
        // TODO: time synchronization
    }

    event message_t* ReceiveInterval.receive(message_t* msg, void* payload, uint8_t len) {
        report_received();
        // TODO: update interval
    }

    // TODO: packet jump here
    // better find all nodes in the network and send to only nodeid < TOS_NODE_ID
    
    // TODO: receive ack
}