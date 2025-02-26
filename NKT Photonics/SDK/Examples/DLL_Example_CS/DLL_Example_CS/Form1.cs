using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using NKTP;

namespace DLL_Example_CS
{
    public partial class Form1 : Form
    {

        public Form1()
        {
            InitializeComponent();

            // Assure the protocol combobox has the default selection
            P2PPortAddProtocol.SelectedIndex = 1;
        }

        /*******************************************************************************************************
         * Misc. helpers
         *******************************************************************************************************/

        private void ShowPortResultTypes(string funcName, NKTPDLL.PortResultTypes result)
        {
            StatusTextBox.AppendText("\r\n" + funcName + ": " + NKTPDLL.getPortResultMsg(result));
        }


        private void ShowP2PPortResultTypes(string funcName, NKTPDLL.P2PPortResultTypes result)
        {
            StatusTextBox.AppendText("\r\n" + funcName + ": " + NKTPDLL.getP2PPortResultMsg(result));
        }


        private void ShowRegisterResultTypes(string funcName, NKTPDLL.RegisterResultTypes result)
        {
            StatusTextBox.AppendText("\r\n" + funcName + ": " + NKTPDLL.getRegisterResultMsg(result));
        }


        private void ShowDeviceResultTypes(string funcName, NKTPDLL.DeviceResultTypes result)
        {
            StatusTextBox.AppendText("\r\n" + funcName + ": " + NKTPDLL.getDeviceResultMsg(result));
        }


        /*******************************************************************************************************
         * Button handlers
         *******************************************************************************************************/


        private void GetAllPorts_Click(object sender, EventArgs e)
        {
            ushort maxLen = 400;
            StringBuilder portNames = new StringBuilder(maxLen);
            NKTPDLL.getAllPorts(portNames, ref maxLen);

            StatusTextBox.AppendText("\r\n" + "getAllPorts: " + portNames);

        }

        private void GetOpenPorts_Click(object sender, EventArgs e)
        {
            ushort maxLen = 400;
            StringBuilder openPortNames = new StringBuilder(maxLen);
            NKTPDLL.getOpenPorts(openPortNames, ref maxLen);

            StatusTextBox.AppendText("\r\n" + "getOpenPorts: " + openPortNames);

        }

        private void OpenPorts_Click(object sender, EventArgs e)
        {
            byte autoMode = 0;
            if  (checkBoxAutoMode.Checked) autoMode = 1;
            byte liveMode = 0;
            if (checkBoxLiveMode.Checked) liveMode = 1;
            string portNames = openPortsPortname.Text;
            NKTPDLL.PortResultTypes result = NKTPDLL.openPorts(portNames, autoMode, liveMode);
            ShowPortResultTypes("openPorts(\"" + portNames + "\", " + autoMode.ToString() + ", " + liveMode.ToString() + ")", result);
        }

        private void ClosePorts_Click(object sender, EventArgs e)
        {
            string portNames = closePortsPortname.Text;
            NKTPDLL.PortResultTypes result = NKTPDLL.closePorts(portNames);
            ShowPortResultTypes("closePorts(\"" + portNames + "\")", result);
        }

        private void PointToPointPortAdd_Click(object sender, EventArgs e)
        {
            string portName = P2PPortAddName.Text;
            string hostAddr = P2PPortAddHostIP.Text;
            int hostPort;
            string clientAddr = P2PPortAddClientIP.Text;
            int clientPort;
            int protocol;
            int timeout;

            if (!Int32.TryParse(P2PPortAddHostPort.Text, out hostPort))
                hostPort = 0;
            if (!Int32.TryParse(P2PPortAddClientPort.Text, out clientPort))
                clientPort = 0;
            if (P2PPortAddProtocol.SelectedIndex >= 0)
                protocol = P2PPortAddProtocol.SelectedIndex;
            else
                protocol = 0;
            if (!Int32.TryParse(P2PPortAddTimeout.Text, out timeout))
                timeout = 0;

            NKTPDLL.P2PPortResultTypes result = NKTPDLL.pointToPointPortAdd(portName, hostAddr, (ushort)hostPort, clientAddr, (ushort)clientPort, (byte)protocol, (byte)timeout);
            ShowP2PPortResultTypes("pointToPointPortAdd(\"" + portName + "\", \"" + hostAddr + "\", " + hostPort.ToString() + ", \"" + clientAddr + "\", " + clientPort.ToString() + ", " + protocol.ToString() + ", " + timeout.ToString(), result);

        }

