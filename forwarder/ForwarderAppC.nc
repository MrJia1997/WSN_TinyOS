configuration ForwarderAppC {}
implementation {
    components MainC, TimeSyncC;
    MainC.SoftwareInit -> TimeSyncC;
    TimeSyncC.Boot -> MainC;

    components ForwarderC as App;
    App.Boot -> MainC;
    App.GlobalTime -> TimeSyncC;
    App.StdControl -> TimeSyncC;

    components LedsC;
    App.Leds -> LedsC;

    components new TimerMilliC() as Timer0;
    App.TimerRead -> Timer0;
    // components new TimerMilliC() as Timer1;
    // App.TimerResend -> Timer1;

    components new SensirionSht11C() as Sensor0;
    components new HamamatsuS1087ParC() as Sensor1;
    App.ReadTemperature -> Sensor0.Temperature;
    App.ReadHumidity -> Sensor0.Humidity;
    App.ReadLightIntensity -> Sensor1;
    
    components ActiveMessageC;
    App.Packet -> ActiveMessageC;
    App.PacketAcknowledgements -> ActiveMessageC;
    App.DataSend -> ActiveMessageC.AMSend[AM_SENSOR_MSG];
    App.IntervalAckSend -> ActiveMessageC.AMSend[AM_INTERVAL_ACK_MSG];
    App.ReceiveInterval -> ActiveMessageC.Receive[AM_INTERVAL_MSG];
    App.ReceiveSensorMsg -> ActiveMessageC.Receive[AM_SENSOR_MSG];
    App.RadioControl -> ActiveMessageC;
}