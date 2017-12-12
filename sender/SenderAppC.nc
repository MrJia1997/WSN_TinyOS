configuration SenderAppC {}
implementation {
    components SenderC as App;
    components MainC, LedsC;
    components new TimerMilliC() as Timer;
    components ActiveMessageC;
    components new SensirionSht11C() as Sense;

    App.Boot -> MainC;
    App.Leds -> LedsC;
    App.Timer -> Timer;
    App.Read -> Sense.Temperature;
    App.Packet -> ActiveMessageC;
    App.AMSend -> ActiveMessageC.AMSend[AM_TEMPERATURE_MSG];
    App.RadioControl -> ActiveMessageC;
}