configuration SenderAppC {}
implementation {
    components SenderC as App;
    components MainC, LedsC;
    components new TimerMilliC() as Timer;
    components ActiveMessageC;
    components new SensirionSht11C() as Sensor0;

    App.Boot -> MainC;
    App.Leds -> LedsC;
    App.Timer -> Timer;
    App.ReadTemperature -> Sensor0.Temperature;
    App.ReadHumidity -> Sensor0.Humidity;
    App.Packet -> ActiveMessageC;
    App.AMSend -> ActiveMessageC.AMSend[AM_SENSOR_MSG];
    App.ReceiveTimeSync -> ActiveMessageC.Receive[AM_TIMESYNC_MSG];
    App.ReceiveInterval -> ActiveMessageC.Receive[AM_INTERVAL_MSG];
    App.RadioControl -> ActiveMessageC;
}