        private void pointToPointPortGet_Click(object sender, EventArgs e)
        {
            string portName = P2PPortGetName.Text;

            byte hostAddrMax = 255;
            StringBuilder hostAddr = new StringBuilder(hostAddrMax);
            ushort hostPort = 0;

            byte clientAddrMax = 255;
            StringBuilder clientAddr = new StringBuilder(clientAddrMax);
            ushort clientPort = 0;

            byte protocol = 0;
            byte timeout = 0;

            NKTPDLL.P2PPortResultTypes result = NKTPDLL.pointToPointPortGet(portName, hostAddr, ref hostAddrMax, ref hostPort, clientAddr, ref clientAddrMax, ref clientPort, ref protocol, ref timeout);
            ShowP2PPortResultTypes("pointToPointPortGet(\"" + portName + "\", \"" + hostAddr + "\", " + hostPort.ToString() + ", \"" + clientAddr + "\", " + clientPort.ToString() + ", " + protocol.ToString() + ", " + timeout.ToString(), result);

            P2PPortGetHostIP.Text = hostAddr.ToString();
            P2PPortGetHostPort.Text = hostPort.ToString();
            P2PPortGetClientIP.Text = clientAddr.ToString();
            P2PPortGetClientPort.Text = clientPort.ToString();
            P2PPortGetProtocol.SelectedIndex = protocol;
            P2PPortGetTimeout.Text = timeout.ToString();                

        }

        private void pointToPointPortDel_Click(object sender, EventArgs e)
        {
            string portName = P2PPortDelName.Text;

            NKTPDLL.P2PPortResultTypes result = NKTPDLL.pointToPointPortDel(portName);
            ShowP2PPortResultTypes("pointToPointPortDel(\"" + portName + "\")", result);

        }



        private void ExitButton_Click(object sender, EventArgs e)
        {
            System.Windows.Forms.Application.Exit();
        }

        //------------------------------------------------------------------------------------------------------
        // Dedicated - Register read functions
        //------------------------------------------------------------------------------------------------------

        private void registerReadU8_Click(object sender, EventArgs e)
        {
            string portName = registerReadPortname.Text;
            byte devId = Convert.ToByte(registerReadDevId.Value);
            byte regId = Convert.ToByte(registerReadRegId.Value);
            byte value = 0;
            Int16 index = Convert.ToInt16(registerReadIndex.Value);

            NKTPDLL.RegisterResultTypes result = NKTPDLL.registerReadU8(portName, devId, regId, ref value, index);
            ShowRegisterResultTypes("registerReadU8(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + 0 + ", " + index.ToString() + ") : " + value.ToString(), result);

        }

        private void registerReadS8_Click(object sender, EventArgs e)
        {
            string portName = registerReadPortname.Text;
            byte devId = Convert.ToByte(registerReadDevId.Value);
            byte regId = Convert.ToByte(registerReadRegId.Value);
            sbyte value = 0;
            Int16 index = Convert.ToInt16(registerReadIndex.Value);

            NKTPDLL.RegisterResultTypes result = NKTPDLL.registerReadS8(portName, devId, regId, ref value, index);
            ShowRegisterResultTypes("registerReadS8(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + 0 + ", " + index.ToString() + ") : " + value.ToString(), result);

        }

        private void registerReadU16_Click(object sender, EventArgs e)
        {
            string portName = registerReadPortname.Text;
            byte devId = Convert.ToByte(registerReadDevId.Value);
            byte regId = Convert.ToByte(registerReadRegId.Value);
            UInt16 value = 0;
            Int16 index = Convert.ToInt16(registerReadIndex.Value);

            NKTPDLL.RegisterResultTypes result = NKTPDLL.registerReadU16(portName, devId, regId, ref value, index);
            ShowRegisterResultTypes("registerReadU16(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + 0 + ", " + index.ToString() + ") : " + value.ToString(), result);

        }

        private void registerReadS16_Click(object sender, EventArgs e)
        {
            string portName = registerReadPortname.Text;
            byte devId = Convert.ToByte(registerReadDevId.Value);
            byte regId = Convert.ToByte(registerReadRegId.Value);
            Int16 value = 0;
            Int16 index = Convert.ToInt16(registerReadIndex.Value);

            NKTPDLL.RegisterResultTypes result = NKTPDLL.registerReadS16(portName, devId, regId, ref value, index);
            ShowRegisterResultTypes("registerReadS16(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + 0 + ", " + index.ToString() + ") : " + value.ToString(), result);

        }

        private void registerReadU32_Click(object sender, EventArgs e)
        {
            string portName = registerReadPortname.Text;
            byte devId = Convert.ToByte(registerReadDevId.Value);
            byte regId = Convert.ToByte(registerReadRegId.Value);
            UInt32 value = 0;
            Int16 index = Convert.ToInt16(registerReadIndex.Value);

            NKTPDLL.RegisterResultTypes result = NKTPDLL.registerReadU32(portName, devId, regId, ref value, index);
            ShowRegisterResultTypes("registerReadU32(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + 0 + ", " + index.ToString() + ") : " + value.ToString(), result);

        }

        private void registerReadS32_Click(object sender, EventArgs e)
        {
            string portName = registerReadPortname.Text;
            byte devId = Convert.ToByte(registerReadDevId.Value);
            byte regId = Convert.ToByte(registerReadRegId.Value);
            Int32 value = 0;
            Int16 index = Convert.ToInt16(registerReadIndex.Value);

            NKTPDLL.RegisterResultTypes result = NKTPDLL.registerReadS32(portName, devId, regId, ref value, index);
            ShowRegisterResultTypes("registerReadS32(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + 0 + ", " + index.ToString() + ") : " + value.ToString(), result);

        }

