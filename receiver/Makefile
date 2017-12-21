COMPONENT=ReceiverAppC
BUILD_EXTRA_DEPS += Receiver.class
CLEAN_EXTRA = *.class Message.java
CFLAGS += -I$(TOSDIR)/lib/T2Hack
CFLAGS += -I$(TOSDIR)/lib/ftsp
CFLAGS += -DTOSH_DATA_LENGTH=50
PFLAGS += -DTIMESYNC_RATE=3
Receiver.class: $(wildcard *.java) Message.java
	javac *.java
Message.java:
	mig java -target=null $(CFLAGS) -java-classname=Message Message.h Sensor_Msg -o $(@)
include $(MAKERULES)
