using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

using System.IO;
using System.IO.Ports;

namespace IB_Example_CS_Log
{
    public partial class MainForm : Form
    {

        private SerialPort comport = new SerialPort();

        public MainForm()
        {
            InitializeComponent();
        }


        public void RescanPorts()
        {
            cbbDevices.Items.Clear();
            cbbDevices.Items.AddRange(SerialPort.GetPortNames());
            if (cbbDevices.Items.Count > 0)
                cbbDevices.SelectedIndex = 0;
        }


        private void btRefresh_Click(object sender, EventArgs e)
        {
            RescanPorts();
        }


        private void btConnect_Click(object sender, EventArgs e)
        {
            if (comport.IsOpen)
            {
                comport.Handshake = Handshake.None;
                comport.Close();
                btRefresh.Enabled = true;
                cbbDevices.Enabled = true;
                btConnect.BackColor = SystemColors.Control;
                btConnect.Text = "Connect";

            }
            else
            {
                try
                {
                    comport.PortName = cbbDevices.Items[cbbDevices.SelectedIndex].ToString();
                    comport.BaudRate = 115200;
                    comport.Parity = Parity.None;
                    comport.StopBits = StopBits.Two;

                    comport.Handshake = Handshake.None;
                    comport.DtrEnable = true;
                    comport.RtsEnable = true;
                    comport.Open();
                }
                catch (Exception)
                {
                    //throw;
                }

                if (comport.IsOpen)
                {
                    btRefresh.Enabled = false;
                    cbbDevices.Enabled = false;
                    btConnect.BackColor = Color.ForestGreen;
                    btConnect.Text = "DisConnect";
                }
                else
                {
                    MessageBox.Show("Error opening port: " + cbbDevices.Items[cbbDevices.SelectedIndex].ToString(), "Error", MessageBoxButtons.OK);
                }

            }
        }


        private void btReadType_Click(object sender, EventArgs e)
        {
            byte[] tempData = new byte[240];
            InterbusFunc.ibMsgType respType = InterbusFunc.ibMsgType.ibNONE;

            // Read register 0x61 - Module type
            if (comport.IsOpen)
            {
                if (InterbusFunc.readInterbus_Stream(comport, (byte)nudDeviceId.Value, 0x61, ref respType, ref tempData))
                {
                    if (tempData.Length == 1)
                    {
                        lbTypeHex.ForeColor = SystemColors.ControlText;
                        lbTypeHex.Text = "0x" + tempData[0].ToString("X2");
                    }
                    else
                    {
                        lbTypeHex.ForeColor = Color.Red;
                        lbTypeHex.Text = "*";
                    }
                }
                else
                {
                    lbTypeHex.ForeColor = Color.Red;
                    lbTypeHex.Text = "*";
                }
            }

        }


        private void btReadVersion_Click(object sender, EventArgs e)
        {
            byte[] tempData = new byte[240];
            InterbusFunc.ibMsgType respType = InterbusFunc.ibMsgType.ibNONE;

            // Read register 0x64 - Version (Int16 + Ascii string)
            if (comport.IsOpen)
            {
                if (InterbusFunc.readInterbus_Stream(comport, (byte)nudDeviceId.Value, 0x64, ref respType, ref tempData))
                {
                    if (tempData.Length > 1)
                    {
                        lbVerInt.ForeColor = SystemColors.ControlText;
                        lbVerInt.Text = (BitConverter.ToUInt16(tempData, 0) / 100.0).ToString("#0.00");
                    }
                    else
                    {
                        lbVerInt.ForeColor = Color.Red;
                        lbVerInt.Text = "*";
                    }

                    if (tempData.Length > 2)
                    {
                        lbVerStr.ForeColor = SystemColors.ControlText;
                        lbVerStr.Text = Encoding.UTF8.GetString(tempData, 2, tempData.Length - 2);
                    }
                    else
                    {
                        lbVerStr.ForeColor = Color.Red;
                        lbVerStr.Text = "*";
                    }

                }
                else
                {
                    lbVerInt.ForeColor = Color.Red;
                    lbVerInt.Text = "*";
                    lbVerStr.ForeColor = Color.Red;
                    lbVerStr.Text = "*";
                }
            }
        }


        private void btReadLogStatus_Click(object sender, EventArgs e)
        {
            UInt32 totalEntries = 0;
            InterbusFunc.ibMsgType respType = InterbusFunc.ibMsgType.ibNONE;

            // Read register 0x84 - Number of log entries present.
            if (comport.IsOpen)
            {
                if (InterbusFunc.readInterbus_UInt32(comport, (byte)nudDeviceId.Value, 0x84, ref respType, ref totalEntries))
                {
                    nudTotalEntries.Value = totalEntries;

                    if (nudStartIndex.Value > totalEntries)
                        nudStartIndex.Value = totalEntries - 1;
                    nudStartIndex.Maximum = totalEntries - 1;

                    btGetBinaryLog.Enabled = true;
                }
            }
        }


