import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.util.Vector;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.swing.table.DefaultTableModel;
import javax.swing.text.AttributeSet;
import javax.swing.text.BadLocationException;
import javax.swing.text.PlainDocument;

class tosData {
    public int nodeid;
    public int time;
    public double temp;
    public double hum;
    public double light;
}

class MyRegExp extends PlainDocument {
    private Pattern pattern;
    private Matcher m;
    public MyRegExp(String pat) {
        super();
        this.pattern = Pattern.compile(pat);
    }
    @Override
    public void insertString(int offset, String str, AttributeSet attr) throws BadLocationException{
        if (str == null) {
            return;
        }
        String tmp = getText(0, offset).concat(str);
        m = pattern.matcher(tmp);
        if (m.matches())
            super.insertString(offset, str, attr);
    }
}

public class MainWindow extends JFrame {
    private enum dataType{
        temp,
        hum,
        light
    }
    private Vector<tosData> totalData;
    private tosData[] showData;
    private int dataLength;
    private JPanel tempPaintPanel;
    private JPanel humPaintPanel;
    private JPanel lightPaintPanel;
    private JTable dataTable;
    private boolean showNode1;
    private boolean showNode2;
    private JTextArea displayInput;
    private JTextArea sendInput;
    private JButton okButton;
    private JButton resetButton;
    private int sendTime;
    private int displayNumber;
    final int xLength = 380;
    final int yLength = 380;
    private JCheckBoxMenuItem selectNode1;
    private JCheckBoxMenuItem selectNode2;
    final private String[] columnNames = {"节点号","时间","温度","湿度","光照强度"};
    private CallBack callBack;
    public MainWindow(String title) {
        super(title);
        this.totalData = new Vector<tosData>();
        this.showData = new tosData[200];
        this.dataLength = 0;
        this.showNode1 = true;
        this.showNode2 = true;
        this.sendTime = 200;
        this.displayNumber = 10;
        this.setBounds(200, 200, 500, 500);
        this.setResizable(false);
        Container contentPane = this.getContentPane();
        JTabbedPane tabbedPanel = new JTabbedPane();
        JPanel chartPanel1 = new JPanel(new GridLayout());
        JMenuBar menuBar = new JMenuBar();
        JMenu menu = new JMenu("数据");
        this.selectNode1 = new JCheckBoxMenuItem("节点一");
        this.selectNode2 = new JCheckBoxMenuItem("节点二");
        menu.add(this.selectNode1);
        menu.add(this.selectNode2);
        this.selectNode1.setSelected(true);
        this.selectNode2.setSelected(true);
        menuBar.add(menu);
        this.setJMenuBar(menuBar);
        this.tempPaintPanel = new JPanel() {
          public void paint(Graphics g) {
              super.paint(g);
              g.setColor(Color.gray);
              for (int i = 100; i <= 480; i += 30) {
                  g.drawLine(i, 0, i, 380);
              }
              for (int i = 0; i <= 380; i += 20) {
                  g.drawLine(100, i, 480, i);
              }
              draw(g, dataType.temp);
          }
        };
        this.humPaintPanel = new JPanel() {
            public void paint(Graphics g) {
                super.paint(g);
                g.setColor(Color.gray);
                for (int i = 100; i <= 480; i += 30) {
                    g.drawLine(i, 0, i, 380);
                }
                for (int i = 0; i <= 380; i += 20) {
                    g.drawLine(100, i, 480, i);
                }
                draw(g, dataType.hum);
            }
        };
        this.lightPaintPanel = new JPanel() {
            public void paint(Graphics g) {
                super.paint(g);
                g.setColor(Color.gray);
                for (int i = 100; i <= 480; i += 30) {
                    g.drawLine(i, 0, i, 380);
                }
                for (int i = 0; i <= 380; i += 20) {
                    g.drawLine(100, i, 480, i);
                }
                draw(g, dataType.light);
            }
        };
        JScrollPane tablePanel = new JScrollPane();
        DefaultTableModel model = new DefaultTableModel(null, this.columnNames) {
            public boolean isCellEditable(int row, int column) {
                return false;
            }
        };
        this.dataTable = new JTable(model);
        tablePanel.getViewport().add(this.dataTable);
        //this.dataTable.setFillsViewportHeight(true);
        JPanel confPanel = new JPanel();
        confPanel.setLayout(null);
        JLabel sendLabel = new JLabel("发送时间间隔(ms)");
        sendLabel.setBounds(80, 50, 120, 30);
        this.sendInput = new JTextArea();
        this.sendInput.setDocument(new MyRegExp("\\d*"));
        Font f = new Font(null, Font.PLAIN, 25);
        this.sendInput.setBounds(200, 50, 200, 30);
        this.sendInput.setFont(f);
        JLabel displayLabel = new JLabel("单屏数据点数(个)");
        displayLabel.setBounds(80, 150, 120, 30);
        this.displayInput = new JTextArea();
        this.displayInput.setDocument(new MyRegExp("\\d*"));
        this.displayInput.setBounds(200, 150, 200, 30);
        this.displayInput.setFont(f);
        this.okButton = new JButton("确定");
        this.okButton.setBounds(150, 250, 80, 30);
        this.resetButton = new JButton("重置");
        this.resetButton.setBounds(250, 250, 80, 30);
        confPanel.add(sendLabel);
        confPanel.add(this.sendInput);
        confPanel.add(displayLabel);
        confPanel.add(this.displayInput);
        confPanel.add(this.okButton);
        confPanel.add(this.resetButton);
        tabbedPanel.addTab("数据", tablePanel);
        tabbedPanel.addTab("温度", this.tempPaintPanel);
        tabbedPanel.addTab("湿度", this.humPaintPanel);
        tabbedPanel.addTab("光照强度", this.lightPaintPanel);
        tabbedPanel.addTab("设置", confPanel);
        this.selectNode1.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                showNode1 = selectNode1.isSelected();
                humPaintPanel.repaint();
                tempPaintPanel.repaint();
                lightPaintPanel.repaint();
            }
        });
        this.selectNode2.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                showNode2 = selectNode2.isSelected();
                humPaintPanel.repaint();
                tempPaintPanel.repaint();
                lightPaintPanel.repaint();
            }
        });
        this.okButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                updateConfigure();
            }
        });
        this.resetButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                resetConfigure();
            }
        });
        contentPane.add(tabbedPanel);
        this.displayInput.setText("10");
        this.sendInput.setText("200");
        this.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        this.setVisible(true);
    }
    private void addTableLine(tosData td) {
        DefaultTableModel model = (DefaultTableModel) this.dataTable.getModel();
        String[] newRow = new String[5];
        newRow[0] = Integer.toString(td.nodeid);
        newRow[1] = Integer.toString(td.time);
        newRow[2] = String.format("%4.2f", td.temp);
        newRow[3] = String.format("%4.2f", td.hum);
        newRow[4] = String.format("%4.2f", td.light);
        model.addRow(newRow);
    }
    private Color getColor(int nodeid) {
        if (nodeid == 1) {
            return Color.BLUE;
        } else {
            return Color.RED;
        }
    }
    private void drawLine(int nodeid, int[] timeList, double[] dataList, double dmin, double dmax, int totaltime, Graphics g) {
        g.setColor(this.getColor(nodeid));
        Graphics2D g2d = (Graphics2D)g;
        BasicStroke stroke = new BasicStroke(3);
        g2d.setStroke(stroke);
        int[] xs = new int[this.displayNumber];
        int[] ys = new int[this.displayNumber];
        for (int i = 0; i < this.displayNumber; ++i) {
            xs[i] = (timeList[i] - timeList[0]) * this.xLength / totaltime + 100;
            ys[i] = 380 - (int)((dataList[i] - dmin) * this.yLength / (dmax - dmin));
            g2d.fillOval(xs[i] - 3, ys[i] - 3, 6, 6);
        }
        for (int i = 0; i < this.displayNumber - 1; ++i) {
            g2d.drawLine(xs[i], ys[i], xs[i + 1], ys[i + 1]);
        }
    }
    private void drawImage(int[] timeList1, int[] timeList2, double[] dataList1, double[] dataList2, int len, Graphics g) {
        if (timeList1 == null && timeList2 == null)
            return;
        if (len < 2)
            return;
        Graphics2D g2d = (Graphics2D)g;
        int tmax = 0, tmin = 0;
        if (timeList1 != null) {
            tmax = timeList1[len - 1];
            tmin = timeList1[0];
        }
        if (timeList2 != null) {
            tmax = timeList2[len - 1];
            tmin = timeList2[0];
        }
        if (timeList1 != null && timeList2 != null){
            tmax = timeList1[len - 1] > timeList2[len - 1] ? timeList1[len - 1] : timeList2[len - 1];
            tmin = timeList1[0] > timeList2[0] ? timeList2[0] : timeList1[0];
        }
        int totalTime = tmax - tmin;
        double dmin = Double.MAX_VALUE;
        double dmax = Double.MIN_VALUE;
        if (dataList1 != null) {
            for (int i = 0; i < len; ++i) {
                if (dataList1[i] < dmin) {
                    dmin = dataList1[i];
                }
                if (dataList1[i] > dmax) {
                    dmax = dataList1[i];
                }
            }
        }
        if (dataList2 != null) {
            for (int i = 0; i < len; ++i) {
                if (dataList2[i] < dmin) {
                    dmin = dataList2[i];
                }
                if (dataList2[i] > dmax) {
                    dmax = dataList2[i];
                }
            }
        }
        if (dmax - dmin < 2){
            dmax = dmax + 1;
            dmin = dmin - 1;
        }
        for (int i = 0; i < 11; ++i) {
            g2d.drawString(Integer.toString((int)(0.1 * i * dmin + 0.1 * (10 - i) * dmax)), 50,38 * i);
            g2d.drawString(Integer.toString((int)(0.1 * i * tmin + 0.1 * (10 - i) * tmax)), 480 - 38 * i, 400);
        }
        if (this.showNode1) {
            g2d.setColor(this.getColor(1));
            g2d.drawString("节点一", 0, 50);
            this.drawLine(1, timeList1, dataList1, dmin, dmax, totalTime, g);
        }
        if (this.showNode2) {
            g2d.setColor(this.getColor(2));
            g2d.drawString("节点二", 0, 100);
            this.drawLine(2, timeList2, dataList2, dmin, dmax, totalTime, g);
        }
    }
    private void draw(Graphics g, dataType dt){
        boolean dataFilled = true;
        int len = this.totalData.size() / 2;
        int len1 = 0, len2 = 0;
        if (len < this.displayNumber) {
            len1 = len2 = len;
        } else {
            len1 = len2 = this.displayNumber;
        }
        len = len1;
        if (!this.showNode1) {
            len1 = 0;
            len = len2;
        }
        if (!this.showNode2) {
            len2 = 0;
            len = len1;
        }
        int pos = this.totalData.size();
        int[] timeList1 = new int[len1];
        int[] timeList2 = new int[len2];
        double[] dataList1 = new double[len1];
        double[] dataList2 = new double[len2];
        if (!this.showNode1) {
            timeList1 = null;
            dataList1 = null;
        }
        if (!this.showNode2) {
            timeList2 = null;
            dataList2 = null;
        }
        while (len1 != 0 || len2 != 0) {
            --pos;
            if (pos < 0){
                break;
            }
            tosData curr = this.totalData.get(pos);
            if (curr.nodeid == 1) {
                --len1;
                if (len1 < 0 || !this.showNode1)
                    continue;
                timeList1[len1] = curr.time;
                switch (dt) {
                    case temp:
                        dataList1[len1] = curr.temp;
                        break;
                    case hum:
                        dataList1[len1] = curr.hum;
                        break;
                    case light:
                        dataList1[len1] = curr.light;
                        break;
                }
            } else {
                --len2;
                if (len2 < 0 || !this.showNode2)
                    continue;
                timeList2[len2] = curr.time;
                switch (dt) {
                    case temp:
                        dataList2[len2] = curr.temp;
                        break;
                    case hum:
                        dataList2[len2] = curr.hum;
                        break;
                    case light:
                        dataList2[len2] = curr.light;
                        break;
                }
            }
        }
        this.drawImage(timeList1, timeList2, dataList1, dataList2, len, g);
    }
    private void updateConfigure(){
        this.sendTime = Integer.parseInt(this.sendInput.getText());
        this.displayNumber = Integer.parseInt(this.displayInput.getText());
        this.humPaintPanel.repaint();
        this.tempPaintPanel.repaint();
        this.lightPaintPanel.repaint();
        if (callBack != null)
            callBack.run();
    }
    private void resetConfigure() {
        this.sendTime = 200;
        this.displayNumber = 10;
        this.sendInput.setText("200");
        this.displayInput.setText("10");
        this.humPaintPanel.repaint();
        this.tempPaintPanel.repaint();
        this.lightPaintPanel.repaint();
        if (callBack != null)
            callBack.run();
    }
    public int getSendTime() {
        return this.sendTime;
    }
    public void getData(int nodeid, int time, double temp, double hum, double light) {
        tosData newData = new tosData();
        newData.nodeid = nodeid;
        newData.time = time;
        newData.temp = temp;
        newData.hum = hum;
        newData.light = light;
        if (totalData.size() == 400) {
            totalData.remove(0);
        }
        totalData.add(newData);
        this.humPaintPanel.repaint();
        this.tempPaintPanel.repaint();
        this.lightPaintPanel.repaint();
        this.addTableLine(newData);
    }
    public void setCallBack(CallBack cb) {
        this.callBack = cb;
    }
    static public void  main(String[] args) {
        MainWindow mw = new MainWindow("tiny OS 数据测量");
        for (int i = 0; i < 100; ++i){
            mw.getData(1,i,i,i,i);
            mw.getData(2,i,100 - i,100 - i,100 - i);
        }
    }
}
