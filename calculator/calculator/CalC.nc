#include "Message.h"

module CalC {
    uses {
        interface Boot;
        interface Leds;
        interface Packet;
        interface PacketAcknowledgements;
        interface AMPacket;
        interface AMSend as ResultSend;
        interface AMSend as SupportSend;
        interface Receive as ReceiveBase;
        interface Receive as ReceiveSupport;
        interface SplitControl as RadioControl;
        interface Timer<TMilli> as TimerSendSupport;
    }
}

implementation {
    bool sendBusy;
    message_t sendBuf;
    
    Result_Msg local;
    Support_Msg localSupport;

    uint32_t min;
    uint32_t max;
    uint32_t sum;
    uint32_t average;
    uint32_t median;

    uint16_t seq;
    uint32_t number;

    uint16_t count;
    uint16_t firstSeq;
    uint16_t lastSeq;
    bool isFinish;

    uint32_t data[DATA_SIZE];
    uint16_t lostSeq[LOST_SEQ_LENGTH];
    uint8_t lostSeqHead;
    uint8_t lostSeqTail;
    uint8_t storageCount;

    void swapInArray(uint16_t posA, uint16_t posB) {
        uint32_t temp;
        temp = data[posA];
        data[posA] = data[posB];
        data[posB] = temp;
    }

    uint16_t oneWayChange(uint16_t left, uint16_t right) {
        uint32_t pivot;
        uint16_t tempLeft, tempRight;
        
        swapInArray((left + right) / 2, left);
        pivot = data[left];
        tempLeft = left + 1;
        tempRight = right;

        while (1) {
            while (data[tempLeft] <= pivot && tempLeft < right) {
                tempLeft++;
            }
            while (data[tempRight] > pivot && tempRight > left) {
                tempRight--;
            }
            if (tempLeft >= tempRight) {
                break;
            }
            swapInArray(tempLeft, tempRight);
        }

        swapInArray(left, tempRight);
        return tempRight;
    }

    void findMedian() {
        uint16_t leftEdge, rightEdge;
        uint16_t pivotPos;
        uint16_t i, j;

        leftEdge = 0;
        rightEdge = DATA_SIZE - 1;

        while(1) {
            if (rightEdge - leftEdge <= 20) {
                break;
            }
            pivotPos = oneWayChange(leftEdge, rightEdge);
            if (pivotPos >= DATA_SIZE / 2) {
                rightEdge = pivotPos;
            }
            else {
                leftEdge = pivotPos;
            }
        }

        // Insert sort
        for (i = leftEdge + 1; i <= rightEdge; i++) {
            for (j = i; j > leftEdge; j--) {
                if (data[j] < data[j - 1]) {
                    swapInArray(j - 1, j);
                }
            }
        }

        local.median = (data[999] + data[1000]) / 2;
    } 

    task void send() {
        if (!sendBusy) {
            // if (call PacketAcknowledgements.requestAck(&sendBuf) != SUCCESS)
            //     call Leds.led0On();
            sendBusy = TRUE;
            if (call ResultSend.send(ROOT_ID, &sendBuf, sizeof local) != SUCCESS) {
                sendBusy = FALSE;
                post send();
            }
        }
    }

    task void getLost() {
        // get lost packet
        if (!sendBusy && lostSeqHead != lostSeqTail) {
            if (lostSeq[lostSeqHead] == 0 || data[lostSeq[lostSeqHead] - 1] != 0xFFFFFFFF) {
                lostSeqHead = (lostSeqHead + 1) % LOST_SEQ_LENGTH;
                if (lostSeqHead != lostSeqTail) 
                    post getLost();
            }
            sendBusy = TRUE;
            call Leds.led1Toggle();
            localSupport.sequence_number = lostSeq[lostSeqHead];
            memcpy(call SupportSend.getPayload(&sendBuf, sizeof(localSupport)), &localSupport, sizeof localSupport);
            // call PacketAcknowledgements.requestAck(&sendBuf);
            if (call SupportSend.send(62, &sendBuf, sizeof local) != SUCCESS) {
                // call Leds.led1Toggle();
                sendBusy = FALSE;
                // post getLost();
            }
        }
    }

    event void TimerSendSupport.fired() {
        if (lostSeqHead != lostSeqTail)
            post getLost();
    }

    event void Boot.booted() {
        uint16_t i;
        for (i = 0; i < DATA_SIZE; i++)
            data[i] = 0xFFFFFFFF;
        
        sendBusy = FALSE;
        min = 0xFFFFFFFF;
        max = 0;
        sum = 0;
        average = 0;
        median = 0;
        
        count = 0;
        firstSeq = 0xFFFF;
        lastSeq = 0;
        isFinish = FALSE;
        lostSeqHead = 0;
        lostSeqTail = 0;
        storageCount = 0;
        
        call TimerSendSupport.startPeriodic(200);
        if (call RadioControl.start() != SUCCESS)
            call Leds.led0On();
    }

    event void RadioControl.startDone(error_t err) {
        if (err != SUCCESS)
            call RadioControl.start();
    }

    event void RadioControl.stopDone(error_t err) {}

    void lostSeqPush(uint16_t sequence) {
        if (data[sequence - 1] == 0xFFFFFFFF) {
            lostSeq[lostSeqTail] = sequence;
            lostSeqTail = (lostSeqTail + 1) % LOST_SEQ_LENGTH;
        }
    }

    task void handleRandomReceive() {
        uint16_t i;
        
        if (isFinish) {
            return;
        }

        if(lostSeq[lostSeqHead] == seq)
            lostSeqHead = (lostSeqHead + 1) % LOST_SEQ_LENGTH;
        // call Leds.led2Toggle();
        // if (len != sizeof(Random_Msg)) {
        //     call Leds.led0On();
        //     return NULL;
        // }

        // Handle sequence number
        if (firstSeq == 0xFFFF) {
            firstSeq = seq;
        }
        else {
            if (seq != (lastSeq + 1) && seq != (lastSeq - 1999)) {
                if (seq > lastSeq) {
                    for (i = lastSeq + 1; i < seq; i++) { lostSeqPush(i); }
                }
                else {
                    for (i = lastSeq + 1; i <= DATA_SIZE; i++) { lostSeqPush(i); }
                    for (i = 1; i < seq; i++) { lostSeqPush(i); }
                }
                // call Leds.led0Toggle();
                post getLost();
            }
        }
        lastSeq = seq;
        
        // data process
        if (data[seq - 1] == 0xFFFFFFFF) {
            data[seq - 1] = number;
            count++;
            sum += number;
            if (number > max) { max = number; }
            if (number < min) { min = number; }
        }
        
        if (count == DATA_SIZE) {
            local.group_id = GROUP_ID;
            local.min = min;
            local.max = max;
            local.sum = sum;
            local.average = sum / count;
            // local.median = (data[999] + data[1000]) / 2;
            findMedian();
            isFinish = TRUE;
            call Leds.led2On();
            memcpy(call ResultSend.getPayload(&sendBuf, sizeof(local)), &local, sizeof local);
            if (call ResultSend.send(ROOT_ID, &sendBuf, sizeof local) != SUCCESS) {
                sendBusy = FALSE;
                post send();
            }
        }
    }

    task void handleSupportReceive() {
        if (isFinish) {
            return;
        }

        // call Leds.led2Toggle();
        // if (len != sizeof(Random_Msg)) {
        //     call Leds.led0On();
        //     return NULL;
        // }

        // data process
        if (data[seq - 1] == 0xFFFFFFFF && number != 0xFFFFFFFF) {
            data[seq - 1] = number;
            count++;
            sum += number;
            if (number > max) { max = number; }
            if (number < min) { min = number; }
        }
        
        // TODO: to be changed into 3
        if (storageCount == 1) {
            if (data[seq - 1] == 0xFFFFFFFF) {
                lostSeqPush(lostSeq[lostSeqHead]);    
            }
            lostSeqHead = (lostSeqHead + 1) % LOST_SEQ_LENGTH;
            storageCount = 0;
        }

        if (count == DATA_SIZE) {
            local.group_id = GROUP_ID;
            local.min = min;
            local.max = max;
            local.sum = sum;
            local.average = sum / count;
            // local.median = (data[999] + data[1000]) / 2;
            findMedian();
            isFinish = TRUE;
            call Leds.led2On();
            memcpy(call ResultSend.getPayload(&sendBuf, sizeof(local)), &local, sizeof local);
            if (call ResultSend.send(ROOT_ID, &sendBuf, sizeof local) != SUCCESS) {
                sendBusy = FALSE;
                post send();
            }
        }
    }

    event message_t* ReceiveBase.receive(message_t* msg, void* payload, uint8_t len) {
        Random_Msg *rcvPayload;

        // call Leds.led2Toggle();
        
        rcvPayload = (Random_Msg*)payload;
        seq = rcvPayload -> sequence_number;
        number = rcvPayload -> random_integer;

        post handleRandomReceive();
        return msg;
    }

    event message_t* ReceiveSupport.receive(message_t* msg, void* payload, uint8_t len) {
        Random_Msg *rcvPayload;
        uint8_t source;

        call Leds.led2Toggle();

        rcvPayload = (Random_Msg*)payload;
        seq = rcvPayload -> sequence_number;
        number = rcvPayload -> random_integer;
        source = call AMPacket.source(msg);
        if (source == 62) 
            storageCount = storageCount | 1;
        else if (source == 63)
            storageCount = storageCount | 2;

        post handleSupportReceive();
        return msg;
    }

    event void ResultSend.sendDone(message_t* msg, error_t err) {
        sendBusy = FALSE;
        if (err == SUCCESS) {
            // if(call PacketAcknowledgements.wasAcked(msg) != SUCCESS) {
            //     post send();
            // }
            // call Leds.led0Toggle();
            call Leds.led2Off();
        }
        else {
            post send();
        }
    }

    event void SupportSend.sendDone(message_t* msg, error_t err) {
        sendBusy = FALSE;
        if (err == SUCCESS) {
            call Leds.led1Toggle();
            // if (lostSeqHead != lostSeqTail)
            //     post getLost();
        }
        else {
            call Leds.led0Toggle();
            // post getLost();
        }
    }
}