        private void registerReadU64_Click(object sender, EventArgs e)
        {
            string portName = registerReadPortname.Text;
            byte devId = Convert.ToByte(registerReadDevId.Value);
            byte regId = Convert.ToByte(registerReadRegId.Value);
            UInt64 value = 0;
            Int16 index = Convert.ToInt16(registerReadIndex.Value);

            NKTPDLL.RegisterResultTypes result = NKTPDLL.registerReadU64(portName, devId, regId, ref value, index);
            ShowRegisterResultTypes("registerReadU64(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + 0 + ", " + index.ToString() + ") : " + value.ToString(), result);

        }

        private void registerReadS64_Click(object sender, EventArgs e)
        {
            string portName = registerReadPortname.Text;
            byte devId = Convert.ToByte(registerReadDevId.Value);
            byte regId = Convert.ToByte(registerReadRegId.Value);
            Int64 value = 0;
            Int16 index = Convert.ToInt16(registerReadIndex.Value);

            NKTPDLL.RegisterResultTypes result = NKTPDLL.registerReadS64(portName, devId, regId, ref value, index);
            ShowRegisterResultTypes("registerReadS64(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + 0 + ", " + index.ToString() + ") : " + value.ToString(), result);

        }

        private void registerReadF32_Click(object sender, EventArgs e)
        {
            string portName = registerReadPortname.Text;
            byte devId = Convert.ToByte(registerReadDevId.Value);
            byte regId = Convert.ToByte(registerReadRegId.Value);
            float value = 0;
            Int16 index = Convert.ToInt16(registerReadIndex.Value);

            NKTPDLL.RegisterResultTypes result = NKTPDLL.registerReadF32(portName, devId, regId, ref value, index);
            ShowRegisterResultTypes("registerReadF32(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + 0 + ", " + index.ToString() + ") : " + value.ToString(), result);

        }

        private void registerReadF64_Click(object sender, EventArgs e)
        {
            string portName = registerReadPortname.Text;
            byte devId = Convert.ToByte(registerReadDevId.Value);
            byte regId = Convert.ToByte(registerReadRegId.Value);
            double value = 0;
            Int16 index = Convert.ToInt16(registerReadIndex.Value);

            NKTPDLL.RegisterResultTypes result = NKTPDLL.registerReadF64(portName, devId, regId, ref value, index);
            ShowRegisterResultTypes("registerReadF64(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + 0 + ", " + index.ToString() + ") : " + value.ToString(), result);

        }

        private void registerReadAscii_Click(object sender, EventArgs e)
        {
            string portName = registerReadPortname.Text;
            byte devId = Convert.ToByte(registerReadDevId.Value);
            byte regId = Convert.ToByte(registerReadRegId.Value);
            byte maxLen = 255;
            StringBuilder value = new StringBuilder(maxLen);
            Int16 index = Convert.ToInt16(registerReadIndex.Value);

            NKTPDLL.RegisterResultTypes result = NKTPDLL.registerReadAscii(portName, devId, regId, value, ref maxLen, index);
            ShowRegisterResultTypes("registerReadAscii(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + "\"\"" + ", " + index.ToString() + ") : " + value.ToString(), result);

        }

       //------------------------------------------------------------------------------------------------------
       // Dedicated - Register write functions
       //------------------------------------------------------------------------------------------------------

        private void registerWriteU8_Click(object sender, EventArgs e)
        {
            string portName = registerWritePortname.Text;
            byte devId = Convert.ToByte(registerWriteDevId.Value);
            byte regId = Convert.ToByte(registerWriteRegId.Value);
            Int16 index = Convert.ToInt16(registerWriteIndex.Value);

            try
            {
                byte value = Convert.ToByte(registerWriteU8Value.Text);

                NKTPDLL.RegisterResultTypes result = NKTPDLL.registerWriteU8(portName, devId, regId, value, index);
                ShowRegisterResultTypes("registerWriteU8(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + value.ToString() + ", " + index.ToString() + ")", result);
            }
            catch (Exception)
            {
                StatusTextBox.AppendText("\r\n*** Invalid write value ***");
            }

        }

        private void registerWriteS8_Click(object sender, EventArgs e)
        {
            string portName = registerWritePortname.Text;
            byte devId = Convert.ToByte(registerWriteDevId.Value);
            byte regId = Convert.ToByte(registerWriteRegId.Value);
            Int16 index = Convert.ToInt16(registerWriteIndex.Value);

            try
            {
                sbyte value = Convert.ToSByte(registerWriteS8Value.Text);

                NKTPDLL.RegisterResultTypes result = NKTPDLL.registerWriteS8(portName, devId, regId, value, index);
                ShowRegisterResultTypes("registerWriteS8(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + value.ToString() + ", " + index.ToString() + ")", result);
            }
            catch (Exception)
            {
                StatusTextBox.AppendText("\r\n*** Invalid write value ***");
            }

        }

