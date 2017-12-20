configuration ReceiverAppC {}
implementation {
  components MainC, LedsC;
  components TimeSyncC;
  MainC.SoftwareInit -> TimeSyncC;
  TimeSyncC.Boot -> MainC;

  components ReceiverC as App;
  components ActiveMessageC;
  components SerialActiveMessageC;

  App.Boot -> MainC.Boot;
  App.StdControl -> TimeSyncC;
  App.Leds -> LedsC.Leds;
  App.Packet -> SerialActiveMessageC;
  App.AMSend -> SerialActiveMessageC.AMSend[AM_SENSOR_MSG];
  App.RadioSend -> ActiveMessageC.AMSend[AM_SENSOR_MSG];
  App.RadioReceive -> ActiveMessageC.Receive[AM_SENSOR_MSG];
  App.SerialReceive -> ActiveMessageC.Receive[AM_SENSOR_MSG];
  App.RadioControl -> ActiveMessageC;
  App.SerialControl -> SerialActiveMessageC;
}