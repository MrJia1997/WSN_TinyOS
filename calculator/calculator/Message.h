#ifndef MESSAGE_H
#define MESSAGE_H

enum {
    AM_RANDOM_MSG = 243,
    AM_RESULT_MSG = 97,
    AM_SUPPORT_MSG = 147,
    AM_SUPPORT_DATA_MSG = 149,
    DATA_SIZE = 2000,
    LOST_SEQ_LENGTH = 200,
    STORAGE = 1,    // TODO: to be changed into 2
    GROUP_ID = 21,
    ROOT_ID = 0
};

typedef nx_struct Random_Msg {
    nx_uint16_t sequence_number;
    nx_uint32_t random_integer;
} Random_Msg;

typedef nx_struct Support_Msg {
    nx_uint16_t sequence_number;
} Support_Msg;

typedef nx_struct Result_Msg {
    nx_uint8_t group_id;
    nx_uint32_t max;
    nx_uint32_t min;
    nx_uint32_t sum;
    nx_uint32_t average;
    nx_uint32_t median;
} Result_Msg;

#endif