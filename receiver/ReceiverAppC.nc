configuration ReceiverAppC {}
implementation {
  components MainC, LedsC;
  components ReceiverC as App;
  components ActiveMessageC;
  components SerialActiveMessageC;

  App.Boot -> MainC.Boot;
  App.Leds -> LedsC.Leds;
  App.Packet -> SerialActiveMessageC;
  App.AMSend -> SerialActiveMessageC.AMSend[AM_TEMPERATURE_MSG];
  App.Receive -> ActiveMessageC.Receive[AM_TEMPERATURE_MSG];
  App.RadioControl -> ActiveMessageC;
  App.SerialControl -> SerialActiveMessageC;
}