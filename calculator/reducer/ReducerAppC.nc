configuration ReducerAppC {}
implementation {
    components MainC
    components ReducerC as App;
    App.Boot -> MainC;

    components LedsC;
    App.Leds -> LedsC;

    // components new TimerMilliC() as Timer0;
    // App.Timer -> Timer0;

    components ActiveMessageC;
    App.Packet -> ActiveMessageC;
    App.PacketAcknowledgements -> ActiveMessageC;
    App.AMSend -> ActiveMessageC.AMSend[AM_RESULT_MSG];
    App.ReceiveData -> ActiveMessageC.Receive[AM_DATA_MSG];
    App.ReceiveAck -> ActiveMessageC.Receive[AM_ACK_MSG];
    App.RadioControl -> ActiveMessageC;
}