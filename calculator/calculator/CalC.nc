#include "Message.h"

module CalC {
    uses {
        interface Boot;
        interface Leds;
        interface Packet;
        interface PacketAcknowledgements;
        interface AMSend;
        interface Receive as ReceiveBase;
        interface SplitControl as RadioControl;
    }
}

implementation {
    bool sendBusy;
    message_t sendBuf;
    
    Result_Msg local;

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
    uint16_t lostSeq[100];
    uint8_t lostSeqHead;
    uint8_t lostSeqTail;

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
            if (call AMSend.send(AM_BROADCAST_ADDR, &sendBuf, sizeof local) != SUCCESS) {
                sendBusy = FALSE;
                post send();
            }                
        }
    }

    task void getLost() {
        // TODO: get lost packet
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
            lostSeqTail++;
        }
    }

    task void handleReceive() {
        uint16_t i;
        
        if (isFinish) {
            return;
        }

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
            if (seq != lastSeq + 1 && seq != (lastSeq - 1999)) {
                if (seq > lastSeq) {
                    for (i = lastSeq + 1; i < seq; i++) { lostSeqPush(i); }
                }
                else {
                    for (i = lastSeq + 1; i <= DATA_SIZE; i++) { lostSeqPush(i); }
                    for (i = 1; i < seq; i++) { lostSeqPush(i); }
                }
                call Leds.led0Toggle();
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
            call Leds.led1Toggle();
            memcpy(call AMSend.getPayload(&sendBuf, sizeof(local)), &local, sizeof local);
            if (call AMSend.send(AM_BROADCAST_ADDR, &sendBuf, sizeof local) != SUCCESS) {
                sendBusy = FALSE;
                post send();
            }
        }
    }

    event message_t* ReceiveBase.receive(message_t* msg, void* payload, uint8_t len) {
        Random_Msg *rcvPayload;

        // if (isFinish) {
        //     return NULL;
        // }

        call Leds.led2Toggle();
        // if (len != sizeof(Random_Msg)) {
        //     call Leds.led0On();
        //     return NULL;
        // }

        rcvPayload = (Random_Msg*)payload;
        seq = rcvPayload -> sequence_number;
        number = rcvPayload -> random_integer;
        
        // // Handle sequence number
        // if (firstSeq == 0xFFFF) {
        //     firstSeq = seq;
        // }
        // else {
        //     if (seq != lastSeq + 1 && seq != (lastSeq - 1999)) {
        //         if (seq > lastSeq) {
        //             for (i = lastSeq + 1; i < seq; i++) { lostSeqPush(i); }
        //         }
        //         else {
        //             for (i = lastSeq + 1; i <= DATA_SIZE; i++) { lostSeqPush(i); }
        //             for (i = 1; i < seq; i++) { lostSeqPush(i); }
        //         }
        //         call Leds.led0Toggle();
        //         post getLost();
        //     }
        // }
        // lastSeq = seq;
        
        // // data process
        // if (data[seq - 1] == 0xFFFFFFFF) {
        //     data[seq - 1] = temp;
        //     count++;
        //     sum += temp;
        //     if (temp > max) { max = temp; }
        //     if (temp < min) { min = temp; }
        // }
        
        // if (count == DATA_SIZE) {
        //     local.group_id = GROUP_ID;
        //     local.min = min;
        //     local.max = max;
        //     local.sum = sum;
        //     local.average = sum / count;
        //     // local.median = (data[999] + data[1000]) / 2;
        //     findMedian();
        //     isFinish = TRUE;
        //     call Leds.led2Toggle();
        //     if (call AMSend.send(AM_BROADCAST_ADDR, &sendBuf, sizeof local) != SUCCESS) {
        //         sendBusy = FALSE;
        //         post send();
        //     }
        // }
        post handleReceive();
        return msg;
    }

    event void AMSend.sendDone(message_t* msg, error_t err) {
        if (err == SUCCESS) {
            sendBusy = FALSE;
            // if(call PacketAcknowledgements.wasAcked(msg) != SUCCESS) {
            //     post send();
            // }
            call Leds.led1Toggle();
        }
        else {
            post send();
        }
    }
}