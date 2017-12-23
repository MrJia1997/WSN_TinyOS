#ifndef MESSAGE_H
#define MESSAGE_H

enum {
    AM_RANDOM_MSG = 6,
    AM_RESULT_MSG = 111,
    AM_SUPPORT_MSG = 147,
    DATA_SIZE = 2000,
    GROUP_ID = 21
};

typedef nx_struct Random_Msg {
    nx_uint16_t sequence_number;
    nx_uint32_t random_integer;
} Random_Msg;

typedef nx_struct Result_Msg {
    nx_uint8_t group_id;
    nx_uint32_t max;
    nx_uint32_t min;
    nx_uint32_t sum;
    nx_uint32_t average;
    nx_uint32_t median;
} Result_Msg;

#endif