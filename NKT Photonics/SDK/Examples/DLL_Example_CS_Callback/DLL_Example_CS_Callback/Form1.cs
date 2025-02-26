using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using NKTP;


namespace DLL_Example_CS_Callback
{
    public partial class Form1 : Form
    {
        static TextBox MyStatusBox = null;

        public Form1()
        {
            InitializeComponent();
            MyStatusBox = StatusTextBox;    // Store a reference to the StatusTextBox so we can invoke from the callback routines.
        }


        /*******************************************************************************************************
         * Misc. helpers
         *******************************************************************************************************/


        private void comboBoxPortname_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (comboBoxPortname.SelectedIndex >= 0)
            {
                openPortsPortname.Text = comboBoxPortname.SelectedItem.ToString();
                closePortsPortname.Text = comboBoxPortname.SelectedItem.ToString();
                deviceCreatePortname.Text = comboBoxPortname.SelectedItem.ToString();
                registerCreatePortname.Text = comboBoxPortname.SelectedItem.ToString();
            }
        }


        private void ShowPortResultTypes(string funcName, NKTPDLL.PortResultTypes result)
        {
            StatusTextBox.AppendText("\r\n" + funcName + ": " + NKTPDLL.getPortResultMsg(result));
        }


        private void ShowP2PPortResultTypes(string funcName, NKTPDLL.P2PPortResultTypes result)
        {
            StatusTextBox.AppendText("\r\n" + funcName + ": " + NKTPDLL.getP2PPortResultMsg(result));
        }


        private void ShowDeviceResultTypes(string funcName, NKTPDLL.DeviceResultTypes result)
        {
            StatusTextBox.AppendText("\r\n" + funcName + ": " + NKTPDLL.getDeviceResultMsg(result));
        }


        private void ShowRegisterResultTypes(string funcName, NKTPDLL.RegisterResultTypes result)
        {
            StatusTextBox.AppendText("\r\n" + funcName + ": " + NKTPDLL.getRegisterResultMsg(result));
        }


        /*******************************************************************************************************
         * Callback handlers
         *******************************************************************************************************/


        private NKTPDLL.PortStatusCallbackFuncPtr _PortStatusInstance = new NKTPDLL.PortStatusCallbackFuncPtr(PortStatusCallback);  // Allocated to prevent garbage collection
        private static void PortStatusCallback([MarshalAs(UnmanagedType.LPStr)]String portname, NKTPDLL.PortStatusTypes status, byte curScanAdr, byte maxScanAdr, byte foundType)
        {
            string statusMsg = "\r\nPortInfo Callback: " + portname + " status:" + status.ToString() + " curScanAdr:" + curScanAdr.ToString() + " maxScanAdr:" + maxScanAdr.ToString() + " foundType:" + foundType.ToString("X2");

            MyStatusBox.Invoke((MethodInvoker) delegate() { MyStatusBox.AppendText(statusMsg); });

            Console.Write(statusMsg);
        }


