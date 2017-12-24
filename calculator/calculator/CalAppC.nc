configuration CalAppC {}
implementation {
  components MainC, LedsC;
  components CalC as App;
  App.Boot -> MainC;
  App.Leds -> LedsC;
  
  components ActiveMessageC;
  App.Packet -> ActiveMessageC;
  App.PacketAcknowledgements -> ActiveMessageC;
  App.ResultSend -> ActiveMessageC.AMSend[AM_RESULT_MSG];
  App.SupportSend -> ActiveMessageC.AMSend[AM_SUPPORT_MSG];
  App.ReceiveBase -> ActiveMessageC.Receive[AM_RANDOM_MSG];
  App.ReceiveSupport -> ActiveMessageC.Receive[AM_SUPPORT_MSG];
  App.RadioControl -> ActiveMessageC;
}