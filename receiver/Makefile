COMPONENT=ReceiverAppC
BUILD_EXTRA_DEPS += Receiver.class
CLEAN_EXTRA = *.class Message.java
CFLAGS += -I$(TOSDIR)/lib/T2Hack
Receiver.class: $(wildcard *.java) Message.java
javac -target 1.5 -source 1.5 *.java
Message.java:
mig java -target=null $(CFLAGS) -java-classname=Message Message.h Temperature_Msg -o $(@)
include $(MAKERULES)