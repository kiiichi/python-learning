using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

using System.IO.Ports;

namespace IB_Exampls_CS
{
    public partial class MainForm : Form
    {

        private SerialPort comport = new SerialPort();

        public MainForm()
        {
            InitializeComponent();
            RescanPorts();
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

        private void btReadOnOffStatus_Click(object sender, EventArgs e)
        {
            byte tempData = 0;
            InterbusFunc.ibMsgType respType = InterbusFunc.ibMsgType.ibNONE;

            // Read register 0x30 - On/Off (byte)
            if (comport.IsOpen)
            {
                if (InterbusFunc.readInterbus_Byte(comport, (byte)nudDeviceId.Value, 0x30, ref respType, ref tempData))
                {
                    lbPwrOnOffStatus.Text = tempData.ToString();
                }
                else
                {
                    lbPwrOnOffStatus.ForeColor = Color.Red;  // Read failed!
                }
            }
        }

        private void btWriteOnOff_Click(object sender, EventArgs e)
        {
            InterbusFunc.ibMsgType respType = InterbusFunc.ibMsgType.ibNONE;

            // Write register 0x30 - On/Off (byte)
            if (comport.IsOpen)
            {
                if (InterbusFunc.writeInterbus_Byte(comport, (byte)nudDeviceId.Value, 0x30, ref respType, (byte)nudPwrOnOff.Value))
                {
                    nudPwrOnOff.ForeColor = SystemColors.ControlText;   // Write successfull
                }
                else
                {
                    nudPwrOnOff.ForeColor = Color.Red;  // Write failed!
                }
            }
        }

        private void trkbarPowerlevel_ValueChanged(object sender, EventArgs e)
        {
            lbPowerlevelSetting.Text = trkbarPowerlevel.Value.ToString();
        }

        private void btSetPowerlevel_Click(object sender, EventArgs e)
        {
            InterbusFunc.ibMsgType respType = InterbusFunc.ibMsgType.ibNONE;

            // Write register 0x37 - Power level (UInt16)
            if (comport.IsOpen)
            {
                if (InterbusFunc.writeInterbus_UInt16(comport, (byte)nudDeviceId.Value, 0x37, ref respType, (UInt16)trkbarPowerlevel.Value))
                {
                    lbPowerlevelSetting.ForeColor = SystemColors.ControlText;   // Write successfull
                }
                else
                {
                    lbPowerlevelSetting.ForeColor = Color.Red;  // Write failed!
                }
            }

        }

        private void btReadPowerlevel_Click(object sender, EventArgs e)
        {
            UInt16 tempData = 0;
            InterbusFunc.ibMsgType respType = InterbusFunc.ibMsgType.ibNONE;

            // Read register 0x37 - Power level status (UInt16)
            if (comport.IsOpen)
            {
                if (InterbusFunc.readInterbus_UInt16(comport, (byte)nudDeviceId.Value, 0x37, ref respType, ref tempData))
                {
                    lbPowerlevelStatus.Text = tempData.ToString();
                    probarPowerlevel.Value = tempData;
                }

            }

        }



    }
}
