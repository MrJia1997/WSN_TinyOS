#include "Message.h"

module ReceiverC {
    uses {
        interface Boot;
        interface Leds;
        interface Packet;
        interface AMSend;
        interface Receive as RadioReceive;
        interface Receive as SerialReceive;
        interface SplitControl as RadioControl;
        interface SplitControl as SerialControl;
        interface StdControl;
    }
}
implementation {
    bool busy;
    message_t pkt;

    void report_problem() { call Leds.led2Toggle(); }

    event void Boot.booted() {
        busy = FALSE;
        call RadioControl.start();
        call SerialControl.start();
        call StdControl.start();
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

        if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Sensor_Msg)) == SUCCESS) {
            busy = TRUE;
            call Leds.led2Toggle();
        }
        return msg;
    }

    event void AMSend.sendDone(message_t* msg, error_t err) {
        if (&pkt == msg) {
            busy = FALSE;
            call Leds.led1Toggle();
        }
    }
}