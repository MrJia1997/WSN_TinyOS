#include "Message.h"

module ReceiverC {
    uses {
        interface Boot;
        interface Leds;
        interface Packet;
        interface Timer<TMilli> as TimerIntervalTimeout;
        interface AMSend as SerialSend;
        interface AMSend as RadioSend;
        interface Receive as RadioReceive;
        interface Receive as SerialReceive;
        interface Receive as IntervalAckReceive;
        interface SplitControl as RadioControl;
        interface SplitControl as SerialControl;
        interface StdControl;
    }
}
implementation {
    bool RadioBusy;
    bool SerialBusy;
    uint16_t interval;
    bool needSendInterval;
    bool nodeCount;
    message_t pkt;

    void report_problem() { call Leds.led2Toggle(); }

    event void Boot.booted() {
        RadioBusy = FALSE;
        SerialBusy = FALSE;
        needSendInterval = FALSE;
        nodeCount = 0;
        call RadioControl.start();
        call SerialControl.start();
        call StdControl.start();
        // call TimerIntervalTimeout.startPeriodic(500);
    }
    event void RadioControl.startDone(error_t err) {
        if (err != SUCCESS) {
            call RadioControl.start();
        }
    }
    event void RadioControl.stopDone(error_t err) { }

    event void SerialControl.startDone(error_t err) {
        if (err != SUCCESS) {
            call SerialControl.start();
        }
    }
    event void SerialControl.stopDone(error_t err) {}
    
    event message_t* RadioReceive.receive(message_t* msg, void* payload, uint8_t len) {
        Sensor_Msg* rcvPayload;
        Sensor_Msg* sndPayload;

        rcvPayload = (Sensor_Msg*)payload;
        sndPayload = (Sensor_Msg*)(call Packet.getPayload(&pkt, sizeof(Sensor_Msg)));

        if (sndPayload == NULL) {
            report_problem();
            return NULL;
        }
        memcpy(sndPayload, rcvPayload ,sizeof(Sensor_Msg));

        if (call SerialSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Sensor_Msg)) == SUCCESS) {
            SerialBusy = TRUE;
            call Leds.led2Toggle();
        }
        return msg;
    }

    event void TimerIntervalTimeout.fired() {
        Interval_Msg* sndPayload;
        if (nodeCount != 2) {
            sndPayload = (Interval_Msg*)(call Packet.getPayload(&pkt, sizeof(Interval_Msg)));
            sndPayload -> interval = interval;
            if (call RadioSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Interval_Msg)) == SUCCESS) {
                RadioBusy = TRUE;
                call Leds.led0Toggle();
                call TimerIntervalTimeout.startOneShot(500);
            }
        }
        nodeCount = 0;
    }

    event message_t* IntervalAckReceive.receive(message_t* msg, void* payload, uint8_t len) {
        nodeCount++;
    }

    event message_t* SerialReceive.receive(message_t* msg, void* payload, uint8_t len) {
        Interval_Msg* rcvPayload;
        Interval_Msg* sndPayload;
        call Leds.led1Toggle();
        rcvPayload = (Interval_Msg*)payload;
        sndPayload = (Interval_Msg*)(call Packet.getPayload(&pkt, sizeof(Interval_Msg)));

        if (sndPayload == NULL) {
            report_problem();
            return NULL;
        }
        memcpy(sndPayload, rcvPayload ,sizeof(Interval_Msg));
        interval = rcvPayload -> interval;
        nodeCount = 0;
        if (call RadioSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Interval_Msg)) == SUCCESS) {
            RadioBusy = TRUE;
            call Leds.led0Toggle();
            call TimerIntervalTimeout.startOneShot(500);
        }
        return msg;
    }

    event void RadioSend.sendDone(message_t* msg, error_t err) {
        if (&pkt == msg) {
            RadioBusy = FALSE;
        }
    }

    event void SerialSend.sendDone(message_t* msg, error_t err) {
        if (&pkt == msg) {
            SerialBusy = FALSE;
            call Leds.led2Toggle();
        }
    }
}