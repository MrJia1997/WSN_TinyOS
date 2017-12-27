configuration ReceiverAppC {}
implementation {
  components MainC, LedsC;
  components TimeSyncC;
  MainC.SoftwareInit -> TimeSyncC;
  TimeSyncC.Boot -> MainC;

  components ReceiverC as App;
  components ActiveMessageC;
  components SerialActiveMessageC;
  components new TimerMilliC() as Timer0;
  App.TimerIntervalTimeout -> Timer0;
  App.Boot -> MainC.Boot;
  App.StdControl -> TimeSyncC;
  App.Leds -> LedsC.Leds;
  App.Packet -> SerialActiveMessageC;
  App.SerialSend -> SerialActiveMessageC.AMSend[AM_SENSOR_MSG];
  App.RadioSend -> ActiveMessageC.AMSend[AM_INTERVAL_MSG];
  App.RadioReceive -> ActiveMessageC.Receive[AM_SENSOR_MSG];
  App.IntervalAckReceive -> ActiveMessageC.Receive[AM_INTERVAL_ACK_MSG];
  App.SerialReceive -> SerialActiveMessageC.Receive[AM_INTERVAL_MSG];
  App.RadioControl -> ActiveMessageC;
  App.SerialControl -> SerialActiveMessageC;
}