        private void registerWriteU16_Click(object sender, EventArgs e)
        {
            string portName = registerWritePortname.Text;
            byte devId = Convert.ToByte(registerWriteDevId.Value);
            byte regId = Convert.ToByte(registerWriteRegId.Value);
            Int16 index = Convert.ToInt16(registerWriteIndex.Value);

            try
            {
                UInt16 value = Convert.ToUInt16(registerWriteU16Value.Text);

                NKTPDLL.RegisterResultTypes result = NKTPDLL.registerWriteU16(portName, devId, regId, value, index);
                ShowRegisterResultTypes("registerWriteU16(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + value.ToString() + ", " + index.ToString() + ")", result);
            }
            catch (Exception)
            {
                StatusTextBox.AppendText("\r\n*** Invalid write value ***");
            }

        }

        private void registerWriteS16_Click(object sender, EventArgs e)
        {
            string portName = registerWritePortname.Text;
            byte devId = Convert.ToByte(registerWriteDevId.Value);
            byte regId = Convert.ToByte(registerWriteRegId.Value);
            Int16 index = Convert.ToInt16(registerWriteIndex.Value);

            try
            {
                Int16 value = Convert.ToInt16(registerWriteS16Value.Text);

                NKTPDLL.RegisterResultTypes result = NKTPDLL.registerWriteS16(portName, devId, regId, value, index);
                ShowRegisterResultTypes("registerWriteS16(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + value.ToString() + ", " + index.ToString() + ")", result);
            }
            catch (Exception)
            {
                StatusTextBox.AppendText("\r\n*** Invalid write value ***");
            }

        }

        private void registerWriteU32_Click(object sender, EventArgs e)
        {
            string portName = registerWritePortname.Text;
            byte devId = Convert.ToByte(registerWriteDevId.Value);
            byte regId = Convert.ToByte(registerWriteRegId.Value);
            Int16 index = Convert.ToInt16(registerWriteIndex.Value);

            try
            {
                UInt32 value = Convert.ToUInt32(registerWriteU32Value.Text);

                NKTPDLL.RegisterResultTypes result = NKTPDLL.registerWriteU32(portName, devId, regId, value, index);
                ShowRegisterResultTypes("registerWriteU32(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + value.ToString() + ", " + index.ToString() + ")", result);
            }
            catch (Exception)
            {
                StatusTextBox.AppendText("\r\n*** Invalid write value ***");
            }

        }

        private void registerWriteS32_Click(object sender, EventArgs e)
        {
            string portName = registerWritePortname.Text;
            byte devId = Convert.ToByte(registerWriteDevId.Value);
            byte regId = Convert.ToByte(registerWriteRegId.Value);
            Int16 index = Convert.ToInt16(registerWriteIndex.Value);

            try
            {
                Int32 value = Convert.ToInt32(registerWriteS32Value.Text);

                NKTPDLL.RegisterResultTypes result = NKTPDLL.registerWriteS32(portName, devId, regId, value, index);
                ShowRegisterResultTypes("registerWriteS32(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + value.ToString() + ", " + index.ToString() + ")", result);
            }
            catch (Exception)
            {
                StatusTextBox.AppendText("\r\n*** Invalid write value ***");
            }

        }

        private void registerWriteU64_Click(object sender, EventArgs e)
        {
            string portName = registerWritePortname.Text;
            byte devId = Convert.ToByte(registerWriteDevId.Value);
            byte regId = Convert.ToByte(registerWriteRegId.Value);
            Int16 index = Convert.ToInt16(registerWriteIndex.Value);

            try
            {
                UInt64 value = Convert.ToUInt64(registerWriteU64Value.Text);

                NKTPDLL.RegisterResultTypes result = NKTPDLL.registerWriteU64(portName, devId, regId, value, index);
                ShowRegisterResultTypes("registerWriteU64(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + value.ToString() + ", " + index.ToString() + ")", result);
            }
            catch (Exception)
            {
                StatusTextBox.AppendText("\r\n*** Invalid write value ***");
            }

        }

        private void registerWriteS64_Click(object sender, EventArgs e)
        {
            string portName = registerWritePortname.Text;
            byte devId = Convert.ToByte(registerWriteDevId.Value);
            byte regId = Convert.ToByte(registerWriteRegId.Value);
            Int16 index = Convert.ToInt16(registerWriteIndex.Value);

            try
            {
                Int64 value = Convert.ToInt64(registerWriteS64Value.Text);

                NKTPDLL.RegisterResultTypes result = NKTPDLL.registerWriteS64(portName, devId, regId, value, index);
                ShowRegisterResultTypes("registerWriteS64(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + value.ToString() + ", " + index.ToString() + ")", result);
            }
            catch (Exception)
            {
                StatusTextBox.AppendText("\r\n*** Invalid write value ***");
            }

        }

