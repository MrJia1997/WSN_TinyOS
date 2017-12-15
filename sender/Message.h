#ifndef MESSAGE_H
#define MESSAGE_H

enum {
    AM_SENSOR_MSG = 85,
    NREADINGS = 10,
    SENSOR_TYPES = 3,
    DEFAULT_INTERVAL = 100
};

typedef nx_struct Sensor_Msg {
    nx_uint16_t nodeid;
    nx_uint16_t interval;
    nx_uint16_t seqNumber;
    nx_uint16_t collectTime[NREADINGS];
    nx_uint16_t temperature[NREADINGS];
    nx_uint16_t humidity[NREADINGS];
    nx_uint16_t lightIntensity[NREADINGS];
} Sensor_Msg;

#endif
