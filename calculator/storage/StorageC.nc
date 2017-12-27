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
    uint16_t seq;
    uint32_t data;
    uint32_t DataArray[DATA_NUMBER+1];

    void report_problem() { call Leds.led2Toggle(); }

    event void Boot.booted() {
        uint16_t i;
        RadioBusy = FALSE;
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
    
    task void handleRandomMsg() {
        DataArray[seq] = data;
        call Leds.led1Toggle();
    }

    //receive data from TA's node
    event message_t* DataReceive.receive(message_t* msg, void* payload, uint8_t len) {
        Data_Msg* rcvPayload;
        rcvPayload = (Data_Msg*)payload;
        // add data into array
        seq = rcvPayload -> sequence_number;
        data = rcvPayload -> random_integer;
        DataArray[seq] = data;
        //post handleRandomMsg();
        return msg;
    }

    task void send()
    {
        Data_Msg* sndPayload;
        sndPayload = (Data_Msg*)(call Packet.getPayload(&pkt, sizeof(Data_Msg)));
        if (sndPayload == NULL) {
            report_problem();
            return;
        }
        memcpy(sndPayload, &RequestData ,sizeof(Data_Msg));
        RadioBusy = TRUE;
        if(call AMSend.send(61, &pkt, sizeof(Data_Msg)) != SUCCESS)
        {
            call Leds.led0Toggle();
            post send();
        }
        
    }

    task void handleRequestMsg() {
        /*if(DataArray[RequestData.sequence_number] == 0xffffffff || RequestData.sequence_number == 0)
        {
            call Leds.led1Toggle();
            return;
        }*/
        RequestData.random_integer = DataArray[RequestData.sequence_number]; 
        post send();
    }

    //receive request from base node
     event message_t* RequestReceive.receive(message_t* msg, void* payload, uint8_t len) {
        Request_Msg* rcvPayload;
        rcvPayload = (Request_Msg*)payload;
        RequestData.sequence_number = rcvPayload->sequence_number;
        post handleRequestMsg();
        return msg;
    }



    event void AMSend.sendDone(message_t* msg, error_t err) {
        if (&pkt == msg) {
                if (err == SUCCESS) {
                    RadioBusy = FALSE;
            }
        }
    }
}