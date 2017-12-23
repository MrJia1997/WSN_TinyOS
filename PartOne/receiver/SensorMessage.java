/**
 * This class is automatically generated by mig. DO NOT EDIT THIS FILE.
 * This class implements a Java interface to the 'SensorMessage'
 * message type.
 */

public class SensorMessage extends net.tinyos.message.Message {

    /** The default size of this message type in bytes. */
    public static final int DEFAULT_MESSAGE_SIZE = 34;

    /** The Active Message type associated with this message. */
    public static final int AM_TYPE = 85;

    /** Create a new SensorMessage of size 34. */
    public SensorMessage() {
        super(DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /** Create a new SensorMessage of the given data_length. */
    public SensorMessage(int data_length) {
        super(data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new SensorMessage with the given data_length
     * and base offset.
     */
    public SensorMessage(int data_length, int base_offset) {
        super(data_length, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new SensorMessage using the given byte array
     * as backing store.
     */
    public SensorMessage(byte[] data) {
        super(data);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new SensorMessage using the given byte array
     * as backing store, with the given base offset.
     */
    public SensorMessage(byte[] data, int base_offset) {
        super(data, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new SensorMessage using the given byte array
     * as backing store, with the given base offset and data length.
     */
    public SensorMessage(byte[] data, int base_offset, int data_length) {
        super(data, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new SensorMessage embedded in the given message
     * at the given base offset.
     */
    public SensorMessage(net.tinyos.message.Message msg, int base_offset) {
        super(msg, base_offset, DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new SensorMessage embedded in the given message
     * at the given base offset and length.
     */
    public SensorMessage(net.tinyos.message.Message msg, int base_offset, int data_length) {
        super(msg, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
    /* Return a String representation of this message. Includes the
     * message type name and the non-indexed field values.
     */
    public String toString() {
      String s = "Message <SensorMessage> \n";
      try {
        s += "  [nodeid=0x"+Long.toHexString(get_nodeid())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [interval=0x"+Long.toHexString(get_interval())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [seqNumber=0x"+Long.toHexString(get_seqNumber())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [collectTime=";
        for (int i = 0; i < 3; i++) {
          s += "0x"+Long.toHexString(getElement_collectTime(i) & 0xffffffff)+" ";
        }
        s += "]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [temperature=";
        for (int i = 0; i < 3; i++) {
          s += "0x"+Long.toHexString(getElement_temperature(i) & 0xffff)+" ";
        }
        s += "]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [humidity=";
        for (int i = 0; i < 3; i++) {
          s += "0x"+Long.toHexString(getElement_humidity(i) & 0xffff)+" ";
        }
        s += "]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [lightIntensity=";
        for (int i = 0; i < 3; i++) {
          s += "0x"+Long.toHexString(getElement_lightIntensity(i) & 0xffff)+" ";
        }
        s += "]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      return s;
    }

    // Message-type-specific access methods appear below.

    /////////////////////////////////////////////////////////
    // Accessor methods for field: nodeid
    //   Field type: short, unsigned
    //   Offset (bits): 0
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'nodeid' is signed (false).
     */
    public static boolean isSigned_nodeid() {
        return false;
    }

    /**
     * Return whether the field 'nodeid' is an array (false).
     */
    public static boolean isArray_nodeid() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'nodeid'
     */
    public static int offset_nodeid() {
        return (0 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'nodeid'
     */
    public static int offsetBits_nodeid() {
        return 0;
    }

    /**
     * Return the value (as a short) of the field 'nodeid'
     */
    public short get_nodeid() {
        return (short)getUIntBEElement(offsetBits_nodeid(), 8);
    }

    /**
     * Set the value of the field 'nodeid'
     */
    public void set_nodeid(short value) {
        setUIntBEElement(offsetBits_nodeid(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 'nodeid'
     */
    public static int size_nodeid() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 'nodeid'
     */
    public static int sizeBits_nodeid() {
        return 8;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: interval
    //   Field type: int, unsigned
    //   Offset (bits): 8
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'interval' is signed (false).
     */
    public static boolean isSigned_interval() {
        return false;
    }

    /**
     * Return whether the field 'interval' is an array (false).
     */
    public static boolean isArray_interval() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'interval'
     */
    public static int offset_interval() {
        return (8 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'interval'
     */
    public static int offsetBits_interval() {
        return 8;
    }

    /**
     * Return the value (as a int) of the field 'interval'
     */
    public int get_interval() {
        return (int)getUIntBEElement(offsetBits_interval(), 16);
    }

    /**
     * Set the value of the field 'interval'
     */
    public void set_interval(int value) {
        setUIntBEElement(offsetBits_interval(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'interval'
     */
    public static int size_interval() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'interval'
     */
    public static int sizeBits_interval() {
        return 16;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: seqNumber
    //   Field type: short, unsigned
    //   Offset (bits): 24
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'seqNumber' is signed (false).
     */
    public static boolean isSigned_seqNumber() {
        return false;
    }

    /**
     * Return whether the field 'seqNumber' is an array (false).
     */
    public static boolean isArray_seqNumber() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'seqNumber'
     */
    public static int offset_seqNumber() {
        return (24 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'seqNumber'
     */
    public static int offsetBits_seqNumber() {
        return 24;
    }

    /**
     * Return the value (as a short) of the field 'seqNumber'
     */
    public short get_seqNumber() {
        return (short)getUIntBEElement(offsetBits_seqNumber(), 8);
    }

    /**
     * Set the value of the field 'seqNumber'
     */
    public void set_seqNumber(short value) {
        setUIntBEElement(offsetBits_seqNumber(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 'seqNumber'
     */
    public static int size_seqNumber() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 'seqNumber'
     */
    public static int sizeBits_seqNumber() {
        return 8;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: collectTime
    //   Field type: long[], unsigned
    //   Offset (bits): 32
    //   Size of each element (bits): 32
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'collectTime' is signed (false).
     */
    public static boolean isSigned_collectTime() {
        return false;
    }

    /**
     * Return whether the field 'collectTime' is an array (true).
     */
    public static boolean isArray_collectTime() {
        return true;
    }

    /**
     * Return the offset (in bytes) of the field 'collectTime'
     */
    public static int offset_collectTime(int index1) {
        int offset = 32;
        if (index1 < 0 || index1 >= 3) throw new ArrayIndexOutOfBoundsException();
        offset += 0 + index1 * 32;
        return (offset / 8);
    }

    /**
     * Return the offset (in bits) of the field 'collectTime'
     */
    public static int offsetBits_collectTime(int index1) {
        int offset = 32;
        if (index1 < 0 || index1 >= 3) throw new ArrayIndexOutOfBoundsException();
        offset += 0 + index1 * 32;
        return offset;
    }

    /**
     * Return the entire array 'collectTime' as a long[]
     */
    public long[] get_collectTime() {
        long[] tmp = new long[3];
        for (int index0 = 0; index0 < numElements_collectTime(0); index0++) {
            tmp[index0] = getElement_collectTime(index0);
        }
        return tmp;
    }

    /**
     * Set the contents of the array 'collectTime' from the given long[]
     */
    public void set_collectTime(long[] value) {
        for (int index0 = 0; index0 < value.length; index0++) {
            setElement_collectTime(index0, value[index0]);
        }
    }

    /**
     * Return an element (as a long) of the array 'collectTime'
     */
    public long getElement_collectTime(int index1) {
        return (long)getUIntBEElement(offsetBits_collectTime(index1), 32);
    }

    /**
     * Set an element of the array 'collectTime'
     */
    public void setElement_collectTime(int index1, long value) {
        setUIntBEElement(offsetBits_collectTime(index1), 32, value);
    }

    /**
     * Return the total size, in bytes, of the array 'collectTime'
     */
    public static int totalSize_collectTime() {
        return (96 / 8);
    }

    /**
     * Return the total size, in bits, of the array 'collectTime'
     */
    public static int totalSizeBits_collectTime() {
        return 96;
    }

    /**
     * Return the size, in bytes, of each element of the array 'collectTime'
     */
    public static int elementSize_collectTime() {
        return (32 / 8);
    }

    /**
     * Return the size, in bits, of each element of the array 'collectTime'
     */
    public static int elementSizeBits_collectTime() {
        return 32;
    }

    /**
     * Return the number of dimensions in the array 'collectTime'
     */
    public static int numDimensions_collectTime() {
        return 1;
    }

    /**
     * Return the number of elements in the array 'collectTime'
     */
    public static int numElements_collectTime() {
        return 3;
    }

    /**
     * Return the number of elements in the array 'collectTime'
     * for the given dimension.
     */
    public static int numElements_collectTime(int dimension) {
      int array_dims[] = { 3,  };
        if (dimension < 0 || dimension >= 1) throw new ArrayIndexOutOfBoundsException();
        if (array_dims[dimension] == 0) throw new IllegalArgumentException("Array dimension "+dimension+" has unknown size");
        return array_dims[dimension];
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: temperature
    //   Field type: int[], unsigned
    //   Offset (bits): 128
    //   Size of each element (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'temperature' is signed (false).
     */
    public static boolean isSigned_temperature() {
        return false;
    }

    /**
     * Return whether the field 'temperature' is an array (true).
     */
    public static boolean isArray_temperature() {
        return true;
    }

    /**
     * Return the offset (in bytes) of the field 'temperature'
     */
    public static int offset_temperature(int index1) {
        int offset = 128;
        if (index1 < 0 || index1 >= 3) throw new ArrayIndexOutOfBoundsException();
        offset += 0 + index1 * 16;
        return (offset / 8);
    }

    /**
     * Return the offset (in bits) of the field 'temperature'
     */
    public static int offsetBits_temperature(int index1) {
        int offset = 128;
        if (index1 < 0 || index1 >= 3) throw new ArrayIndexOutOfBoundsException();
        offset += 0 + index1 * 16;
        return offset;
    }

    /**
     * Return the entire array 'temperature' as a int[]
     */
    public int[] get_temperature() {
        int[] tmp = new int[3];
        for (int index0 = 0; index0 < numElements_temperature(0); index0++) {
            tmp[index0] = getElement_temperature(index0);
        }
        return tmp;
    }

    /**
     * Set the contents of the array 'temperature' from the given int[]
     */
    public void set_temperature(int[] value) {
        for (int index0 = 0; index0 < value.length; index0++) {
            setElement_temperature(index0, value[index0]);
        }
    }

    /**
     * Return an element (as a int) of the array 'temperature'
     */
    public int getElement_temperature(int index1) {
        return (int)getUIntBEElement(offsetBits_temperature(index1), 16);
    }

    /**
     * Set an element of the array 'temperature'
     */
    public void setElement_temperature(int index1, int value) {
        setUIntBEElement(offsetBits_temperature(index1), 16, value);
    }

    /**
     * Return the total size, in bytes, of the array 'temperature'
     */
    public static int totalSize_temperature() {
        return (48 / 8);
    }

    /**
     * Return the total size, in bits, of the array 'temperature'
     */
    public static int totalSizeBits_temperature() {
        return 48;
    }

    /**
     * Return the size, in bytes, of each element of the array 'temperature'
     */
    public static int elementSize_temperature() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of each element of the array 'temperature'
     */
    public static int elementSizeBits_temperature() {
        return 16;
    }

    /**
     * Return the number of dimensions in the array 'temperature'
     */
    public static int numDimensions_temperature() {
        return 1;
    }

    /**
     * Return the number of elements in the array 'temperature'
     */
    public static int numElements_temperature() {
        return 3;
    }

    /**
     * Return the number of elements in the array 'temperature'
     * for the given dimension.
     */
    public static int numElements_temperature(int dimension) {
      int array_dims[] = { 3,  };
        if (dimension < 0 || dimension >= 1) throw new ArrayIndexOutOfBoundsException();
        if (array_dims[dimension] == 0) throw new IllegalArgumentException("Array dimension "+dimension+" has unknown size");
        return array_dims[dimension];
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: humidity
    //   Field type: int[], unsigned
    //   Offset (bits): 176
    //   Size of each element (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'humidity' is signed (false).
     */
    public static boolean isSigned_humidity() {
        return false;
    }

    /**
     * Return whether the field 'humidity' is an array (true).
     */
    public static boolean isArray_humidity() {
        return true;
    }

    /**
     * Return the offset (in bytes) of the field 'humidity'
     */
    public static int offset_humidity(int index1) {
        int offset = 176;
        if (index1 < 0 || index1 >= 3) throw new ArrayIndexOutOfBoundsException();
        offset += 0 + index1 * 16;
        return (offset / 8);
    }

    /**
     * Return the offset (in bits) of the field 'humidity'
     */
    public static int offsetBits_humidity(int index1) {
        int offset = 176;
        if (index1 < 0 || index1 >= 3) throw new ArrayIndexOutOfBoundsException();
        offset += 0 + index1 * 16;
        return offset;
    }

    /**
     * Return the entire array 'humidity' as a int[]
     */
    public int[] get_humidity() {
        int[] tmp = new int[3];
        for (int index0 = 0; index0 < numElements_humidity(0); index0++) {
            tmp[index0] = getElement_humidity(index0);
        }
        return tmp;
    }

    /**
     * Set the contents of the array 'humidity' from the given int[]
     */
    public void set_humidity(int[] value) {
        for (int index0 = 0; index0 < value.length; index0++) {
            setElement_humidity(index0, value[index0]);
        }
    }

    /**
     * Return an element (as a int) of the array 'humidity'
     */
    public int getElement_humidity(int index1) {
        return (int)getUIntBEElement(offsetBits_humidity(index1), 16);
    }

    /**
     * Set an element of the array 'humidity'
     */
    public void setElement_humidity(int index1, int value) {
        setUIntBEElement(offsetBits_humidity(index1), 16, value);
    }

    /**
     * Return the total size, in bytes, of the array 'humidity'
     */
    public static int totalSize_humidity() {
        return (48 / 8);
    }

    /**
     * Return the total size, in bits, of the array 'humidity'
     */
    public static int totalSizeBits_humidity() {
        return 48;
    }

    /**
     * Return the size, in bytes, of each element of the array 'humidity'
     */
    public static int elementSize_humidity() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of each element of the array 'humidity'
     */
    public static int elementSizeBits_humidity() {
        return 16;
    }

    /**
     * Return the number of dimensions in the array 'humidity'
     */
    public static int numDimensions_humidity() {
        return 1;
    }

    /**
     * Return the number of elements in the array 'humidity'
     */
    public static int numElements_humidity() {
        return 3;
    }

    /**
     * Return the number of elements in the array 'humidity'
     * for the given dimension.
     */
    public static int numElements_humidity(int dimension) {
      int array_dims[] = { 3,  };
        if (dimension < 0 || dimension >= 1) throw new ArrayIndexOutOfBoundsException();
        if (array_dims[dimension] == 0) throw new IllegalArgumentException("Array dimension "+dimension+" has unknown size");
        return array_dims[dimension];
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: lightIntensity
    //   Field type: int[], unsigned
    //   Offset (bits): 224
    //   Size of each element (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'lightIntensity' is signed (false).
     */
    public static boolean isSigned_lightIntensity() {
        return false;
    }

    /**
     * Return whether the field 'lightIntensity' is an array (true).
     */
    public static boolean isArray_lightIntensity() {
        return true;
    }

    /**
     * Return the offset (in bytes) of the field 'lightIntensity'
     */
    public static int offset_lightIntensity(int index1) {
        int offset = 224;
        if (index1 < 0 || index1 >= 3) throw new ArrayIndexOutOfBoundsException();
        offset += 0 + index1 * 16;
        return (offset / 8);
    }

    /**
     * Return the offset (in bits) of the field 'lightIntensity'
     */
    public static int offsetBits_lightIntensity(int index1) {
        int offset = 224;
        if (index1 < 0 || index1 >= 3) throw new ArrayIndexOutOfBoundsException();
        offset += 0 + index1 * 16;
        return offset;
    }

    /**
     * Return the entire array 'lightIntensity' as a int[]
     */
    public int[] get_lightIntensity() {
        int[] tmp = new int[3];
        for (int index0 = 0; index0 < numElements_lightIntensity(0); index0++) {
            tmp[index0] = getElement_lightIntensity(index0);
        }
        return tmp;
    }

    /**
     * Set the contents of the array 'lightIntensity' from the given int[]
     */
    public void set_lightIntensity(int[] value) {
        for (int index0 = 0; index0 < value.length; index0++) {
            setElement_lightIntensity(index0, value[index0]);
        }
    }

    /**
     * Return an element (as a int) of the array 'lightIntensity'
     */
    public int getElement_lightIntensity(int index1) {
        return (int)getUIntBEElement(offsetBits_lightIntensity(index1), 16);
    }

    /**
     * Set an element of the array 'lightIntensity'
     */
    public void setElement_lightIntensity(int index1, int value) {
        setUIntBEElement(offsetBits_lightIntensity(index1), 16, value);
    }

    /**
     * Return the total size, in bytes, of the array 'lightIntensity'
     */
    public static int totalSize_lightIntensity() {
        return (48 / 8);
    }

    /**
     * Return the total size, in bits, of the array 'lightIntensity'
     */
    public static int totalSizeBits_lightIntensity() {
        return 48;
    }

    /**
     * Return the size, in bytes, of each element of the array 'lightIntensity'
     */
    public static int elementSize_lightIntensity() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of each element of the array 'lightIntensity'
     */
    public static int elementSizeBits_lightIntensity() {
        return 16;
    }

    /**
     * Return the number of dimensions in the array 'lightIntensity'
     */
    public static int numDimensions_lightIntensity() {
        return 1;
    }

    /**
     * Return the number of elements in the array 'lightIntensity'
     */
    public static int numElements_lightIntensity() {
        return 3;
    }

    /**
     * Return the number of elements in the array 'lightIntensity'
     * for the given dimension.
     */
    public static int numElements_lightIntensity(int dimension) {
      int array_dims[] = { 3,  };
        if (dimension < 0 || dimension >= 1) throw new ArrayIndexOutOfBoundsException();
        if (array_dims[dimension] == 0) throw new IllegalArgumentException("Array dimension "+dimension+" has unknown size");
        return array_dims[dimension];
    }

}
