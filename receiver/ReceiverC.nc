#include "Message.h"

module ReceiverC {
    uses {
        interface Boot;
        interface Leds;
        interface Packet;
        interface AMSend;
        interface Receive;
        interface SplitControl as RadioControl;
        interface SplitControl as SerialControl;
    }
}
implementation {
    bool busy;
    message_t pkt;

    void report_problem() { call Leds.led0Toggle(); }

    event void Boot.booted() {
        busy = FALSE;
        call RadioControl.start();
        call SerialControl.start();
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
    
    event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
        Sensor_Msg* rcvPayload;
        Sensor_Msg* sndPayload;

        call Leds.led1Toggle();
        if (len != sizeof(Sensor_Msg)) {
            report_problem()；
            return NULL;
        }

        rcvPayload = (Sensor_Msg*)payload;
        sndPayload = (Sensor_Msg*)(call Packet.getPayload(&pkt, sizeof(Sensor_Msg)));

        if (sndPayload == NULL) {
            report_problem()；
            return NULL;
        }
        memcpy(sndPayload->nodeid, rcvPayload->nodeid ,sizeof(rcvPayload->nodeid));
        memcpy(sndPayload->interval, rcvPayload->interval ,sizeof(rcvPayload->interval));
        memcpy(sndPayload->seqNumber, rcvPayload->seqNumber ,sizeof(rcvPayload->seqNumber));
      
        memcpy(sndPayload->collectTime, rcvPayload->collectTime ,sizeof(rcvPayload->collectTime));
        memcpy(sndPayload->temperature, rcvPayload->temperature ,sizeof(rcvPayload->temperature));
        memcpy(sndPayload->humidity, rcvPayload->humidity ,sizeof(rcvPayload->humidity));
        memcpy(sndPayload->lightIntensity, rcvPayload->lightIntensity ,sizeof(rcvPayload->lightIntensity));

        if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Sensor_Msg)) == SUCCESS) {
            busy = TRUE;
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