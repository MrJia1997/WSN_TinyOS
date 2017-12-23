COMPONENT=ReceiverAppC
BUILD_EXTRA_DEPS += Receiver.class
CLEAN_EXTRA = *.class Message.java
CFLAGS += -I$(TOSDIR)/lib/T2Hack
CFLAGS += -I$(TOSDIR)/lib/ftsp
CFLAGS += -DTOSH_DATA_LENGTH=50
PFLAGS += -DTIMESYNC_RATE=3
Receiver.class: $(wildcard *.java) SensorMessage.java IntervalMessage.java
	javac *.java
SensorMessage.java:
	mig java -target=null $(CFLAGS) -java-classname=SensorMessage Message.h Sensor_Msg -o $(@)
IntervalMessage.java:
	mig java -target=null $(CFLAGS) -java-classname=IntervalMessage Message.h Interval_Msg -o $(@)
include $(MAKERULES)
