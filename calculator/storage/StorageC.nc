#include "Message.h"

module StorageC {
    uses {
        interface Boot;
        interface Leds;
        interface Packet;
        interface PacketAcknowledgements;
        interface AMSend;
        interface Receive as DataReceive;
        interface Receive as RequestReceive;
        interface SplitControl as RadioControl;
    }
}
implementation {
    bool RadioBusy;
    message_t pkt;
    Data_Msg RequestData;
    uint32_t DataArray[DATA_NUMBER+1]

    void report_problem() { call Leds.led2Toggle(); }

    event void Boot.booted() {
        RadioBusy = FALSE;
        uint16_t i = 0;
        for( i = 0; i < DATA_NUMBER; i++)
        {
            DataArray[i] = 0xffffffff;
        }

        call RadioControl.start();
    }
    event void RadioControl.startDone(error_t err) {
        if (err != SUCCESS) {
            call RadioControl.start();
        }
    }
    event void RadioControl.stopDone(error_t err) { }
    
    //receive data from TA's node
    event message_t* DataReceive.receive(message_t* msg, void* payload, uint8_t len) {
        Data_Msg* rcvPayload;
        Data_Msg* sndPayload;

        rcvPayload = (Data_Msg*)payload;
        sndPayload = (Data_Msg*)(call Packet.getPayload(&pkt, sizeof(Data_Msg)));

        if (sndPayload == NULL) {
            report_problem();
            return NULL;
        }
        memcpy(sndPayload, rcvPayload ,sizeof(Sensor_Msg));
        // add data into array
        DataArray[rcvPayload->sequence_number] = DataArray[rcvPayload->random_integer]
        return msg;
    }

    task void send()
    {
        Request_Msg* sndPayload;
        sndPayload = (Data_Msg*)(call Packet.getPayload(&pkt, sizeof(Data_Msg)));
        if (sndPayload == NULL) {
            report_problem();
            return NULL;
        }
        memcpy(sndPayload, &RequestData ,sizeof(Data_Msg));
        if (call PacketAcknowledgements.requestAck(&pkt) != SUCCESS)
            report_problem();
        RadioBusy = TRUE;
        if(call AMSend.send(GROUP_ID, &pkt, sizeof(Data_Msg)) != SUCCESS)
            post send();

    }

    //receive request from base node
     event message_t* RequestReceive.receive(message_t* msg, void* payload, uint8_t len) {
        Request_Msg* rcvPayload；
        rcvPayload = (Request_Msg*)payload;
        RequestData.sequence_number = rcvPayload->sequence_number;
        RequestData.random_integer = DataArray[rcvPayload->sequence_number];
        post send();
        return msg;
    }

    event void AMSend.sendDone(message_t* msg, error_t err) {
        if (&pkt == msg) {
            RadioBusy = FALSE;
            call Leds.led1Toggle();
        }
        if (err == SUCCESS) {
            if(call PacketAcknowledgements.wasAcked(msg)) {
                RadioBusy = FALSE;
            }
        }
    }

    
}