        private void registerWriteF32_Click(object sender, EventArgs e)
        {
            string portName = registerWritePortname.Text;
            byte devId = Convert.ToByte(registerWriteDevId.Value);
            byte regId = Convert.ToByte(registerWriteRegId.Value);
            Int16 index = Convert.ToInt16(registerWriteIndex.Value);

            try
            {
                float value = Convert.ToSingle(registerWriteF32Value.Text);

                NKTPDLL.RegisterResultTypes result = NKTPDLL.registerWriteF32(portName, devId, regId, value, index);
                ShowRegisterResultTypes("registerWriteF32(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + value.ToString() + ", " + index.ToString() + ")", result);
            }
            catch (Exception)
            {
                StatusTextBox.AppendText("\r\n*** Invalid write value ***");
            }

        }

        private void registerWriteF64_Click(object sender, EventArgs e)
        {
            string portName = registerWritePortname.Text;
            byte devId = Convert.ToByte(registerWriteDevId.Value);
            byte regId = Convert.ToByte(registerWriteRegId.Value);
            Int16 index = Convert.ToInt16(registerWriteIndex.Value);

            try
            {
                double value = Convert.ToDouble(registerWriteF64Value.Text);

                NKTPDLL.RegisterResultTypes result = NKTPDLL.registerWriteF64(portName, devId, regId, value, index);
                ShowRegisterResultTypes("registerWriteF64(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + value.ToString() + ", " + index.ToString() + ")", result);
            }
            catch (Exception)
            {
                StatusTextBox.AppendText("\r\n*** Invalid write value ***");
            }

        }

        private void registerWriteAscii_Click(object sender, EventArgs e)
        {
            string portName = registerWritePortname.Text;
            byte devId = Convert.ToByte(registerWriteDevId.Value);
            byte regId = Convert.ToByte(registerWriteRegId.Value);
            Int16 index = Convert.ToInt16(registerWriteIndex.Value);
            string value = registerWriteAsciiValue.Text;
            byte wrEOL = Convert.ToByte(registerWriteAsciiEOL.Checked);

            NKTPDLL.RegisterResultTypes result = NKTPDLL.registerWriteAscii(portName, devId, regId, value, wrEOL, index);
            ShowRegisterResultTypes("registerWriteAscii(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + value.ToString() + ", " + wrEOL.ToString() + ", " + index.ToString() + ")", result);

        }


       //------------------------------------------------------------------------------------------------------
       // Dedicated - Register write/read functions (A write immediately followed by a read)
       //------------------------------------------------------------------------------------------------------


        private void registerWriteReadU8_Click(object sender, EventArgs e)
        {
            string portName = registerWriteReadPortname.Text;
            byte devId = Convert.ToByte(registerWriteReadDevId.Value);
            byte regId = Convert.ToByte(registerWriteReadRegId.Value);
            Int16 index = Convert.ToInt16(registerWriteReadIndex.Value);

            try
            {
                byte wrValue = Convert.ToByte(registerWriteReadU8WrValue.Text);
                byte rdValue = 0;

                NKTPDLL.RegisterResultTypes result = NKTPDLL.registerWriteReadU8(portName, devId, regId, wrValue, ref rdValue, index);
                ShowRegisterResultTypes("registerWriteReadU8(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + wrValue.ToString() + ", " + "0, " + index.ToString() + ") : " + rdValue.ToString(), result);
            }
            catch (Exception)
            {
                StatusTextBox.AppendText("\r\n*** Invalid write value ***");
            }

        }

        private void registerWriteReadS8_Click(object sender, EventArgs e)
        {
            string portName = registerWriteReadPortname.Text;
            byte devId = Convert.ToByte(registerWriteReadDevId.Value);
            byte regId = Convert.ToByte(registerWriteReadRegId.Value);
            Int16 index = Convert.ToInt16(registerWriteReadIndex.Value);

            try
            {
                sbyte wrValue = Convert.ToSByte(registerWriteReadS8WrValue.Text);
                sbyte rdValue = 0;

                NKTPDLL.RegisterResultTypes result = NKTPDLL.registerWriteReadS8(portName, devId, regId, wrValue, ref rdValue, index);
                ShowRegisterResultTypes("registerWriteReadS8(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + wrValue.ToString() + ", " + "0, " + index.ToString() + ") : " + rdValue.ToString(), result);
            }
            catch (Exception)
            {
                StatusTextBox.AppendText("\r\n*** Invalid write value ***");
            }

        }

        private void registerWriteReadU16_Click(object sender, EventArgs e)
        {
            string portName = registerWriteReadPortname.Text;
            byte devId = Convert.ToByte(registerWriteReadDevId.Value);
            byte regId = Convert.ToByte(registerWriteReadRegId.Value);
            Int16 index = Convert.ToInt16(registerWriteReadIndex.Value);

            try
            {
                UInt16 wrValue = Convert.ToUInt16(registerWriteReadU16WrValue.Text);
                UInt16 rdValue = 0;

                NKTPDLL.RegisterResultTypes result = NKTPDLL.registerWriteReadU16(portName, devId, regId, wrValue, ref rdValue, index);
                ShowRegisterResultTypes("registerWriteReadU16(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + wrValue.ToString() + ", " + "0, " + index.ToString() + ") : " + rdValue.ToString(), result);
            }
            catch (Exception)
            {
                StatusTextBox.AppendText("\r\n*** Invalid write value ***");
            }

        }

