#ifndef MESSAGE_H
#define MESSAGE_H

enum {
    AM_DATA_MSG = 6,
    AM_MYDATA_MSG = 149,
    AM_REQUEST_MSG = 40,
    GROUP_ID = 21,
    DATA_NUMBER = 2000
};

typedef nx_struct Data_Msg {
    nx_uint16_t sequence_number;
    nx_uint32_t random_integer;
} Data_Msg;

typedef nx_struct Request_Msg {
    nx_uint16_t sequence_number;
} Request_Msg;

#endif
