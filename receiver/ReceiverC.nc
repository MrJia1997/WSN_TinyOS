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
    event void RadioControl.stopDone(error_t err) {}
    event void SerialControl.startDone(error_t err) {
        if (err != SUCCESS) {
            call SerialControl.start();
        }
    }
    event void SerialControl.stopDone(error_t err) {}
    event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
        Temperature_Msg* rcvPayload, sndPayload;

        call Leds.led1Toggle();
        if (len != sizeof(Temperature_Msg)) {
            return NULL;
        }

        rcvPayload = (Temperature_Msg*)payload;
        sndPayload = (Temperature_Msg*)(call Packet.getPayload(&pkt, sizeof(Temperature_Msg)));

        if (sndPayload == NULL) {
            return NULL;
        }

        sndPayload->temperature = rcvPayload->temperature;

        if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Temperature_Msg)) == SUCCESS) {
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