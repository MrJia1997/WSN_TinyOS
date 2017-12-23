configuration StorageAppC {}
implementation {
    components MainC
    components StorageC as App;
    App.Boot -> MainC;

    components LedsC;
    App.Leds -> LedsC;

    // components new TimerMilliC() as Timer0;
    // App.Timer -> Timer0;

    components ActiveMessageC;
    App.Packet -> ActiveMessageC;
    App.PacketAcknowledgements -> ActiveMessageC;
    App.AMSend -> ActiveMessageC.AMSend[AM_MYDATA_MSG];
    App.DataReceive -> ActiveMessageC.Receive[AM_DATA_MSG];
    App.RequestReceive -> ActiveMessageC.Receive[AM_REQUEST_MSG];
    App.RadioControl -> ActiveMessageC;
}