        private void btGetBinaryLog_Click(object sender, EventArgs e)
        {
            String logFilename;

            // Displays a SaveFileDialog so the user can save the log  
            SaveFileDialog saveFileDialog1 = new SaveFileDialog();
            saveFileDialog1.Filter = "Binary log|*.bin";
            saveFileDialog1.Title = "Save binary log";

            if (saveFileDialog1.ShowDialog() == DialogResult.OK)
            {
                logFilename = saveFileDialog1.FileName;

                // Delete the file if it exists.
                if (File.Exists(logFilename))
                {
                    File.Delete(logFilename);
                }

                using (FileStream fs = File.Create(logFilename))
                {
                    groupBoxComport.Enabled = false;
                    groupBoxDevData.Enabled = false;
                    btReadLogStatus.Enabled = false;
                    btAbortBinaryLog.Enabled = true;
                    btGetBinaryLog.Enabled = false;

                    saveBinaryLog(fs, (UInt32)nudStartIndex.Value, (UInt32)nudTotalEntries.Value - 1);

                    groupBoxComport.Enabled = true;
                    groupBoxDevData.Enabled = true;
                    btReadLogStatus.Enabled = true;
                    btAbortBinaryLog.Enabled = false;
                    btGetBinaryLog.Enabled = true;

                }

            }
        }


        enum binLogStates
        {
            setIndex,
            getLogEntry,
            completed,
            failed

        };

        private bool abortBinaryDownload;

        private bool saveBinaryLog(FileStream fs, UInt32 startIndex, UInt32 lastIndex)
        {
            binLogStates state = binLogStates.setIndex;
            byte retryCounter = 10;
            InterbusFunc.ibMsgType respType = InterbusFunc.ibMsgType.ibNONE;
            byte[] logData;
            UInt32 logPointer = startIndex;
            UInt32 busyCount = 0;

            abortBinaryDownload = false;
            while (!abortBinaryDownload && state != binLogStates.completed && state != binLogStates.failed)
            {

                switch (state)
                {
                    case binLogStates.setIndex:

                        if (InterbusFunc.writeInterbus_UInt32(comport, (byte)nudDeviceId.Value, 0x8F, ref respType, logPointer))
                        {
                            // Index successfully set
                            retryCounter = 10;  // Reset retry counter

                            state = binLogStates.getLogEntry;
                        }
                        else
                        {
                            if (respType == InterbusFunc.ibMsgType.ibBusy)
                            {
                                // Retry on busy - Stay in state and retry
                                busyCount++;

                                nudBusyCount.Value = busyCount;
                            }
                            else if (respType == InterbusFunc.ibMsgType.ibNack)
                            {
                                // Abort on nacks
                                state = binLogStates.failed;
                            }
                            else
                            {
                                // Retry on all other errors
                                if (retryCounter > 0)
                                    retryCounter--;   // Update the retry counter and retry.
                                else
                                    state = binLogStates.failed;    // To many errors
                            }
                        }
                        break;

                    case binLogStates.getLogEntry:
                        respType = 0;
                        logData = new byte[240];
                        if (InterbusFunc.readInterbus_Stream(comport, (byte)nudDeviceId.Value, 0x87, ref respType, ref logData))
                        {
                            // Log entry successfully read
                            retryCounter = 10;  // Reset retry counter

                            fs.Write(logData, 0, logData.Length);

                            if (logPointer < lastIndex)
                                logPointer++; // Update the index
                            else
                                state = binLogStates.completed;

                            nudCurrentIndex.Value = logPointer;
                        }
                        else
                        {
                            if (respType == InterbusFunc.ibMsgType.ibBusy)
                            {
                                // Retry on busy - Stay in state and retry
                                busyCount++;

                                nudBusyCount.Value = busyCount;
                            }
                            else if (respType == InterbusFunc.ibMsgType.ibNack)
                            {
                                // Abort on nacks
                                state = binLogStates.failed;
                            }
                            else
                            {
                                // On all other errors, we restart by setting the index again
                                if (retryCounter > 0)
                                {
                                    retryCounter--;   // Update the retry counter and retry.
                                    state = binLogStates.setIndex;
                                }
                                else
                                    state = binLogStates.failed;    // To many errors
                            }
                        }
                        break;

                    case binLogStates.completed:
                    case binLogStates.failed:
                        break;
                    default:
                        state = binLogStates.setIndex;
                        break;
                }
                Application.DoEvents();
            }
            return (state == binLogStates.completed);
        }

        private void btAbortBinaryLog_Click(object sender, EventArgs e)
        {
            abortBinaryDownload = true;
        }
    }
}