        private void registerWriteReadS16_Click(object sender, EventArgs e)
        {
            string portName = registerWriteReadPortname.Text;
            byte devId = Convert.ToByte(registerWriteReadDevId.Value);
            byte regId = Convert.ToByte(registerWriteReadRegId.Value);
            Int16 index = Convert.ToInt16(registerWriteReadIndex.Value);

            try
            {
                Int16 wrValue = Convert.ToInt16(registerWriteReadS16WrValue.Text);
                Int16 rdValue = 0;

                NKTPDLL.RegisterResultTypes result = NKTPDLL.registerWriteReadS16(portName, devId, regId, wrValue, ref rdValue, index);
                ShowRegisterResultTypes("registerWriteReadS16(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + wrValue.ToString() + ", " + "0, " + index.ToString() + ") : " + rdValue.ToString(), result);
            }
            catch (Exception)
            {
                StatusTextBox.AppendText("\r\n*** Invalid write value ***");
            }

        }

        private void registerWriteReadU32_Click(object sender, EventArgs e)
        {
            string portName = registerWriteReadPortname.Text;
            byte devId = Convert.ToByte(registerWriteReadDevId.Value);
            byte regId = Convert.ToByte(registerWriteReadRegId.Value);
            Int16 index = Convert.ToInt16(registerWriteReadIndex.Value);

            try
            {
                UInt32 wrValue = Convert.ToUInt32(registerWriteReadU32WrValue.Text);
                UInt32 rdValue = 0;

                NKTPDLL.RegisterResultTypes result = NKTPDLL.registerWriteReadU32(portName, devId, regId, wrValue, ref rdValue, index);
                ShowRegisterResultTypes("registerWriteReadU32(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + wrValue.ToString() + ", " + "0, " + index.ToString() + ") : " + rdValue.ToString(), result);
            }
            catch (Exception)
            {
                StatusTextBox.AppendText("\r\n*** Invalid write value ***");
            }

        }

        private void registerWriteReadS32_Click(object sender, EventArgs e)
        {
            string portName = registerWriteReadPortname.Text;
            byte devId = Convert.ToByte(registerWriteReadDevId.Value);
            byte regId = Convert.ToByte(registerWriteReadRegId.Value);
            Int16 index = Convert.ToInt16(registerWriteReadIndex.Value);

            try
            {
                Int32 wrValue = Convert.ToInt32(registerWriteReadS32WrValue.Text);
                Int32 rdValue = 0;

                NKTPDLL.RegisterResultTypes result = NKTPDLL.registerWriteReadS32(portName, devId, regId, wrValue, ref rdValue, index);
                ShowRegisterResultTypes("registerWriteReadS32(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + wrValue.ToString() + ", " + "0, " + index.ToString() + ") : " + rdValue.ToString(), result);
            }
            catch (Exception)
            {
                StatusTextBox.AppendText("\r\n*** Invalid write value ***");
            }

        }

        private void registerWriteReadU64_Click(object sender, EventArgs e)
        {
            string portName = registerWriteReadPortname.Text;
            byte devId = Convert.ToByte(registerWriteReadDevId.Value);
            byte regId = Convert.ToByte(registerWriteReadRegId.Value);
            Int16 index = Convert.ToInt16(registerWriteReadIndex.Value);

            try
            {
                UInt64 wrValue = Convert.ToUInt64(registerWriteReadU64WrValue.Text);
                UInt64 rdValue = 0;

                NKTPDLL.RegisterResultTypes result = NKTPDLL.registerWriteReadU64(portName, devId, regId, wrValue, ref rdValue, index);
                ShowRegisterResultTypes("registerWriteReadU64(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + wrValue.ToString() + ", " + "0, " + index.ToString() + ") : " + rdValue.ToString(), result);
            }
            catch (Exception)
            {
                StatusTextBox.AppendText("\r\n*** Invalid write value ***");
            }

        }

        private void registerWriteReadS64_Click(object sender, EventArgs e)
        {
            string portName = registerWriteReadPortname.Text;
            byte devId = Convert.ToByte(registerWriteReadDevId.Value);
            byte regId = Convert.ToByte(registerWriteReadRegId.Value);
            Int16 index = Convert.ToInt16(registerWriteReadIndex.Value);

            try
            {
                Int64 wrValue = Convert.ToInt64(registerWriteReadS64WrValue.Text);
                Int64 rdValue = 0;

                NKTPDLL.RegisterResultTypes result = NKTPDLL.registerWriteReadS64(portName, devId, regId, wrValue, ref rdValue, index);
                ShowRegisterResultTypes("registerWriteReadS64(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + wrValue.ToString() + ", " + "0, " + index.ToString() + ") : " + rdValue.ToString(), result);
            }
            catch (Exception)
            {
                StatusTextBox.AppendText("\r\n*** Invalid write value ***");
            }

        }

