import java.util.*;
import java.io.FileWriter;
import java.io.IOException;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

public class MsgReader implements MessageListener, CallBack{

  private MoteIF moteIF;
  
  private MainWindow mainWindow;

  private FileWriter fileWriter;

  private int interval;

  public MsgReader(String source) throws Exception {
    if (source != null) {
      moteIF = new MoteIF(BuildSource.makePhoenix(source, PrintStreamMessenger.err));
    }
    else {
      moteIF = new MoteIF(BuildSource.makePhoenix(PrintStreamMessenger.err));
    }
    mainWindow = new MainWindow("tinyOS ����");
    interval = 100;
    mainWindow.setCallBack(this);
  }

  public void start() {
  }

  public void run() {
    int interval = mainWindow.getSendTime();
    IntervalMessage message = new IntervalMessage();
    System.out.println(interval);
    message.set_interval(interval);
    try {
      for (int i = 0; i < 20; ++i)
        moteIF.send(i, message);
    }
    catch (IOException e) {
      e.printStackTrace();
    }
  }

  public void messageReceived(int to, net.tinyos.message.Message m) {
    SensorMessage message = (SensorMessage)m;
    long t = System.currentTimeMillis();
    //    Date d = new Date(t);
    System.out.print("" + t + ": ");
    System.out.println(message);
    short seqNumber = message.get_seqNumber();
    short nodeid = message.get_nodeid();
    int[] temps = message.get_temperature();
    int[] hums = message.get_humidity();
    int[] lights = message.get_lightIntensity();
    long[] collectTimes = message.get_collectTime();
    for (int i = 0; i < 3; ++i){
      double temp = -38.4 + 0.0098 * temps[i];
      double hum = (temp - 25) * (0.01 + 8e-5 * hums[i]) - 28e-7 * hums[i] * hums[i] + 0.0405 * hums[i] - 4;
      double lx = (lights[i] * 6250 * 1.5 / 4096);
      int time = (int)collectTimes[i];
      mainWindow.getData(nodeid, time, temp, hum, lx);
      String record = String.format("%d %d %d %4.2f %4.2f %4.2f \n", nodeid, seqNumber, collectTimes[i], temp, hum, lx);
      try {
        this.writeToFile(record);
      }
      catch (IOException e) {
        e.printStackTrace();
      }
    }
  }

  private void writeToFile(String content) throws IOException{
    fileWriter = new FileWriter("result.txt", true);
    fileWriter.write(content);
    fileWriter.close();
  }

  private static void usage() {
    System.err.println("usage: MsgReader [-comm <source>] message-class [message-class ...]");
  }

  private void addMsgType(Message msg) {
    moteIF.registerListener(msg, this);
  }
  
  public static void main(String[] args) throws Exception {
    String source = null;
    Vector v = new Vector();
    if (args.length > 0) {
      for (int i = 0; i < args.length; i++) {
	if (args[i].equals("-comm")) {
	  source = args[++i];
	}
	else {
	  String className = args[i];
	  try {
	    Class c = Class.forName(className);
	    Object packet = c.newInstance();
	    Message msg = (Message)packet;
	    if (msg.amType() < 0) {
		System.err.println(className + " does not have an AM type - ignored");
	    }
	    else {
		v.addElement(msg);
	    }
	  }
	  catch (Exception e) {
	    System.err.println(e);
	  }
	}
      }
    }
    else if (args.length != 0) {
      usage();
      System.exit(1);
    }

    MsgReader mr = new MsgReader(source);
    Enumeration msgs = v.elements();
    while (msgs.hasMoreElements()) {
      Message m = (Message)msgs.nextElement();
      mr.addMsgType(m);
    }
    mr.start();
  }
}
