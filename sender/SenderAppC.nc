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
    App.RadioControl -> ActiveMessageC;
}