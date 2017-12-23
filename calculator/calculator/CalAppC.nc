configuration CalAppC {}
implementation {
  components MainC, LedsC;
  components CalC as App;
  App.Boot -> MainC;
  App.Leds -> LedsC;
  
  components ActiveMessageC;
  App.Packet -> ActiveMessageC;
  App.PacketAcknowledgements -> ActiveMessageC;
  App.AMSend -> ActiveMessageC.AMSend[AM_RESULT_MSG];
  App.ReceiveBase -> ActiveMessageC.Receive[AM_RANDOM_MSG];
  App.RadioControl -> ActiveMessageC;
}