        private void registerWriteReadF32_Click(object sender, EventArgs e)
        {
            string portName = registerWriteReadPortname.Text;
            byte devId = Convert.ToByte(registerWriteReadDevId.Value);
            byte regId = Convert.ToByte(registerWriteReadRegId.Value);
            Int16 index = Convert.ToInt16(registerWriteReadIndex.Value);

            try
            {
                float wrValue = Convert.ToSingle(registerWriteReadF32WrValue.Text);
                float rdValue = 0;

                NKTPDLL.RegisterResultTypes result = NKTPDLL.registerWriteReadF32(portName, devId, regId, wrValue, ref rdValue, index);
                ShowRegisterResultTypes("registerWriteReadF32(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + wrValue.ToString() + ", " + "0, " + index.ToString() + ") : " + rdValue.ToString(), result);
            }
            catch (Exception)
            {
                StatusTextBox.AppendText("\r\n*** Invalid write value ***");
            }

        }

        private void registerWriteReadF64_Click(object sender, EventArgs e)
        {
            string portName = registerWriteReadPortname.Text;
            byte devId = Convert.ToByte(registerWriteReadDevId.Value);
            byte regId = Convert.ToByte(registerWriteReadRegId.Value);
            Int16 index = Convert.ToInt16(registerWriteReadIndex.Value);

            try
            {
                double wrValue = Convert.ToDouble(registerWriteReadF64WrValue.Text);
                double rdValue = 0;

                NKTPDLL.RegisterResultTypes result = NKTPDLL.registerWriteReadF64(portName, devId, regId, wrValue, ref rdValue, index);
                ShowRegisterResultTypes("registerWriteReadF64(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + wrValue.ToString() + ", " + "0, " + index.ToString() + ") : " + rdValue.ToString(), result);
            }
            catch (Exception)
            {
                StatusTextBox.AppendText("\r\n*** Invalid write value ***");
            }

        }

        private void registerWriteReadAscii_Click(object sender, EventArgs e)
        {
            string portName = registerWriteReadPortname.Text;
            byte devId = Convert.ToByte(registerWriteReadDevId.Value);
            byte regId = Convert.ToByte(registerWriteReadRegId.Value);
            
            string wrValue = registerWriteReadAsciiWrValue.Text;

            byte maxLen = 255;
            StringBuilder rdValue = new StringBuilder(maxLen);

            byte wrEOL = Convert.ToByte(registerWriteReadAsciiEOL.Checked);
            Int16 index = Convert.ToInt16(registerWriteReadIndex.Value);

            NKTPDLL.RegisterResultTypes result = NKTPDLL.registerWriteReadAscii(portName, devId, regId, wrValue, wrEOL, rdValue, ref maxLen, index);
            ShowRegisterResultTypes("registerWriteAscii(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", \"" + wrValue.ToString() + "\", " + wrEOL.ToString() + ", \"\"" + ", " + index.ToString() + ", " + index.ToString() + ") : \"" + rdValue.ToString() + "\"", result);

        }

        //------------------------------------------------------------------------------------------------------
        // Dedicated - Device functions
        //------------------------------------------------------------------------------------------------------

        private void deviceGetType_Click(object sender, EventArgs e)
        {
            string portName = dedicatedDevicePortname.Text;
            byte devId = Convert.ToByte(dedicatedDeviceDevId.Value);
            byte devType = 0;

            NKTPDLL.DeviceResultTypes result = NKTPDLL.deviceGetType(portName, devId, ref devType);
            ShowDeviceResultTypes("deviceGetType(\"" + portName + "\", " + devId.ToString() + ", 0) : 0x" + devType.ToString("X2"), result);
        }

        private void deviceGetPartnumberStr_Click(object sender, EventArgs e)
        {
            string portName = dedicatedDevicePortname.Text;
            byte devId = Convert.ToByte(dedicatedDeviceDevId.Value);
            byte maxLen = 255;
            StringBuilder partnmb = new StringBuilder(maxLen);

            NKTPDLL.DeviceResultTypes result = NKTPDLL.deviceGetPartNumberStr(portName, devId, partnmb, ref maxLen);
            ShowDeviceResultTypes("deviceGetPartNumberStr(\"" + portName + "\", " + devId.ToString() + ", \"\", " + maxLen + ") : \"" + partnmb.ToString() + "\"", result);
        }

        private void deviceGetPCBVersion_Click(object sender, EventArgs e)
        {
            string portName = dedicatedDevicePortname.Text;
            byte devId = Convert.ToByte(dedicatedDeviceDevId.Value);
            byte pcbVer = 0;

            NKTPDLL.DeviceResultTypes result = NKTPDLL.deviceGetPCBVersion(portName, devId, ref pcbVer);
            ShowDeviceResultTypes("deviceGetPCBVersion(\"" + portName + "\", " + devId.ToString() + ", 0) : " + pcbVer.ToString(), result);
        }

