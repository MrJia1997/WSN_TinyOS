configuration SenderAppC {}
implementation {
    components MainC, TimeSyncC;
    MainC.SoftwareInit -> TimeSyncC;
    TimeSyncC.Boot -> MainC;

    components SenderC as App;
    App.Boot -> MainC;
    App.GlobalTime -> TimeSyncC;
    App.StdControl -> TimeSyncC;

    components LedsC;
    App.Leds -> LedsC;

    components new TimerMilliC() as Timer;
    App.Timer -> Timer;

    components new SensirionSht11C() as Sensor0;
    components new HamamatsuS1087ParC() as Sensor1;
    App.ReadTemperature -> Sensor0.Temperature;
    App.ReadHumidity -> Sensor0.Humidity;
    App.ReadLightIntensity -> Sensor1;
    
    components ActiveMessageC;
    App.Packet -> ActiveMessageC;
    App.AMSend -> ActiveMessageC.AMSend[AM_SENSOR_MSG];
    App.ReceiveInterval -> ActiveMessageC.Receive[AM_INTERVAL_MSG];
    App.RadioControl -> ActiveMessageC;
}