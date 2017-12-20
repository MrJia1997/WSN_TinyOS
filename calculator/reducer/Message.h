#ifndef MESSAGE_H
#define MESSAGE_H

enum {
    AM_DATA_MSG = 6,
    AM_RESULT_MSG = 20,
    AM_ACK_MSG = 30,
    REDUCER_ID = 0
};

typedef nx_struct Data_Msg {
    nx_uint16_t sequence_number;
    nx_uint32_t random_integer;
} Data_Msg;

typedef nx_struct Result_Msg {
    nx_uint8_t group_id;
    nx_uint32_t max;
    nx_uint32_t min;
    nx_uint32_t sum;
    nx_uint32_t average;
    nx_uint32_t median;
} Result_Msg;

typedef nx_struct Ack_Msg {
    nx_uint8_t group_id;
} Ack_Msg;
#endif
