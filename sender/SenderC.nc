#include "Message.h"

#define TIMER_PERIOD 2000

module SenderC {
    uses interface Boot;
    uses interface Timer<TMilli>;
    uses interface Leds;
    uses interface Read<uint16_t>;
    uses interface Packet;
    uses interface AMSend;
    uses interface SplitControl as RadioControl;
}

implementation {
    bool busy;
    message_t pkt;

    event void Boot.booted() {
        busy = FALSE;
        call RadioControl.start();
    }
    event void RadioControl.startDone(error_t err) {
        if (err == SUCCESS) {
            call Timer.startPeriodic(TIMER_PERIOD);
        } else {
            call RadioControl.start();
        }
    }
    event void RadioControl.stopDone(error_t err) {}
    event void Timer.fired() {
        call Leds.led0Toggle();
        call Read.read();
    }
    event void Read.readDone(error_t result, uint16_t val) {
        Temperature_Msg* payload;
        if (result == SUCCESS) {
            if(busy == FALSE) {
                payload = (Temperature_Msg*)(call Packet.getPayload(&pkt, sizeof(Temperature_Msg)));

                if (payload == NULL) {
                    return;
                }

                payload->temperature = val;
                if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Temperature_Msg)) == SUCCESS) {
                    busy = TRUE;
                }
            }
        }
    }
    event void AMSend.sendDone(message_t* msg, error_t err) {
        if (&pkt == msg) {
            call Leds.led0Toggle();
            busy = FALSE;
        }
    }
}