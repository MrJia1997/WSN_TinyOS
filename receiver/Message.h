#ifndef MESSAGE_H
#define MESSAGE_H

enum {AM_SENSOR_MSG = 85,
    AM_TIMESYNC_MSG = 95,
    AM_INTERVAL_MSG = 105,
    NREADINGS = 3,
    SENSOR_TYPES = 3,
    DEFAULT_INTERVAL = 500};

typedef nx_struct Sensor_Msg {
    nx_uint8_t nodeid;
    nx_uint16_t interval;
    nx_uint8_t seqNumber;
    nx_uint32_t collectTime[NREADINGS];
    nx_uint16_t temperature[NREADINGS];
    nx_uint16_t humidity[NREADINGS];
    nx_uint16_t lightIntensity[NREADINGS];
} Sensor_Msg;

#endif