        private NKTPDLL.DeviceStatusCallbackFuncPtr _DeviceStatusInstance = new NKTPDLL.DeviceStatusCallbackFuncPtr(DeviceStatusCallback);  // Allocated to prevent garbage collection
        private static void DeviceStatusCallback([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, NKTPDLL.DeviceStatusTypes status, byte devDataLen, [MarshalAs(UnmanagedType.LPArray, SizeParamIndex=3)]byte[] devData)
        {
            string statusMsg = "\r\nDeviceInfo Callback: " + portname + " devId: " + devId.ToString() + " status:" + status.ToString() + " ";

            switch ((NKTPDLL.DeviceStatusTypes)status)
            {
                case NKTPDLL.DeviceStatusTypes.DeviceModeChanged:
                    // 0 - devData contains 1 unsigned byte ::DeviceModeTypes
                    switch ((NKTPDLL.DeviceModeTypes)devData[0])
                    {
                        case NKTPDLL.DeviceModeTypes.DevModeDisabled:       statusMsg += "Mode: disabled"; break;
                        case NKTPDLL.DeviceModeTypes.DevModeAnalyzeInit:    statusMsg += "Mode: analyze init"; break;
                        case NKTPDLL.DeviceModeTypes.DevModeAnalyze:        statusMsg += "Mode: analyzing"; break;
                        case NKTPDLL.DeviceModeTypes.DevModeNormal:         statusMsg += "Mode: normal"; break;
                        case NKTPDLL.DeviceModeTypes.DevModeLogDownload:    statusMsg += "Mode: logDownload"; break;
                        case NKTPDLL.DeviceModeTypes.DevModeError:          statusMsg += "Mode: error"; break;
                        case NKTPDLL.DeviceModeTypes.DevModeTimeout:        statusMsg += "Mode: timeout"; break;
                        case NKTPDLL.DeviceModeTypes.DevModeUpload:         statusMsg += "Mode: firmwareUpload"; break;
                    }
                    break;
                case NKTPDLL.DeviceStatusTypes.DeviceLiveChanged:
                    // 1 - devData contains 1 unsigned byte, 0=live off, 1=live on.
                    if (devData[0] == 0)
                        statusMsg += "live: off";
                    else
                        statusMsg += "live: on";
                    break;
                case NKTPDLL.DeviceStatusTypes.DeviceTypeChanged:
                    // 2 - devData contains 1 unsigned byte with DeviceType (module type).
                    statusMsg += "type: 0x" + devData[0].ToString("X2");
                    break;
                case NKTPDLL.DeviceStatusTypes.DevicePartNumberChanged:
                    // 3 - devData contains a string with partnumber.
                    statusMsg += "partnumber: " + System.Text.Encoding.Default.GetString(devData);
                    break;
                case NKTPDLL.DeviceStatusTypes.DevicePCBVersionChanged:
                    // 4 - devData contains 1 unsigned byte with PCB version number.
                    statusMsg += "PCB ver: " + devData[0].ToString();
                    break;
                case NKTPDLL.DeviceStatusTypes.DeviceStatusBitsChanged:
                    // 5 - devData contains 1 unsigned long with statusbits.
                    statusMsg += "status bits: 0x" + BitConverter.ToUInt32(devData, 0).ToString("X8");
                    break;
                case NKTPDLL.DeviceStatusTypes.DeviceErrorCodeChanged:
                    // 6 - devData contains 1 unsigned short with errorcode.
                    statusMsg += "error code: 0x" + BitConverter.ToUInt16(devData, 0).ToString("X4");
                    break;
                case NKTPDLL.DeviceStatusTypes.DeviceBlVerChanged:
                    // 7 - devData contains a string with Bootloader version.
                    statusMsg += "bootloader ver: " + System.Text.Encoding.Default.GetString(devData);
                    break;
                case NKTPDLL.DeviceStatusTypes.DeviceFwVerChanged:
                    // 8 - devData contains a string with Firmware version.
                    statusMsg += "firmware ver: " + System.Text.Encoding.Default.GetString(devData);
                    break;
                case NKTPDLL.DeviceStatusTypes.DeviceModuleSerialChanged:
                    // 9 - devData contains a string with Module serialnumber.
                    statusMsg += "module serialnumber: " + System.Text.Encoding.Default.GetString(devData);
                    break;
                case NKTPDLL.DeviceStatusTypes.DevicePCBSerialChanged:
                    // 10 - devData contains a string with PCB serialnumber.
                    statusMsg += "PCB serialnumber: " + System.Text.Encoding.Default.GetString(devData);
                    break;
                case NKTPDLL.DeviceStatusTypes.DeviceSysTypeChanged:
                    // 11 - devData contains 1 unsigned byte with SystemType (system type).
                    statusMsg += "sys type: " + devData[0].ToString();
                    break;
            };

            MyStatusBox.Invoke((MethodInvoker)delegate() { MyStatusBox.AppendText(statusMsg); });

            Console.Write(statusMsg);
        }


        NKTPDLL.RegisterStatusCallbackFuncPtr _RegisterStatusInstance = new NKTPDLL.RegisterStatusCallbackFuncPtr(RegisterStatusCallback);  // Allocated to prevent garbage collection
        private static void RegisterStatusCallback([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, NKTPDLL.RegisterStatusTypes status, NKTPDLL.RegisterDataTypes regType, byte regDataLen, [MarshalAs(UnmanagedType.LPArray,SizeParamIndex=5)]byte[] regData)
        {
            string statusMsg = "\r\nDeviceInfo Callback: " + portname + " devId: " + devId.ToString() + " regId:" + regId.ToString() + " status:" + status.ToString() + " regType: " + regType.ToString() + " ";

            statusMsg += " regDataLen: " + regDataLen.ToString() + " regData:";
            for (int idx = 0; idx < regDataLen; idx++)
                statusMsg += " 0x" + regData[idx].ToString("X2");

            statusMsg += "\r\n" + NKTPDLL.getRegisterDataTypeMsg(regType);

            MyStatusBox.Invoke((MethodInvoker)delegate() { MyStatusBox.AppendText(statusMsg); });

            Console.Write(statusMsg);
        }


        /*******************************************************************************************************
         * Button handlers
         *******************************************************************************************************/

        private void getOpenPorts_Click(object sender, EventArgs e)
        {
            ushort maxLen = 400;
            StringBuilder openPortNames = new StringBuilder(maxLen);

            NKTPDLL.getOpenPorts(openPortNames, ref maxLen);
            StatusTextBox.AppendText("\r\n" + "getOpenPorts: " + openPortNames);
        }

        private void getAllPorts_Click(object sender, EventArgs e)
        {
            ushort maxLen = 400;
            StringBuilder portNames = new StringBuilder(maxLen);

            NKTPDLL.getAllPorts(portNames, ref maxLen);
            StatusTextBox.AppendText("\r\n" + "getAllPorts: " + portNames);

            // Update the portname combobox
            comboBoxPortname.Items.Clear();
            comboBoxPortname.Items.AddRange( portNames.ToString().Split(',') );
            comboBoxPortname.SelectedIndex = 0;
        }


        // Enable/Disable port info callbacks
        private void setCallbackPtrPortInfo_CheckedChanged(object sender, EventArgs e)
        {
            if (setCallbackPtrPortInfo.Checked)
                NKTPDLL.setCallbackPtrPortInfo(_PortStatusInstance);
            else
                NKTPDLL.setCallbackPtrPortInfo(null);
        }


        private void openPorts_Click(object sender, EventArgs e)
        {
            byte autoMode = 0;
            if (CheckBoxAutoMode.Checked) autoMode = 1;
            byte liveMode = 0;
            if (CheckBoxLiveMode.Checked) liveMode = 1;
            string portName = openPortsPortname.Text;

            NKTPDLL.PortResultTypes result = NKTPDLL.openPorts(portName, autoMode, liveMode);
            ShowPortResultTypes("openPorts(\"" + portName + "\", " + autoMode.ToString() + ", " + liveMode.ToString() + ")", result);
        }

        private void closePorts_Click(object sender, EventArgs e)
        {
            string portName = closePortsPortname.Text;

            NKTPDLL.PortResultTypes result = NKTPDLL.closePorts(portName);
            ShowPortResultTypes("closePorts(\"" + portName + "\")", result);
        }

        // Enable/Disable device info callbacks
        private void setCallbackPtrDeviceInfo_CheckedChanged(object sender, EventArgs e)
        {
            if (setCallbackPtrDeviceInfo.Checked)
                NKTPDLL.setCallbackPtrDeviceInfo(_DeviceStatusInstance);
            else
                NKTPDLL.setCallbackPtrDeviceInfo(null);
        }

        private void deviceCreate_Click(object sender, EventArgs e)
        {
            string portName = deviceCreatePortname.Text;
            byte devId = Convert.ToByte(deviceCreateDevId.Value);
            byte waitReady = 0;
            if (deviceCreateWaitReady.Checked) waitReady = 1;

            NKTPDLL.DeviceResultTypes result = NKTPDLL.deviceCreate(portName, devId, waitReady);
            ShowDeviceResultTypes("deviceCreate(\"" + portName + "\", " + devId.ToString() + ", " + waitReady.ToString() + ")", result);
        }

        // Enable/Disable register info callbacks
        private void setCallbackPtrRegisterInfo_CheckedChanged(object sender, EventArgs e)
        {
            if (setCallbackPtrRegisterInfo.Checked)
                NKTPDLL.setCallbackPtrRegisterInfo(_RegisterStatusInstance);
            else
                NKTPDLL.setCallbackPtrRegisterInfo(null);

        }

        private void registerCreate_Click(object sender, EventArgs e)
        {
            string portName = registerCreatePortname.Text;
            byte devId = Convert.ToByte(registerCreateDevId.Value);
            byte regId = Convert.ToByte(registerCreateRegId.Value);
            NKTPDLL.RegisterPriorityTypes priority = 0;
            if (registerCreatePriority.SelectedIndex >= 0)
                priority = (NKTPDLL.RegisterPriorityTypes)registerCreatePriority.SelectedIndex;
            NKTPDLL.RegisterDataTypes dataType = 0;
            if (registerCreateDataType.SelectedIndex >= 0)
                dataType = (NKTPDLL.RegisterDataTypes)registerCreateDataType.SelectedIndex;

            NKTPDLL.RegisterResultTypes result = NKTPDLL.registerCreate(portName, devId, regId, priority, dataType);
            ShowRegisterResultTypes("registerCreate(\"" + portName + "\", " + devId.ToString() + ", 0x" + regId.ToString("X2") + ", " + priority.ToString() + ", " + dataType.ToString(), result);

        }



    }
}
