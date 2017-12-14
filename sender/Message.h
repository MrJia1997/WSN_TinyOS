#ifndef MESSAGE_H
#define MESSAGE_H

typedef nx_struct Sensor_Msg {
    nx_uint16_t nodeid;
    nx_uint16_t seqNumber;
    nx_uint16_t collectTime;
    nx_uint16_t temperature;
    nx_uint16_t humidity;
    nx_uint16_t lightIntensity;
} Sensor_Msg;

enum {AM_SENSOR_MSG = 85};

#endif