        private void deviceGetStatusBits_Click(object sender, EventArgs e)
        {
            string portName = dedicatedDevicePortname.Text;
            byte devId = Convert.ToByte(dedicatedDeviceDevId.Value);
            UInt32 statusBits = 0;

            NKTPDLL.DeviceResultTypes result = NKTPDLL.deviceGetStatusBits(portName, devId, ref statusBits);
            ShowDeviceResultTypes("deviceGetStatusBits(\"" + portName + "\", " + devId.ToString() + ", 0) : 0x" + statusBits.ToString("X8"), result);
        }

        private void deviceGetErrorCode_Click(object sender, EventArgs e)
        {
            string portName = dedicatedDevicePortname.Text;
            byte devId = Convert.ToByte(dedicatedDeviceDevId.Value);
            UInt16 errorCode = 0;

            NKTPDLL.DeviceResultTypes result = NKTPDLL.deviceGetErrorCode(portName, devId, ref errorCode);
            ShowDeviceResultTypes("deviceGetErrorCode(\"" + portName + "\", " + devId.ToString() + ", 0) : 0x" + errorCode.ToString("X4"), result);
        }

        private void deviceGetBootloaderVersion_Click(object sender, EventArgs e)
        {
            string portName = dedicatedDevicePortname.Text;
            byte devId = Convert.ToByte(dedicatedDeviceDevId.Value);
            UInt16 blVer = 0;

            NKTPDLL.DeviceResultTypes result = NKTPDLL.deviceGetBootloaderVersion(portName, devId, ref blVer);
            ShowDeviceResultTypes("deviceGetBootLoaderVersion(\"" + portName + "\", " + devId.ToString() + ", 0) : " + blVer.ToString(), result);
        }

        private void deviceGetBootloaderVersionStr_Click(object sender, EventArgs e)
        {
            string portName = dedicatedDevicePortname.Text;
            byte devId = Convert.ToByte(dedicatedDeviceDevId.Value);
            byte maxLen = 255;
            StringBuilder blVerStr = new StringBuilder(maxLen);

            NKTPDLL.DeviceResultTypes result = NKTPDLL.deviceGetBootloaderVersionStr(portName, devId, blVerStr, ref maxLen);
            ShowDeviceResultTypes("deviceGetBootloaderVersionStr(\"" + portName + "\", " + devId.ToString() + ", \"\", " + maxLen + ") : \"" + blVerStr.ToString() + "\"", result);
        }

        private void deviceGetFirmwareVersion_Click(object sender, EventArgs e)
        {
            string portName = dedicatedDevicePortname.Text;
            byte devId = Convert.ToByte(dedicatedDeviceDevId.Value);
            UInt16 fwVer = 0;

            NKTPDLL.DeviceResultTypes result = NKTPDLL.deviceGetFirmwareVersion(portName, devId, ref fwVer);
            ShowDeviceResultTypes("deviceGetFirmwareVersion(\"" + portName + "\", " + devId.ToString() + ", 0) : " + fwVer.ToString(), result);
        }

        private void deviceGetFirmwareVersionStr_Click(object sender, EventArgs e)
        {
            string portName = dedicatedDevicePortname.Text;
            byte devId = Convert.ToByte(dedicatedDeviceDevId.Value);
            byte maxLen = 255;
            StringBuilder fwVerStr = new StringBuilder(maxLen);

            NKTPDLL.DeviceResultTypes result = NKTPDLL.deviceGetFirmwareVersionStr(portName, devId, fwVerStr, ref maxLen);
            ShowDeviceResultTypes("deviceGetFirmwareVersionStr(\"" + portName + "\", " + devId.ToString() + ", \"\", " + maxLen + ") : \"" + fwVerStr.ToString() + "\"", result);
        }

        private void deviceGetModuleSerialNumberStr_Click(object sender, EventArgs e)
        {
            string portName = dedicatedDevicePortname.Text;
            byte devId = Convert.ToByte(dedicatedDeviceDevId.Value);
            byte maxLen = 255;
            StringBuilder modSerialStr = new StringBuilder(maxLen);

            NKTPDLL.DeviceResultTypes result = NKTPDLL.deviceGetModuleSerialNumberStr(portName, devId, modSerialStr, ref maxLen);
            ShowDeviceResultTypes("deviceGetModuleSerialNumberStr(\"" + portName + "\", " + devId.ToString() + ", \"\", " + maxLen + ") : \"" + modSerialStr.ToString() + "\"", result);
        }

        private void deviceGetPCBSerialNumberStr_Click(object sender, EventArgs e)
        {
            string portName = dedicatedDevicePortname.Text;
            byte devId = Convert.ToByte(dedicatedDeviceDevId.Value);
            byte maxLen = 255;
            StringBuilder pcbSerialStr = new StringBuilder(maxLen);

            NKTPDLL.DeviceResultTypes result = NKTPDLL.deviceGetPCBSerialNumberStr(portName, devId, pcbSerialStr, ref maxLen);
            ShowDeviceResultTypes("deviceGetPCBSerialNumberStr(\"" + portName + "\", " + devId.ToString() + ", \"\", " + maxLen + ") : \"" + pcbSerialStr.ToString() + "\"", result);
        }




    }
}
