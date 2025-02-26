using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.InteropServices;     // DLL support

namespace NKTP
{
    public class NKTPDLL
    {
        // Try loading the OS related DLL, x86 or x64 version
        // Alternatively copy the correct version into your applications folder.

        [DllImport("kernel32.dll")]
        private static extern IntPtr LoadLibrary(string dllToLoad);
        private static IntPtr refUnmanaged;
        static NKTPDLL()
        {
            String dllFolder = Environment.GetEnvironmentVariable("NKTP_SDK_PATH");
            String subfolder = (IntPtr.Size == 8) ? "\\NKTPDLL\\x64\\" : "\\NKTPDLL\\x86\\";
            refUnmanaged = LoadLibrary(dllFolder + subfolder + "NKTPDLL.dll");
        }

        /*!
        * \brief The PortResultTypes enum
        */
        public enum PortResultTypes : byte
        {
            OPSuccess = 0,          //!< 0
            OPFailed = 1,           //!< 1
            OPPortNotFound = 2,     //!< 2
            OPNoDevices = 3,        //!< 3
            OPApplicationBusy = 4   //!< 4
        };

        /*!
        * \brief The PointToPointPortStatus enum
        */
        public enum P2PPortResultTypes : byte
        {
            P2PSuccess = 0,             //!< 0
            P2PInvalidPortname = 1,     //!< 1
            P2PInvalidLocalIP = 2,      //!< 2
            P2PInvalidRemoteIP = 3,     //!< 3
            P2PPortnameNotFound = 4,    //!< 4
            P2PPortnameExists = 5,      //!< 5
            P2PApplicationBusy = 6      //!< 6
        };

        /*!
        * \brief The DeviceResultTypes enum
        */
        public enum DeviceResultTypes : byte
        {
            DevResultSuccess = 0,           //!< 0
            DevResultWaitTimeout = 1,       //!< 1
            DevResultFailed = 2,            //!< 2
            DevResultDeviceNotFound = 3,    //!< 3
            DevResultPortNotFound = 4,      //!< 4
            DevResultPortOpenError = 5,     //!< 5
            DevResultApplicationBusy = 6    //!< 6
        };

        /*!
        * \brief The DeviceModeTypes enum
        */
        public enum DeviceModeTypes : byte
        {
            DevModeDisabled = 0,        //!< 0
            DevModeAnalyzeInit = 1,     //!< 1
            DevModeAnalyze = 2,         //!< 2
            DevModeNormal = 3,          //!< 3
            DevModeLogDownload = 4,     //!< 4
            DevModeError = 5,           //!< 5
            DevModeTimeout = 6,         //!< 6
            DevModeUpload = 7           //!< 7
        };

        /*!
        * \brief The RegisterResultTypes enum
        */
        public enum RegisterResultTypes : byte
        {
            RegResultSuccess = 0,               //!< 0
            RegResultReadError = 1,             //!< 1
            RegResultFailed = 2,                //!< 2
            RegResultBusy = 3,                  //!< 3
            RegResultNacked = 4,                //!< 4
            RegResultCRCErr = 5,                //!< 5
            RegResultTimeout = 6,               //!< 6
            RegResultComError = 7,              //!< 7
            RegResultTypeError = 8,             //!< 8
            RegResultIndexError = 9,            //!< 9
            RegResultPortClosed = 10,           //!< 10
            RegResultRegisterNotFound = 11,     //!< 11
            RegResultDeviceNotFound = 12,       //!< 12
            RegResultPortNotFound = 13,         //!< 13
            RegResultPortOpenError = 14,        //!< 14
            RegResultApplicationBusy = 15       //!< 15
        };

        /*!
        * \brief The RegisterDataTypes enum
        */
        public enum RegisterDataTypes : byte
        {
            RegData_Unknown = 0,    //!< 0
            RegData_Array = 1,      //!< 1
            RegData_U8 = 2,         //!< 2
            RegData_S8 = 3,         //!< 3
            RegData_U16 = 4,        //!< 4
            RegData_S16 = 5,        //!< 5
            RegData_U32 = 6,        //!< 6
            RegData_S32 = 7,        //!< 7
            RegData_F32 = 8,        //!< 8
            RegData_U64 = 9,        //!< 9
            RegData_S64 = 10,       //!< 10
            RegData_F64 = 11,       //!< 11
            RegData_Ascii = 12,     //!< 12
            RegData_Paramset = 13,  //!< 13
            RegData_B8 = 14,        //!< 14
            RegData_H8 = 15,        //!< 15
            RegData_B16 = 16,       //!< 16
            RegData_H16 = 17,       //!< 17
            RegData_B32 = 18,       //!< 18
            RegData_H32 = 19,       //!< 19
            RegData_B64 = 20,       //!< 20
            RegData_H64 = 21,       //!< 21
            RegData_DateTime = 22,  //!< 22
        };

        /*!
        * \brief The RegisterPriorityTypes enum
        */
        public enum RegisterPriorityTypes : byte
        {
            RegPriority_Low = 0,    //!< 0
            RegPriority_High = 1    //!< 1
        };

        /*!
        * \brief The PortStatusTypes enum
        */
        public enum PortStatusTypes : byte
        {
            PortStatusUnknown = 0,     //!< 0
            PortOpening = 1,           //!< 1
            PortOpened = 2,            //!< 2
            PortOpenFail = 3,          //!< 3
            PortScanStarted = 4,       //!< 4
            PortScanProgress = 5,      //!< 5
            PortScanDeviceFound = 6,   //!< 6
            PortScanEnded = 7,         //!< 7
            PortClosing = 8,           //!< 8
            PortClosed = 9,            //!< 9
            PortReady = 10             //!< 10
        };

        /*!
        * \brief The DeviceStatusTypes enum
        */
        public enum DeviceStatusTypes : byte
        {
            DeviceModeChanged = 0,          //!< 0 - devData contains 1 unsigned byte ::DeviceModeTypes
            DeviceLiveChanged = 1,          //!< 1 - devData contains 1 unsigned byte, 0=live off, 1=live on.
            DeviceTypeChanged = 2,          //!< 2 - devData contains 1 unsigned byte with DeviceType (module type).
            DevicePartNumberChanged = 3,    //!< 3 - devData contains a string with partnumber.
            DevicePCBVersionChanged = 4,    //!< 4 - devData contains 1 unsigned byte with PCB version number.
            DeviceStatusBitsChanged = 5,    //!< 5 - devData contains 1 unsigned long with statusbits.
            DeviceErrorCodeChanged = 6,     //!< 6 - devData contains 1 unsigned short with errorcode.
            DeviceBlVerChanged = 7,         //!< 7 - devData contains a string with Bootloader version.
            DeviceFwVerChanged = 8,         //!< 8 - devData contains a string with Firmware version.
            DeviceModuleSerialChanged = 9,  //!< 9 - devData contains a string with Module serialnumber.
            DevicePCBSerialChanged = 10,    //!< 10 - devData contains a string with PCB serialnumber.
			DeviceSysTypeChanged = 11       //!< 11 - devData contains 1 unsigned byte with SystemType (system type).
        };

        /*!
        * \brief The RegisterStatusTypes enum
        */
        public enum RegisterStatusTypes : byte
        {
            RegSuccess = 0,     //!< 0
            RegBusy = 1,        //!< 1
            RegNacked = 2,      //!< 2
            RegCRCErr = 3,      //!< 3
            RegTimeout = 4,     //!< 4
            RegComError = 5     //!< 5
        };

        /*!
        * \brief tDateTimeStruct, The DateTime struct 24 hour format
        */
        [StructLayout(LayoutKind.Sequential, Pack=1)]
        public struct tDateTimeStruct
        {
            byte Sec;      //!< Seconds
            byte Min;      //!< Minutes
            byte Hour;     //!< Hours
            byte Day;      //!< Days
            byte Month;    //!< Months
            byte Year;     //!< Years
        };

        /*!
        * \brief The ParamSetUnitTypes enum
        */
        public enum ParamSetUnitTypes : byte
        {
            // Unit codes
            UnitNone = 0,       //!< 0 - none/unknown
            UnitmV = 1,         //!< 1 - mV
            UnitV = 2,          //!< 2 - V
            UnituA = 3,         //!< 3 - µA
            UnitmA = 4,         //!< 4 - mA
            UnitA = 5,          //!< 5 - A
            UnituW = 6,         //!< 6 - µW
            UnitcmW = 7,        //!< 7 - mW/100
            UnitdmW = 8,        //!< 8 - mW/10
            UnitmW = 9,         //!< 9 - mW
            UnitW = 10,         //!< 10 - W
            UnitmC = 11,        //!< 11 - °C/1000
            UnitcC = 12,        //!< 12 - °C/100
            UnitdC = 13,        //!< 13 - °C/10
            Unitpm = 14,        //!< 14 - pm
            Unitdnm = 15,       //!< 15 - nm/10
            Unitnm = 16,        //!< 16 - nm
            UnitPerCent = 17,   //!< 17 - %
            UnitPerMille = 18,  //!< 18 - ‰
            UnitcmA = 19,       //!< 19 - mA/100
            UnitdmA = 20,       //!< 20 - mA/10
            UnitRPM = 21,       //!< 21 - RPM
            UnitdBm = 22,       //!< 22 - dBm
            UnitcBm = 23,       //!< 23 - dBm/10
            UnitmBm = 24,       //!< 24 - dBm/100
            UnitdB = 25,        //!< 25 - dB
            UnitcB = 26,        //!< 26 - dB/10
            UnitmB = 27,        //!< 27 - dB/100
            Unitdpm = 28,       //!< 28 - pm/10
            UnitcV = 29,        //!< 29 - V/100
            UnitdV = 30,        //!< 30 - V/10
            Unitlm = 31,        //!< 31 - lm (lumen)
            Unitdlm = 32,       //!< 32 - lm/10
            Unitclm = 33,       //!< 33 - lm/100
            Unitmlm = 34        //!< 34 - lm/1000
        };

        /*!
        * \brief tParamSetStruct, The ParameterSet struct
        * \note How calculation on parametersets is done internally by modules:\n
        * DAC_value = (value * (X/Y)) + Offset; Where value is either StartVal or FactoryVal\n
        * value = (ADC_value * (X/Y)) + Offset; Where value often is available via another measurement register\n
        */
        [StructLayout(LayoutKind.Sequential, Pack=1)]
        public struct tParamSetStruct
        {
            ParamSetUnitTypes Unit; //!< Unit type as defined in ::ParamSetUnitTypes
            byte ErrorHandler;      //!< Warning/Errorhandler not used.
            ushort StartVal;        //!< Setpoint for Settings parameterset, unused in Measurement parametersets.
            ushort FactoryVal;      //!< Factory Setpoint for Settings parameterset, unused in Measurement parametersets.
            ushort ULimit;          //!< Upper limit.
            ushort LLimit;          //!< Lower limit.
            short Numerator;        //!< Numerator(X) for calculation.
            short Denominator;      //!< Denominator(Y) for calculation.
            short Offset;           //!< Offset for calculation
        };


        /*******************************************************************************************************
        * Helper functions
        *******************************************************************************************************/

        public static string getPortResultMsg(PortResultTypes result)
        {
            switch (result)
            {
                case PortResultTypes.OPSuccess: return result.ToString() + "Success";
                case PortResultTypes.OPFailed: return result.ToString() + ":Failed";
                case PortResultTypes.OPPortNotFound: return result.ToString() + ":Port not found";
                case PortResultTypes.OPNoDevices: return result.ToString() + ":Success, but no devices found";
                case PortResultTypes.OPApplicationBusy: return result.ToString() + ":Application busy - Call orginating from callback function, not allowed";
                default: return "Unknown result:" + result.ToString();
            }
        }

        public static string getP2PPortResultMsg(P2PPortResultTypes result)
        {
            switch (result)
            {
                case P2PPortResultTypes.P2PSuccess: return result.ToString() + ":Success";
                case P2PPortResultTypes.P2PInvalidPortname: return result.ToString() + ":Invalid portname";
                case P2PPortResultTypes.P2PInvalidLocalIP: return result.ToString() + ":Invalid local IP";
                case P2PPortResultTypes.P2PInvalidRemoteIP: return result.ToString() + ":Invalid remote IP";
                case P2PPortResultTypes.P2PPortnameNotFound: return result.ToString() + ":Portname not found";
                case P2PPortResultTypes.P2PPortnameExists: return result.ToString() + ":Portname already exists";
                case P2PPortResultTypes.P2PApplicationBusy: return result.ToString() + ":Application busy - Call orginating from callback function, not allowed";
                default: return "Unknown result:" + result.ToString();
            }
        }

        public static string getRegisterDataTypeMsg(RegisterDataTypes dataType)
        {
            switch (dataType)
            {
                case NKTPDLL.RegisterDataTypes.RegData_Unknown: return dataType.ToString() + ":Unknown datatype";
                case NKTPDLL.RegisterDataTypes.RegData_Array: return dataType.ToString() + ":Array datatype";
                case NKTPDLL.RegisterDataTypes.RegData_U8: return dataType.ToString() + ":U8 datatype";
                case NKTPDLL.RegisterDataTypes.RegData_S8: return dataType.ToString() + ":S8 datatype";
                case NKTPDLL.RegisterDataTypes.RegData_U16: return dataType.ToString() + ":U16 datatype";
                case NKTPDLL.RegisterDataTypes.RegData_S16: return dataType.ToString() + ":S16 datatype";
                case NKTPDLL.RegisterDataTypes.RegData_U32: return dataType.ToString() + ":U32 datatype";
                case NKTPDLL.RegisterDataTypes.RegData_S32: return dataType.ToString() + ":S32 datatype";
                case NKTPDLL.RegisterDataTypes.RegData_F32: return dataType.ToString() + ":F32 datatype";
                case NKTPDLL.RegisterDataTypes.RegData_U64: return dataType.ToString() + ":U64 datatype";
                case NKTPDLL.RegisterDataTypes.RegData_S64: return dataType.ToString() + ":S64 datatype";
                case NKTPDLL.RegisterDataTypes.RegData_F64: return dataType.ToString() + ":F64 datatype";
                case NKTPDLL.RegisterDataTypes.RegData_Ascii: return dataType.ToString() + ":Ascii datatype";
                case NKTPDLL.RegisterDataTypes.RegData_Paramset: return dataType.ToString() + ":Paramset datatype";
                case NKTPDLL.RegisterDataTypes.RegData_B8: return dataType.ToString() + ":B8 datatype";
                case NKTPDLL.RegisterDataTypes.RegData_H8: return dataType.ToString() + ":H8 datatype";
                case NKTPDLL.RegisterDataTypes.RegData_B16: return dataType.ToString() + ":B16 datatype";
                case NKTPDLL.RegisterDataTypes.RegData_H16: return dataType.ToString() + ":H16 datatype";
                case NKTPDLL.RegisterDataTypes.RegData_B32: return dataType.ToString() + ":B32 datatype";
                case NKTPDLL.RegisterDataTypes.RegData_H32: return dataType.ToString() + ":H32 datatype";
                case NKTPDLL.RegisterDataTypes.RegData_B64: return dataType.ToString() + ":B64 datatype";
                case NKTPDLL.RegisterDataTypes.RegData_H64: return dataType.ToString() + ":H64 datatype";
                case NKTPDLL.RegisterDataTypes.RegData_DateTime: return dataType.ToString() + ":DateTime datatype";
                default: return "Unknown datatype:" + dataType.ToString();
            }        
        }

        public static string getRegisterResultMsg(RegisterResultTypes result)
        {
            switch (result)
            {
                case RegisterResultTypes.RegResultSuccess: return result.ToString() + ":Success";
                case RegisterResultTypes.RegResultReadError: return result.ToString() + ":ReadError";
                case RegisterResultTypes.RegResultFailed: return result.ToString() + ":Failed";
                case RegisterResultTypes.RegResultBusy: return result.ToString() + ":Busy";
                case RegisterResultTypes.RegResultNacked: return result.ToString() + ":Nacked";
                case RegisterResultTypes.RegResultCRCErr: return result.ToString() + ":CRCError";
                case RegisterResultTypes.RegResultTimeout: return result.ToString() + ":Timeout";
                case RegisterResultTypes.RegResultComError: return result.ToString() + ":ComError";
                case RegisterResultTypes.RegResultTypeError: return result.ToString() + ":TypeError";
                case RegisterResultTypes.RegResultIndexError: return result.ToString() + ":IndexError";
                case RegisterResultTypes.RegResultPortClosed: return result.ToString() + ":PortClosed";
                case RegisterResultTypes.RegResultRegisterNotFound: return result.ToString() + ":RegisterNotFound";
                case RegisterResultTypes.RegResultDeviceNotFound: return result.ToString() + ":DeviceNotFound";
                case RegisterResultTypes.RegResultPortNotFound: return result.ToString() + ":PortNotFound";
                case RegisterResultTypes.RegResultPortOpenError: return result.ToString() + ":PortOpenError";
                case RegisterResultTypes.RegResultApplicationBusy: return result.ToString() + ":ApplicationBusy - Call orginating from callback function, not allowed";
                default: return "Unknown result:" + result.ToString();
            }
        }

        public static string getDeviceResultMsg(DeviceResultTypes result)
        {
            switch (result)
            {
                case DeviceResultTypes.DevResultSuccess: return result.ToString() + ":Success";
                case DeviceResultTypes.DevResultWaitTimeout: return result.ToString() + ":Timeout";
                case DeviceResultTypes.DevResultFailed: return result.ToString() + ":Failed";
                case DeviceResultTypes.DevResultDeviceNotFound: return result.ToString() + ":DeviceNotFound";
                case DeviceResultTypes.DevResultPortNotFound: return result.ToString() + ":PortNotFound";
                case DeviceResultTypes.DevResultPortOpenError: return result.ToString() + ":PortOpenErr";
                case DeviceResultTypes.DevResultApplicationBusy: return result.ToString() + ":ApplicationBusy - Call orginating from callback function, not allowed";
                default: return "Unknown result:" + result.ToString();
            }
        }

        public static string getPortStatustMsg(PortStatusTypes status)
        {
            switch (status)
            {
                case PortStatusTypes.PortStatusUnknown: return status.ToString() + ":PortStatusUnknown";
                case PortStatusTypes.PortOpening: return status.ToString() + ":PortOpening";
                case PortStatusTypes.PortOpened: return status.ToString() + ":PortOpened";
                case PortStatusTypes.PortOpenFail: return status.ToString() + ":PortOpenFail";
                case PortStatusTypes.PortScanStarted: return status.ToString() + ":PortScanStarted";
                case PortStatusTypes.PortScanProgress: return status.ToString() + ":PortScanProgress";
                case PortStatusTypes.PortScanDeviceFound: return status.ToString() + ":PortScanDeviceFound";
                case PortStatusTypes.PortScanEnded: return status.ToString() + ":PortScanEnded";
                case PortStatusTypes.PortClosing: return status.ToString() + ":PortClosing";
                case PortStatusTypes.PortClosed: return status.ToString() + ":PortClosed";
                case PortStatusTypes.PortReady: return status.ToString() + ":PortReady";
                default: return "Unknown status:" + status.ToString();
            }
        }

        public static string getDeviceStatustMsg(DeviceStatusTypes status)
        {
            switch (status)
            {
                case DeviceStatusTypes.DeviceModeChanged: return status.ToString() + ":DeviceModeChanged";
                case DeviceStatusTypes.DeviceLiveChanged: return status.ToString() + ":DeviceLiveChanged";
                case DeviceStatusTypes.DeviceTypeChanged: return status.ToString() + ":DeviceTypeChanged";
                case DeviceStatusTypes.DevicePartNumberChanged: return status.ToString() + ":DevicePartNumberChanged";
                case DeviceStatusTypes.DevicePCBVersionChanged: return status.ToString() + ":DevicePCBVersionChanged";
                case DeviceStatusTypes.DeviceStatusBitsChanged: return status.ToString() + ":DeviceStatusBitsChanged";
                case DeviceStatusTypes.DeviceErrorCodeChanged: return status.ToString() + ":DeviceErrorCodeChanged";
                case DeviceStatusTypes.DeviceBlVerChanged: return status.ToString() + ":DeviceBlVerChanged";
                case DeviceStatusTypes.DeviceFwVerChanged: return status.ToString() + ":DeviceFwVerChanged";
                case DeviceStatusTypes.DeviceModuleSerialChanged: return status.ToString() + ":DeviceModuleSerialChanged";
                case DeviceStatusTypes.DevicePCBSerialChanged: return status.ToString() + ":DevicePCBSerialChanged";
                default: return "Unknown status:" + status.ToString();
            }
        }

        public static string getRegisterStatustMsg(RegisterStatusTypes status)
        {
            switch (status)
            {
                case RegisterStatusTypes.RegSuccess: return status.ToString() + ":RegSuccess";
                case RegisterStatusTypes.RegBusy: return status.ToString() + ":RegBusy";
                case RegisterStatusTypes.RegNacked: return status.ToString() + ":RegNacked";
                case RegisterStatusTypes.RegCRCErr: return status.ToString() + ":RegCRCErr";
                case RegisterStatusTypes.RegTimeout: return status.ToString() + ":RegTimeout";
                case RegisterStatusTypes.RegComError: return status.ToString() + ":RegComError";
                default: return "Unknown status:" + status.ToString();
            }
        }

        /*******************************************************************************************************
        * Port functions
        *******************************************************************************************************/

        /*!
        * \brief Returns a comma separated string with all existing ports.
        * \param portnames Pointer to a preallocated string area where the function will store the comma separated string.
        * \param maxLen Size of preallocated string area. The returned string may be truncated to fit into the allocated area.
        */
        // extern "C" NKTPDLL_EXPORT void getAllPorts(char *portnames, unsigned short *maxLen);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern void getAllPorts([MarshalAs(UnmanagedType.LPStr)]StringBuilder portnames, ref ushort maxLen);

        /*!
        * \brief Returns a comma separated string with all allready opened ports.
        * \param portnames Pointer to a preallocated string area where the function will store the comma separated string.
        * \param maxLen Size of preallocated string area. The returned string may be truncated to fit into the allocated area.
        */
        // extern "C" NKTPDLL_EXPORT void getOpenPorts(char *portnames, unsigned short *maxLen);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern void getOpenPorts([MarshalAs(UnmanagedType.LPStr)]StringBuilder portnames, ref ushort maxLen);

        /*!
        * \brief Creates or Modifies a point to point port.
        * \param portname Zero terminated string giving the portname. ex. "AcoustikPort1"
        * \param hostAddress Zero terminated string giving the local ip address. ex. "192.168.1.67"
        * \param hostPort The local port number.
        * \param clientAddress Zero terminated string giving the remote ip address. ex. "192.168.1.100"
        * \param clientPort The remote port number.
        * \param protocol \arg 0 Specifies TCP protocol.
                          \arg 1 Specifies UDP protocol.
        * \param msTimeout Telegram timeout value in milliseconds, typically set to 100ms.
        * \return ::P2PPortResultTypes
        */
        // extern "C" NKTPDLL_EXPORT P2PPortResultTypes pointToPointPortAdd(const char *portname, const char *hostAddress, const unsigned short hostPort, const char *clientAddress, const unsigned short clientPort, const unsigned char protocol, const unsigned char msTimeout);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern P2PPortResultTypes pointToPointPortAdd([MarshalAs(UnmanagedType.LPStr)]String portname, [MarshalAs(UnmanagedType.LPStr)]String hostAddress, ushort hostPort, [MarshalAs(UnmanagedType.LPStr)]String clientAddress, ushort clientPort, byte protocol, byte msTimeout);

        /*!
        * \brief Retrieve an already created point to point port setting.
        * \param portname Zero terminated string giving the portname (case sensitive). ex. "AcoustikPort1"
        * \param hostAddress Pointer to a preallocated string area where the function will store the zero terminated string, describing the local ip address.
        * \param hostMaxLen Pointer to an unsigned char giving the size of the preallocated hostAddress area, modified by the function to reflect the actual length of the returned string. The returned string may be truncated to fit into the allocated area.
        * \param hostPort Pointer to a preallocated short where the function will store the local port number.
        * \param clientAddress Pointer to a preallocated string area where the function will store the zero terminated string, describing the remote ip address.
        * \param clientMaxLen Pointer to an unsigned char giving the size of the preallocated clientAddress area, modified by the function to reflect the actual length of the returned string. The returned string may be truncated to fit into the allocated area.
        * \param clientPort Pointer to a preallocated short where the function will store the client port number.
        * \param protocol Pointer to a preallocated char where the function will store the protocol.
                       \arg 0 Specifies TCP protocol.
                       \arg 1 Specifies UDP protocol.
        * \param msTimeout Pointer to a preallocated char where the function will store the timeout value.
        * \return ::P2PPortResultTypes
        */
        // extern "C" NKTPDLL_EXPORT P2PPortResultTypes pointToPointPortGet(const char *portname, char *hostAddress, unsigned char *hostMaxLen, unsigned short *hostPort, char *clientAddress, unsigned char *clientMaxLen, unsigned short *clientPort, unsigned char *protocol, unsigned char *msTimeout);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern P2PPortResultTypes pointToPointPortGet([MarshalAs(UnmanagedType.LPStr)]String portname, [MarshalAs(UnmanagedType.LPStr)]StringBuilder hostAddress, ref byte hostMaxLen, ref ushort hostPort, [MarshalAs(UnmanagedType.LPStr)]StringBuilder clientAddress, ref byte clientMaxLen, ref ushort clientPort, ref byte protocol, ref byte msTimeout);

        /*!
        * \brief Delete an already created point to point port.
        * \param portname Zero terminated string giving the portname (case sensitive). ex. "AcoustikPort1"
        * \return ::P2PPortResultTypes
        */
        // extern "C" NKTPDLL_EXPORT P2PPortResultTypes pointToPointPortDel(const char *portname);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern P2PPortResultTypes pointToPointPortDel([MarshalAs(UnmanagedType.LPStr)]String portname);

        /*!
        * \brief Opens the provided portname(s), or all available ports if an empty string provided. Repeatedly calls is allowed to reopen and/or rescan for devices.\n
        * \param portnames Zero terminated comma separated string giving the portnames to open (case sensitive). An empty string opens all available ports.
        * \param autoMode \arg 0 the openPorts function only opens the port. Busscanning and device creation is NOT automatically handled.
        *                 \arg 1 the openPorts function will automatically start the busscanning and create the found devices in the internal devicelist. The port is automatically closed if no devices found.
        * \param liveMode \arg 0 the openPorts function disables the continuously monitoring of the registers. No callback possible on register changes. Use ::registerRead, ::registerWrite & ::registerWriteRead functions.
        *                 \arg 1 the openPorts function will keep all the found or created devices in live mode, which means the Interbus kernel keeps monitoring all the found devices and their registers.
        *                  Please note that this will keep the modules watchdog alive as long as the port is open.
        * \return ::PortResultTypes
        * \note The function may timeout after 2 seconds waiting for port ready status and return ::OPFailed.\n
        *       In case autoMode is specified this timeout is extended to 20 seconds to allow for busscanning to complete.
        */
        // extern "C" NKTPDLL_EXPORT PortResultTypes openPorts(const char *portnames, const char autoMode, const char liveMode);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern PortResultTypes openPorts([MarshalAs(UnmanagedType.LPStr)]String portnames, byte autoMode, byte liveMode);

        /*!
        * \brief Closes the provided portname(s), or all opened ports if an empty string provided.
        * \param portnames Zero terminated comma separated string giving the portnames to close (case sensitive). An empty string closes all open ports.
        * \return ::PortResultTypes
        * \note The function may timeout after 2 seconds waiting for port close to complete and return ::OPFailed.
        */
        // extern "C" NKTPDLL_EXPORT PortResultTypes closePorts(const char *portnames);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern PortResultTypes closePorts([MarshalAs(UnmanagedType.LPStr)]String portnames);

        /*!
        * \brief Sets legacy busscanning on or off.
        * \param legacyScanning \arg 0 the busscanning is set to normal mode and allows for rolling masterId. In this mode the masterId is changed for each message to allow for out of sync. detection.
        *                       \arg 1 the busscanning is set to legacy mode and fixes the masterId at address 66(0x42). Some older modules does not accept masterIds other than 66(ox42).
        */
        // extern "C" NKTPDLL_EXPORT void setLegacyBusScanning(const char legacyScanning);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern void setLegacyBusScanning(byte legacyScanning);

        /*!
        * \brief Gets legacy busscanning status.
        * \return An unsigned char, with legacyScanning status. 0 the busscanning is currently in normal mode. 1 the busscanning is currently in legacy mode.
        */
        // extern "C" NKTPDLL_EXPORT unsigned char getLegacyBusScanning();
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern byte getLegacyBusScanning();

        /*!
        * \brief Retrieve ::PortStatusTypes for a given port.
        * \param portname Zero terminated string giving the portname (case sensitive). ex. "COM1"
        * \param portStatus Pointer to a ::PortStatusTypes where the function will store the port status.
        * \return ::PortResultTypes
        */
        // extern "C" NKTPDLL_EXPORT PortResultTypes getPortStatus(const char *portname, PortStatusTypes *portStatus);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern PortResultTypes getPortStatus([MarshalAs(UnmanagedType.LPStr)]String portname, ref PortStatusTypes portStatus);

        /*!
        * \brief Retrieve error message for a given port. An empty string indicates no error.
        * \param portname Zero terminated string giving the portname (case sensitive). ex. "COM1"
        * \param errorMessage Pointer to a preallocated string area where the function will store the zero terminated error string.
        * \param maxLen Pointer to an unsigned short giving the size of the preallocated string area, modified by the function to reflect the actual length of the returned string. The returned string may be truncated to fit into the allocated area.
        */
        // extern "C" NKTPDLL_EXPORT PortResultTypes getPortErrorMsg(const char *portname, char *errorMessage, unsigned short *maxLen);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern PortResultTypes getPortErrorMsg([MarshalAs(UnmanagedType.LPStr)]String portname, [MarshalAs(UnmanagedType.LPStr)]StringBuilder errorMessage, ref ushort maxLen);

        /*******************************************************************************************************
        * Dedicated - Register read functions
        *******************************************************************************************************/
        /* It is not necessary to open the port, create the device or register before using those functions, since they will do a dedicated action.
         * Even though an already opened port would be preffered in time critical situations where a lot of reads is required.
         */

        /*!
        * \brief Reads a register value and returns the result in readData area.
        * \param portname Zero terminated string giving the portname (case sensitive).
        * \param devId The device id (module address).
        * \param regId The register id (register address).
        * \param readData Pointer to a preallocated data area where the function will store the register value.
        * \param readSize Size of preallocated data area, modified by the function to reflect the actual length of the returned register value. The returned register value may be truncated to fit into the allocated area.
        * \param index Data index. Typically -1, but could be used to extract data from a specific position in the register. Index is byte counted.
        * \return A status result value ::RegisterResultTypes
        * \sa ::registerReadU8, ::registerReadS8 etc.
        * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
        */
        //extern "C" NKTPDLL_EXPORT RegisterResultTypes registerRead(const char *portname, const unsigned char devId, const unsigned char regId, void *readData, unsigned char *readSize, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerRead([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, [MarshalAs(UnmanagedType.LPArray,SizeParamIndex=4)] ref byte[] readData, ref byte readSize, short index);

        /*!
        * \brief Reads an unsigned char (8bit) register value and returns the result in value.
        * \param portname Zero terminated string giving the portname (case sensitive).
        * \param devId The device id (module address).
        * \param regId The register id (register address).
        * \param value Pointer to an unsigned char where the function will store the register value.
        * \param index Value index. Typically -1, but could be used to extract a value in a multi value register. Index is byte counted.
        * \return A status result value ::RegisterResultTypes
        * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
        */
        //extern "C" NKTPDLL_EXPORT RegisterResultTypes registerReadU8(const char *portname, const unsigned char devId, const unsigned char regId, unsigned char *value, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerReadU8([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, ref byte value, short index);

        /*!
        * \brief Reads a signed char (8bit) register value and returns the result in value.
        * \param portname Zero terminated string giving the portname (case sensitive).
        * \param devId The device id (module address).
        * \param regId The register id (register address).
        * \param value Pointer to a signed char where the function will store the register value.
        * \param index Value index. Typically -1, but could be used to extract a value in a multi value register. Index is byte counted.
        * \return A status result value ::RegisterResultTypes
        * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
        */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerReadS8(const char *portname, const unsigned char devId, const unsigned char regId, signed char *value, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerReadS8([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, ref sbyte value, short index);

        /*!
        * \brief Reads an unsigned short (16bit) register value and returns the result in value.
        * \param portname Zero terminated string giving the portname (case sensitive).
        * \param devId The device id (module address).
        * \param regId The register id (register address).
        * \param value Pointer to an unsigned short where the function will store the register value.
        * \param index Value index. Typically -1, but could be used to extract a value in a multi value register. Index is byte counted.
        * \return A status result value ::RegisterResultTypes
        * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
        */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerReadU16(const char *portname, const unsigned char devId, const unsigned char regId, unsigned short *value, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerReadU16([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, ref UInt16 value, short index);

        /*!
        * \brief Reads a signed short (16bit) register value and returns the result in value.
        * \param portname Zero terminated string giving the portname (case sensitive).
        * \param devId The device id (module address).
        * \param regId The register id (register address).
        * \param value Pointer to a signed short where the function will store the register value.
        * \param index Value index. Typically -1, but could be used to extract a value in a multi value register. Index is byte counted.
        * \return A status result value ::RegisterResultTypes
        * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
        */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerReadS16(const char *portname, const unsigned char devId, const unsigned char regId, signed short *value, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerReadS16([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, ref Int16 value, short index);

        /*!
        * \brief Reads an unsigned long (32bit) register value and returns the result in value.
        * \param portname Zero terminated string giving the portname (case sensitive).
        * \param devId The device id (module address).
        * \param regId The register id (register address).
        * \param value Pointer to an unsigned long where the function will store the register value.
        * \param index Value index. Typically -1, but could be used to extract a value in a multi value register. Index is byte counted.
        * \return A status result value ::RegisterResultTypes
        * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
        */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerReadU32(const char *portname, const unsigned char devId, const unsigned char regId, unsigned long *value, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerReadU32([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, ref UInt32 value, short index);

        /*!
        * \brief Reads a signed long (32bit) register value and returns the result in value.
        * \param portname Zero terminated string giving the portname (case sensitive).
        * \param devId The device id (module address).
        * \param regId The register id (register address).
        * \param value Pointer to a signed long where the function will store the register value.
        * \param index Value index. Typically -1, but could be used to extract a value in a multi value register. Index is byte counted.
        * \return A status result value ::RegisterResultTypes
        * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
        */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerReadS32(const char *portname, const unsigned char devId, const unsigned char regId, signed long *value, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerReadS32([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, ref Int32 value, short index);

        /*!
        * \brief Reads an unsigned long long (64bit) register value and returns the result in value.
        * \param portname Zero terminated string giving the portname (case sensitive).
        * \param devId The device id (module address).
        * \param regId The register id (register address).
        * \param value Pointer to an unsigned long long where the function will store the register value.
        * \param index Value index. Typically -1, but could be used to extract a value in a multi value register. Index is byte counted.
        * \return A status result value ::RegisterResultTypes
        * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
        */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerReadU64(const char *portname, const unsigned char devId, const unsigned char regId, unsigned long long *value, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerReadU64([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, ref UInt64 value, short index);

        /*!
        * \brief Reads a signed long long (64bit) register value and returns the result in value.
        * \param portname Zero terminated string giving the portname (case sensitive).
        * \param devId The device id (module address).
        * \param regId The register id (register address).
        * \param value Pointer to a signed long long where the function will store the register value.
        * \param index Value index. Typically -1, but could be used to extract a value in a multi value register. Index is byte counted.
        * \return A status result value ::RegisterResultTypes
        * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
        */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerReadS64(const char *portname, const unsigned char devId, const unsigned char regId, signed long long *value, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerReadS64([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, ref Int64 value, short index);

        /*!
        * \brief Reads a float (32bit) register value and returns the result in value.
        * \param portname Zero terminated string giving the portname (case sensitive).
        * \param devId The device id (module address).
        * \param regId The register id (register address).
        * \param value Pointer to a float where the function will store the register value.
        * \param index Value index. Typically -1, but could be used to extract a value in a multi value register. Index is byte counted.
        * \return A status result value ::RegisterResultTypes
        * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
        */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerReadF32(const char *portname, const unsigned char devId, const unsigned char regId, float *value, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerReadF32([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, ref float value, short index);

        /*!
        * \brief Reads a double (64bit) register value and returns the result in value.
        * \param portname Zero terminated string giving the portname (case sensitive).
        * \param devId The device id (module address).
        * \param regId The register id (register address).
        * \param value Pointer to a double where the function will store the register value.
        * \param index Value index. Typically -1, but could be used to extract a value in a multi value register. Index is byte counted.
        * \return A status result value ::RegisterResultTypes
        * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
        */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerReadF64(const char *portname, const unsigned char devId, const unsigned char regId, double *value, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerReadF64([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, ref double value, short index);

        /*!
        * \brief Reads a Ascii string register value and returns the result in readStr area.
        * \param portname Zero terminated string giving the portname (case sensitive).
        * \param devId The device id (module address).
        * \param regId The register id (register address).
        * \param readStr Pointer to a preallocated string area where the function will store the register value.
        * \param maxLen Size of preallocated string area, modified by the function to reflect the actual length of the returned string. The returned string may be truncated to fit into the allocated area.
        * \param index Value index. Typically -1, but could be used to extract a string in a mixed type register. Index is byte counted.
        * \return A status result value ::RegisterResultTypes
        * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
        */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerReadAscii(const char *portname, const unsigned char devId, const unsigned char regId, char *readStr, unsigned char *maxLen, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerReadAscii([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, [MarshalAs(UnmanagedType.LPStr)]StringBuilder readStr, ref byte maxLen, short index);


        /*******************************************************************************************************
         * Dedicated - Register write functions
         *******************************************************************************************************/
        /* It is not necessary to open the port, create the device or register before using those functions, since they will do a dedicated action.
         * Even though an already opened port would be preffered in time critical situations where a lot of writes is required.
         */

        /*!
         * \brief Writes a register value.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regId The register id (register address).
         * \param writeData Pointer to a data area from where the write value will be extracted.
         * \param writeSize Size of data area, ex. number of bytes to write. Write size is limited to max 240 bytes
         * \param index Data index. Typically -1, but could be used to write data at a specific position in the register. Index is byte counted.
         *                          Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
         *                          indexed content is modified and finally the complete content is written to the register.
         * \return A status result value ::RegisterResultTypes
         * \sa ::registerWriteU8, ::registerWriteS8 etc.
         * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write.
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWrite(const char *portname, const unsigned char devId, const unsigned char regId, const void *writeData, const unsigned char writeSize, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerWrite([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, [MarshalAs(UnmanagedType.LPArray)]byte[] writeData, byte writeSize, short index);

        /*!
         * \brief Writes an unsigned char (8bit) register value.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regId The register id (register address).
         * \param value The register value to write.
         * \param index Value index. Typically -1, but could be used to write a value in a multi value register. Index is byte counted.
         *                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
         *                           indexed content is modified and finally the complete content is written to the register.
         * \return A status result value ::RegisterResultTypes
         * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write.
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteU8(const char *portname, const unsigned char devId, const unsigned char regId, const unsigned char value, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerWriteU8([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, byte value, short index);

        /*!
         * \brief Writes a signed char (8bit) register value.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regId The register id (register address).
         * \param value The register value to write.
         * \param index Value index. Typically -1, but could be used to write a value in a multi value register. Index is byte counted.
         *                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
         *                           indexed content is modified and finally the complete content is written to the register.
         * \return A status result value ::RegisterResultTypes
         * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write.
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteS8(const char *portname, const unsigned char devId, const unsigned char regId, const signed char value, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerWriteS8([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, sbyte value, short index);

        /*!
         * \brief Writes an unsigned short (16bit) register value.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regId The register id (register address).
         * \param value The register value to write.
         * \param index Value index. Typically -1, but could be used to write a value in a multi value register. Index is byte counted.
         *                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
         *                           indexed content is modified and finally the complete content is written to the register.
         * \return A status result value ::RegisterResultTypes
         * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write.
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteU16(const char *portname, const unsigned char devId, const unsigned char regId, const unsigned short value, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerWriteU16([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, UInt16 value, short index);

        /*!
         * \brief Writes a signed short (16bit) register value.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regId The register id (register address).
         * \param value The register value to write.
         * \param index Value index. Typically -1, but could be used to write a value in a multi value register. Index is byte counted.
         *                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
         *                           indexed content is modified and finally the complete content is written to the register.
         * \return A status result value ::RegisterResultTypes
         * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write.
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteS16(const char *portname, const unsigned char devId, const unsigned char regId, const signed short value, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerWriteS16([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, Int16 value, short index);

        /*!
         * \brief Writes an unsigned long (32bit) register value.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regId The register id (register address).
         * \param value The register value to write.
         * \param index Value index. Typically -1, but could be used to write a value in a multi value register. Index is byte counted.
         *                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
         *                           indexed content is modified and finally the complete content is written to the register.
         * \return A status result value ::RegisterResultTypes
         * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write.
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteU32(const char *portname, const unsigned char devId, const unsigned char regId, const unsigned long value, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerWriteU32([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, UInt32 value, short index);

        /*!
         * \brief Writes a signed long (32bit) register value.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regId The register id (register address).
         * \param value The register value to write.
         * \param index Value index. Typically -1, but could be used to write a value in a multi value register. Index is byte counted.
         *                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
         *                           indexed content is modified and finally the complete content is written to the register.
         * \return A status result value ::RegisterResultTypes
         * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write.
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteS32(const char *portname, const unsigned char devId, const unsigned char regId, const signed long value, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerWriteS32([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, Int32 value, short index);

        /*!
         * \brief Writes an unsigned long long (64bit) register value.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regId The register id (register address).
         * \param value The register value to write.
         * \param index Value index. Typically -1, but could be used to write a value in a multi value register. Index is byte counted.
         *                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
         *                           indexed content is modified and finally the complete content is written to the register.
         * \return A status result value ::RegisterResultTypes
         * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write.
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteU64(const char *portname, const unsigned char devId, const unsigned char regId, const unsigned long long value, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerWriteU64([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, UInt64 value, short index);

        /*!
         * \brief Writes a signed long long (64bit) register value.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regId The register id (register address).
         * \param value The register value to write.
         * \param index Value index. Typically -1, but could be used to write a value in a multi value register. Index is byte counted.
         *                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
         *                           indexed content is modified and finally the complete content is written to the register.
         * \return A status result value ::RegisterResultTypes
         * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write.
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteS64(const char *portname, const unsigned char devId, const unsigned char regId, const signed long long value, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerWriteS64([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, Int64 value, short index);

        /*!
         * \brief Writes a float (32bit) register value.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regId The register id (register address).
         * \param value The register value to write.
         * \param index Value index. Typically -1, but could be used to write a value in a multi value register. Index is byte counted.
         *                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
         *                           indexed content is modified and finally the complete content is written to the register.
         * \return A status result value ::RegisterResultTypes
         * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write.
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteF32(const char *portname, const unsigned char devId, const unsigned char regId, const float value, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerWriteF32([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, float value, short index);

        /*!
         * \brief Writes a double (64bit) register value.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regId The register id (register address).
         * \param value The register value to write.
         * \param index Value index. Typically -1, but could be used to write a value in a multi value register. Index is byte counted.
         *                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
         *                           indexed content is modified and finally the complete content is written to the register.
         * \return A status result value ::RegisterResultTypes
         * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write.
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteF64(const char *portname, const unsigned char devId, const unsigned char regId, const double value, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerWriteF64([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, double value, short index);

        /*!
         * \brief Writes a string register value.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regId The register id (register address).
         * \param writeStr The zero terminated string to write. WriteStr will be limited to 239 characters and the terminating zero, totally 240 bytes.
         * \param writeEOL \arg 0 Do NOT append End Of Line character (a null character) to the string.
         *                 \arg 1 Append End Of Line character to the string.
         * \param index Value index. Typically -1, but could be used to write a value in a mixed type register. Index is byte counted.
         *                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
         *                           indexed content is modified and finally the complete content is written to the register.
         * \return A status result value ::RegisterResultTypes
         * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write.
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteAscii(const char *portname, const unsigned char devId, const unsigned char regId, const char* writeStr, const char writeEOL, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerWriteAscii([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, [MarshalAs(UnmanagedType.LPStr)]String writeStr, byte writeEOL, short index);


        /*******************************************************************************************************
         * Dedicated - Register write/read functions (A write immediately followed by a read)
         *******************************************************************************************************/
        /* It is not necessary to open the port, create the device or register before using those functions, since they will do a dedicated action.
         * Even though an already opened port would be preffered in time critical situations where a lot of readwrites is required.
         */

        /*!
         * \brief Writes and Reads a register value before returning.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regId The register id (register address).
         * \param writeData Pointer to a data area from where the write value will be extracted.
         * \param writeSize Size of write data area, ex. number of bytes to write.
         * \param readData Pointer to a preallocated data area where the function will store the register read value.
         * \param readSize Size of preallocated read data area, modified by the function to reflect the actual length of the read register value. The read register value may be truncated to fit into the allocated area.
         * \param index Data index. Typically -1, but could be used to write/read data at/from a specific position in the register. Index is byte counted.
         *                          Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
         *                          indexed content is modified and finally the complete content is written to the register.
         * \return A status result value ::RegisterResultTypes
         * \sa ::registerWriteReadU8, ::registerWriteReadS8 etc.
         * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write followed by a dedicated read.
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteRead(const char *portname, const unsigned char devId, const unsigned char regId, const void *writeData, const unsigned char writeSize, void *readData, unsigned char *readSize, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerWriteRead([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, [MarshalAs(UnmanagedType.LPArray)]byte[] writeData, byte writeSize, [MarshalAs(UnmanagedType.LPArray,SizeParamIndex=6)] ref byte[] readData, ref byte readSize, short index);

        /*!
         * \brief Writes and Reads an unsigned char (8bit) register value.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regId The register id (register address).
         * \param writeValue The register value to write.
         * \param readValue Pointer to an unsigned char where the function will store the register read value.
         * \param index Value index. Typically -1, but could be used to write and read a value in a multi value register. Index is byte counted.
         *                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
         *                           indexed content is modified and finally the complete content is written to the register.
         * \return A status result value ::RegisterResultTypes
         * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write followed by a dedicated read.
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteReadU8(const char *portname, const unsigned char devId, const unsigned char regId, const unsigned char writeValue, unsigned char *readValue, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerWriteReadU8([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, byte writeValue, ref byte readValue, short index);

        /*!
         * \brief Writes and Reads a signed char (8bit) register value.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regId The register id (register address).
         * \param writeValue The register value to write.
         * \param readValue Pointer to a signed char where the function will store the register read value.
         * \param index Value index. Typically -1, but could be used to write and read a value in a multi value register. Index is byte counted.
         *                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
         *                           indexed content is modified and finally the complete content is written to the register.
         * \return A status result value ::RegisterResultTypes
         * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write followed by a dedicated read.
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteReadS8(const char *portname, const unsigned char devId, const unsigned char regId, const signed char writeValue, signed char *readValue, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerWriteReadS8([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, sbyte writeValue, ref sbyte readValue, short index);

        /*!
         * \brief Writes and Reads an unsigned short (16bit) register value.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regId The register id (register address).
         * \param writeValue The register value to write.
         * \param readValue Pointer to an unsigned short where the function will store the register read value.
         * \param index Value index. Typically -1, but could be used to write and read a value in a multi value register. Index is byte counted.
         *                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
         *                           indexed content is modified and finally the complete content is written to the register.
         * \return A status result value ::RegisterResultTypes
         * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write followed by a dedicated read.
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteReadU16(const char *portname, const unsigned char devId, const unsigned char regId, const unsigned short writeValue, unsigned short *readValue, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerWriteReadU16([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, UInt16 writeValue, ref UInt16 readValue, short index);

        /*!
         * \brief Writes and Reads a signed short (16bit) register value.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regId The register id (register address).
         * \param writeValue The register value to write.
         * \param readValue Pointer to a signed short where the function will store the register read value.
         * \param index Value index. Typically -1, but could be used to write and read a value in a multi value register. Index is byte counted.
         *                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
         *                           indexed content is modified and finally the complete content is written to the register.
         * \return A status result value ::RegisterResultTypes
         * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write followed by a dedicated read.
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteReadS16(const char *portname, const unsigned char devId, const unsigned char regId, const signed short writeValue, signed short *readValue, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerWriteReadS16([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, Int16 writeValue, ref Int16 readValue, short index);

        /*!
         * \brief Writes and Reads an unsigned long (32bit) register value.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regId The register id (register address).
         * \param writeValue The register value to write.
         * \param readValue Pointer to an unsigned long where the function will store the register read value.
         * \param index Value index. Typically -1, but could be used to write and read a value in a multi value register. Index is byte counted.
         *                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
         *                           indexed content is modified and finally the complete content is written to the register.
         * \return A status result value ::RegisterResultTypes
         * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write followed by a dedicated read.
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteReadU32(const char *portname, const unsigned char devId, const unsigned char regId, const unsigned long writeValue, unsigned long *readValue, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerWriteReadU32([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, UInt32 writeValue, ref UInt32 readValue, short index);

        /*!
         * \brief Writes and Reads a signed long (32bit) register value.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regId The register id (register address).
         * \param writeValue The register value to write.
         * \param readValue Pointer to a signed long where the function will store the register read value.
         * \param index Value index. Typically -1, but could be used to write and read a value in a multi value register. Index is byte counted.
         *                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
         *                           indexed content is modified and finally the complete content is written to the register.
         * \return A status result value ::RegisterResultTypes
         * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write followed by a dedicated read.
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteReadS32(const char *portname, const unsigned char devId, const unsigned char regId, const signed long writeValue, signed long *readValue, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerWriteReadS32([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, Int32 writeValue, ref Int32 readValue, short index);

        /*!
         * \brief Writes and Reads an unsigned long long (64bit) register value.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regId The register id (register address).
         * \param writeValue The register value to write.
         * \param readValue Pointer to an unsigned long long where the function will store the register read value.
         * \param index Value index. Typically -1, but could be used to write and read a value in a multi value register. Index is byte counted.
         *                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
         *                           indexed content is modified and finally the complete content is written to the register.
         * \return A status result value ::RegisterResultTypes
         * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write followed by a dedicated read.
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteReadU64(const char *portname, const unsigned char devId, const unsigned char regId, const unsigned long long writeValue, unsigned long long *readValue, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerWriteReadU64([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, UInt64 writeValue, ref UInt64 readValue, short index);

        /*!
         * \brief Writes and Reads a signed long long (64bit) register value.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regId The register id (register address).
         * \param writeValue The register value to write.
         * \param readValue Pointer to a signed long long where the function will store the register read value.
         * \param index Value index. Typically -1, but could be used to write and read a value in a multi value register. Index is byte counted.
         *                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
         *                           indexed content is modified and finally the complete content is written to the register.
         * \return A status result value ::RegisterResultTypes
         * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write followed by a dedicated read.
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteReadS64(const char *portname, const unsigned char devId, const unsigned char regId, const signed long long writeValue, signed long long *readValue, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerWriteReadS64([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, Int64 writeValue, ref Int64 readValue, short index);

        /*!
         * \brief Writes and Reads a float (32bit) register value.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regId The register id (register address).
         * \param writeValue The register value to write.
         * \param readValue Pointer to a float where the function will store the register read value.
         * \param index Value index. Typically -1, but could be used to write and read a value in a multi value register. Index is byte counted.
         *                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
         *                           indexed content is modified and finally the complete content is written to the register.
         * \return A status result value ::RegisterResultTypes
         * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write followed by a dedicated read.
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteReadF32(const char *portname, const unsigned char devId, const unsigned char regId, const float writeValue, float *readValue, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerWriteReadF32([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, float writeValue, ref float readValue, short index);

        /*!
         * \brief Writes and Reads a double (64bit) register value.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regId The register id (register address).
         * \param writeValue The register value to write.
         * \param readValue Pointer to a double where the function will store the register read value.
         * \param index Value index. Typically -1, but could be used to write and read a value in a multi value register. Index is byte counted.
         *                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
         *                           indexed content is modified and finally the complete content is written to the register.
         * \return A status result value ::RegisterResultTypes
         * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write followed by a dedicated read.
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteReadF64(const char *portname, const unsigned char devId, const unsigned char regId, const double writeValue, double *readValue, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerWriteReadF64([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, double writeValue, ref double readValue, short index);

        /*!
         * \brief Writes and Reads a string register value.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regId The register id (register address).
         * \param writeStr The zero terminated string to write. WriteStr will be limited to 239 characters and the terminating zero, totally 240 bytes.
         * \param writeEOL \arg 0 Do NOT append End Of Line character (a null character) to the string.
         *                 \arg 1 Append End Of Line character to the string.
         * \param readStr Pointer to a preallocated string area where the function will store the register read value.
         * \param maxLen Size of preallocated string area, modified by the function to reflect the actual length of the returned string. The returned string may be truncated to fit into the allocated area.
         * \param index Value index. Typically -1, but could be used to write and read a string in a mixed type register. Index is byte counted.
         *                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
         *                           indexed content is modified and finally the complete content is written to the register.
         * \return A status result value ::RegisterResultTypes
         * \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write followed by a dedicated read.
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteReadAscii(const char *portname, const unsigned char devId, const unsigned char regId, const char* writeStr, const char writeEOL, char *readStr, unsigned char *maxLen, const short index);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerWriteReadAscii([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, [MarshalAs(UnmanagedType.LPStr)]String writeStr, byte writeEOL, [MarshalAs(UnmanagedType.LPStr)]StringBuilder readStr, ref byte maxLen, short index);


        /*******************************************************************************************************
         * Dedicated - Device functions
         *******************************************************************************************************/
        /* Dedicated - Device functions could be used directly.\n
         * It is not necessary to open the port, create the device or register before using those functions, since they will do a dedicated action.
         * Even though an already opened port would be preffered in time critical situations where a lot of reads is required.
         */

        /*!
         * \brief Returns the module type for a specific device id (module address).
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId Given device id to retrieve device type for (module type).
         * \param devType Pointer to an unsigned char where the function stores the device type.
         * \return A status result value ::DeviceResultTypes
         * \note Register address 0x61\n
         *       It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
         */
        // extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetType(const char *portname, const unsigned char devId, unsigned char *devType);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern DeviceResultTypes deviceGetType([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, ref byte devType);

        /*!
         * \brief Returns the partnumber for a given device (module address).
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param partnumber Pointer to a preallocated string area where the function will store the partnumber.
         * \param maxLen Size of preallocated string area, modified by the function to reflect the actual length of the returned string. The returned string may be truncated to fit into the allocated area.
         * \return A status result value ::RegisterResultTypes
         * \note Register address 0x8E <b>Not all modules have a partnumber register.</b>\n
         *       It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
         */
        // extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetPartNumberStr(const char *portname, const unsigned char devId, char *partnumber, unsigned char *maxLen);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern DeviceResultTypes deviceGetPartNumberStr([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, [MarshalAs(UnmanagedType.LPStr)]StringBuilder partnumber, ref byte maxLen);

        /*!
         * \brief Returns the PCB version for a given device (module address).
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param PCBVersion Pointer to a preallocated unsigned char where the function will store the PCB version.
         * \return A status result value ::RegisterResultTypes
         * \note Register address 0x62\n
         *       It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
         */
        // extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetPCBVersion(const char *portname, const unsigned char devId, unsigned char *PCBVersion);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern DeviceResultTypes deviceGetPCBVersion([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, ref byte PCBVersion);

        /*!
         * \brief Returns the status bits for a given device (module address).
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param statusBits Pointer to a preallocated unsigned short where the function will store the status bits.
         * \return A status result value ::RegisterResultTypes
         * \note Register address 0x66\n
         *       It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
         */
        // extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetStatusBits(const char *portname, const unsigned char devId, unsigned long *statusBits);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern DeviceResultTypes deviceGetStatusBits([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, ref UInt32 statusBits);

        /*!
         * \brief Returns the error code for a given device (module address).
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param errorCode Pointer to a preallocated unsigned short where the function will store the error code.
         * \return A status result value ::RegisterResultTypes
         * \note Register address 0x67\n
         *       It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
         */
        // extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetErrorCode(const char *portname, const unsigned char devId, unsigned short *errorCode);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern DeviceResultTypes deviceGetErrorCode([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, ref UInt16 errorCode);

        /*!
         * \brief Returns the bootloader version for a given device (module address).
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param version Pointer to a preallocated unsigned short where the function will store the bootloader version.
         * \return A status result value ::RegisterResultTypes
         * \note Register address 0x6D\n
         *       It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
         */
        // extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetBootloaderVersion(const char *portname, const unsigned char devId, unsigned short *version);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern DeviceResultTypes deviceGetBootloaderVersion([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, ref UInt16 version);

        /*!
         * \brief Returns the bootloader version (string) for a given device (module address).
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param versionStr Pointer to a preallocated string area where the function will store the bootloader version.
         * \param maxLen Size of preallocated string area, modified by the function to reflect the actual length of the returned string. The returned string may be truncated to fit into the allocated area.
         * \return A status result value ::RegisterResultTypes
         * \note Register address 0x6D\n
         *       It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
         */
        // extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetBootloaderVersionStr(const char *portname, const unsigned char devId, char *versionStr, unsigned char *maxLen);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern DeviceResultTypes deviceGetBootloaderVersionStr([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, [MarshalAs(UnmanagedType.LPStr)]StringBuilder versionStr, ref byte maxLen);

        /*!
         * \brief Returns the firmware version for a given device (module address).
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param version Pointer to a preallocated unsigned short where the function will store the firmware version.
         * \return A status result value ::RegisterResultTypes
         * \note Register address 0x64\n
         *       It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
         */
        // extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetFirmwareVersion(const char *portname, const unsigned char devId, unsigned short *version);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern DeviceResultTypes deviceGetFirmwareVersion([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, ref UInt16 version);

        /*!
         * \brief Returns the firmware version (string) for a given device (module address).
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param versionStr Pointer to a preallocated string area where the function will store the firmware version.
         * \param maxLen Size of preallocated string area, modified by the function to reflect the actual length of the returned string. The returned string may be truncated to fit into the allocated area.
         * \return A status result value ::RegisterResultTypes
         * \note Register address 0x64\n
         *       It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
         */
        // extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetFirmwareVersionStr(const char *portname, const unsigned char devId, char *versionStr, unsigned char *maxLen);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern DeviceResultTypes deviceGetFirmwareVersionStr([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, [MarshalAs(UnmanagedType.LPStr)]StringBuilder versionStr, ref byte maxLen);

        /*!
         * \brief Returns the Module serialnumber (string) for a given device (module address).
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param serialNumber Pointer to a preallocated string area where the function will store the serialnumber version.
         * \param maxLen Size of preallocated string area, modified by the function to reflect the actual length of the returned string. The returned string may be truncated to fit into the allocated area.
         * \return A status result value ::RegisterResultTypes
         * \note Register address 0x65\n
         *       It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
         */
        // extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetModuleSerialNumberStr(const char *portname, const unsigned char devId, char *serialNumber, unsigned char *maxLen);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern DeviceResultTypes deviceGetModuleSerialNumberStr([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, [MarshalAs(UnmanagedType.LPStr)]StringBuilder serialNumber, ref byte maxLen);

        /*!
         * \brief Returns the PCB serialnumber (string) for a given device (module address).
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param serialNumber Pointer to a preallocated string area where the function will store the serialnumber version.
         * \param maxLen Size of preallocated string area, modified by the function to reflect the actual length of the returned string. The returned string may be truncated to fit into the allocated area.
         * \return A status result value ::RegisterResultTypes
         * \note Register address 0x6E\n
         *       It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
         */
        // extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetPCBSerialNumberStr(const char *portname, const unsigned char devId, char *serialNumber, unsigned char *maxLen);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern DeviceResultTypes deviceGetPCBSerialNumberStr([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, [MarshalAs(UnmanagedType.LPStr)]StringBuilder serialNumber, ref byte maxLen);


        /*******************************************************************************************************
        * Callback - Device functions
        *******************************************************************************************************/
        /** Callback - Device functions
        * Device functions primarly used in callback environments.
        */

        /*!
         * \brief Creates a device in the internal devicelist. If the ::openPorts function has been called with the liveMode = 1 the kernel immediatedly starts to monitor the device.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param waitReady
                 \arg 0 Don't wait for the device being ready.
                 \arg 1 Wait up to 2 seconds for the device to complete its analyze cycle. (All standard registers being successfully read) 
         * \return A status result value ::DeviceResultTypes
         */
        // extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceCreate(const char *portname, const unsigned char devId, const char waitReady);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern DeviceResultTypes deviceCreate([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte waitReady);

        /*!
         * \brief Checks if a specific device already exists in the internal devicelist.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param exists Pointer to an unsigned char where the function will store the exists status.
                 \arg 0 Device does not exists.
                 \arg 1 Device exists.
         * \return A status result value ::DeviceResultTypes
         */
        // extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceExists(const char *portname, const unsigned char devId, unsigned char *exists);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern DeviceResultTypes deviceExists([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, ref byte exists);

        /*!
         * \brief Remove a specific device from the internal devicelist.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \return A status result value ::DeviceResultTypes
         */
        // extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceRemove(const char *portname, const unsigned char devId);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern DeviceResultTypes deviceRemove([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId);

        /*!
         * \brief Remove all devices from the internal devicelist. No confirmation given, the list is simply cleared.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \return A status result value ::DeviceResultTypes
         */
        // extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceRemoveAll(const char *portname);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern DeviceResultTypes deviceRemoveAll([MarshalAs(UnmanagedType.LPStr)]String portname);

        /*!
         * \brief Returns a list with device types (module types) from the internal devicelist.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param types Pointer to a preallocated area where the function stores the list of module types. The default list size is 256 bytes long (0-255) where each position indicates module address, containing 0 for no module or the module type for addresses having a module.\n
         *  ex. 00h 61h 62h 63h 64h 65h 00h 00h 00h 00h 00h 00h 00h 00h 00h 60h 00h 00h etc.\n
         * Indicates module type 61h at address 1, module type 62h at address 2 etc. and module type 60h at address 15
         * \param maxTypes Pointer to an unsigned char giving the maximum number of types to retrieve.
                   The returned list may be truncated to fit into the allocated area.
         * \return A status result value ::DeviceResultTypes
         */
        // extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetAllTypes(const char *portname, unsigned char *types, unsigned char *maxTypes);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern DeviceResultTypes deviceGetAllTypes([MarshalAs(UnmanagedType.LPStr)]String portname, [MarshalAs(UnmanagedType.LPArray,SizeParamIndex=2)]byte[] types, ref byte maxTypes);

        /*!
         * \brief Returns the internal device mode for a specific device id (module address).
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId Given device id to retrieve device mode for.
         * \param devMode Pointer to an unsigned char where the function stores the device mode. ::DeviceModeTypes
         * \return A status result value ::DeviceResultTypes
         * \note Requires the port being already opened with the ::openPorts function and the device being already created, either automatically or with the ::deviceCreate function.
         */
        // extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetMode(const char *portname, const unsigned char devId, unsigned char *devMode);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern DeviceResultTypes deviceGetMode([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, ref byte devMode);

        /*!
         * \brief Returns the internal device live status for a specific device id (module address).
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId Given device id to retrieve liveMode.
         * \param liveMode Pointer to an unsigned char where the function stores the live status.
                   \arg 0 liveMode off
                   \arg 1 liveMode on
         * \return A status result value ::DeviceResultTypes
         * \note Requires the port being already opened with the ::openPorts function and the device being already created, either automatically or with the ::deviceCreate function.
         */
        // extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetLive(const char *portname, const unsigned char devId, unsigned char *liveMode);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern DeviceResultTypes deviceGetLive([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, ref byte liveMode);

        /*!
         * \brief Sets the internal device live status for a specific device id (module address).
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId Given device id to set liveMode on.
         * \param liveMode An unsigned char giving the new live status.
                   \arg 0 liveMode off
                   \arg 1 liveMode on
         * \return A status result value ::DeviceResultTypes
         * \note Requires the port being already opened with the ::openPorts function and the device being already created, either automatically or with the ::deviceCreate function.
         */
        // extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceSetLive(const char *portname, const unsigned char devId, const unsigned char liveMode);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern DeviceResultTypes deviceSetLive([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte liveMode);


        /*******************************************************************************************************
        * Callback - Register functions
        *******************************************************************************************************/
        /** Callback - Register functions
        */

        /*!
         * \brief Creates a register in the internal registerlist. If the ::openPorts function has been called with the liveMode = 1 the kernel immediatedly starts to monitor the register.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regId The register id (register address).
         * \param priority The ::RegisterPriorityTypes (monitoring priority).
         * \param dataType The ::RegisterDataTypes, not used internally but could be used in a common callback function to determine data type.
         * \return A status result value ::RegisterResultTypes
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerCreate(const char *portname, const unsigned char devId, const unsigned char regId, const RegisterPriorityTypes priority, const RegisterDataTypes dataType);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerCreate([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, RegisterPriorityTypes priority, RegisterDataTypes dataType);

        /*!
         * \brief Checks if a specific register already exists in the internal registerlist.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regId The register id (register address).
         * \param exists Pointer to an unsigned char where the function will store the exists status.
                 \arg 0 Register does not exists.
                 \arg 1 Register exists.
         * \return A status result value ::RegisterResultTypes
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerExists(const char *portname, const unsigned char devId, const unsigned char regId, unsigned char *exists);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerExists([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, ref byte exists);

        /*!
         * \brief Remove a specific register from the internal registerlist.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regId The register id (register address).
         * \return A status result value ::RegisterResultTypes
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerRemove(const char *portname, const unsigned char devId, const unsigned char regId);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerRemove([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId);

        /*!
         * \brief Remove all registers from the internal registerlist. No confirmation given, the list is simply cleared.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \return A status result value ::RegisterResultTypes
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerRemoveAll(const char *portname, const unsigned char devId);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerRemoveAll([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId);

        /*!
         * \brief Returns a list with register ids (register addresses) from the internal registerlist.
         * \param portname Zero terminated string giving the portname (case sensitive).
         * \param devId The device id (module address).
         * \param regs Pointer to a preallocated area where the function stores the list of registers ids (register addresses).
         * \param maxRegs Pointer to an unsigned char giving the maximum number of register ids to retrieve.
                  Modified by the function to reflect the actual number of register ids returned. The returned list may be truncated to fit into the allocated area.
         * \return A status result value ::RegisterResultTypes
         */
        // extern "C" NKTPDLL_EXPORT RegisterResultTypes registerGetAll(const char *portname, const unsigned char devId, unsigned char *regs, unsigned char *maxRegs);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern RegisterResultTypes registerGetAll([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, [MarshalAs(UnmanagedType.LPArray,SizeParamIndex=3)]byte[] regs, ref byte maxRegs);


        /*******************************************************************************************************
         * Callback - Support functions
         *******************************************************************************************************/

        /*!
         * \brief Defines the PortStatusCallbackFuncPtr for the ::openPorts and ::closePorts functions.
         * \param portname Zero terminated string giving the current portname.
         * \param status The current port status as ::PortStatusTypes
         * \param curScanAdr When status is ::PortScanProgress or ::PortScanDeviceFound this indicates the current module address scanned or found.
         * \param maxScanAdr When status is ::PortScanProgress or ::PortScanDeviceFound this indicates the last module address to be scanned.
         * \param foundType When status is ::PortScanDeviceFound this value will represent the found module type.
         * \note Please note that due to risk of circular runaway leading to stack overflow, it is not allowed to call functions in the DLL from within the callback function.
         * If a call is made to a function in the DLL the function will therefore return an application busy error.
         */
        // typedef void (__cdecl *PortStatusCallbackFuncPtr)(const char* portname,           // current port name
        //                                                   const PortStatusTypes status,   // current port status
        //                                                   const unsigned char curScanAdr, // current scanned address or device found address
        //                                                   const unsigned char maxScanAdr, // total addresses to scan
        //                                                   const unsigned char foundType); // device found type
        [UnmanagedFunctionPointer(CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public delegate void PortStatusCallbackFuncPtr([MarshalAs(UnmanagedType.LPStr)]String portname, PortStatusTypes status, byte curScanAdr, byte maxScanAdr, byte foundType);

        /*!
         * \brief Enables/Disables callback for port status changes.
         * \param callback The ::PortStatusCallbackFuncPtr function pointer. Disable callbacks by parsing in a zero value.
         */
        // extern "C" NKTPDLL_EXPORT void setCallbackPtrPortInfo(PortStatusCallbackFuncPtr callback);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern void setCallbackPtrPortInfo(PortStatusCallbackFuncPtr callback);


        /*!
         * \brief Defines the DeviceStatusCallbackFuncPtr for the devices created or connected with the ::deviceCreate function.
         * \param portname Zero terminated string giving the current portname.
         * \param devId The device id (module address).
         * \param status The current port status as ::DeviceStatusTypes
         * \note Please note that due to risk of circular runaway leading to stack overflow, it is not allowed to call functions in the DLL from within the callback function.
         * If a call is made to a function in the DLL the function will therefore return an application busy error.
         */
        // typedef void (__cdecl *DeviceStatusCallbackFuncPtr)(const char* portname,                     // current port name
        //                                                     const unsigned char devId,                // current device id
        //                                                     const DeviceStatusTypes status,           // current device status
        //                                                     const unsigned char devDataLen,           // number of bytes in devData
        //                                                     const void* devData);                     // device data as specified in status
        [UnmanagedFunctionPointer(CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public delegate void DeviceStatusCallbackFuncPtr([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, DeviceStatusTypes status, byte devDataLen, [MarshalAs(UnmanagedType.LPArray,SizeParamIndex=3)]byte[] devData);

        /*!
         * \brief Enables/Disables callback for device status changes.
         * \param callback The ::DeviceStatusCallbackFuncPtr function pointer. Disable callbacks by parsing in a zero value.
         */
        // extern "C" NKTPDLL_EXPORT void setCallbackPtrDeviceInfo(DeviceStatusCallbackFuncPtr callback);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern void setCallbackPtrDeviceInfo(DeviceStatusCallbackFuncPtr callback);


        /*!
         * \brief Defines the RegisterStatusCallbackFuncPtr for the registers created or connected with the ::registerCreate function.
         * \param portname Zero terminated string giving the current portname.
         * \param status The current register status as ::RegisterStatusTypes
         * \param regType The ::RegisterDataTypes, not used internally but could be used in a common callback function to determine data type.
         * \param regDataLen Number of databytes.
         * \param regData The register data.
         * \note Please note that due to risk of circular runaway leading to stack overflow, it is not allowed to to call functions in the DLL from within the callback function.
         * If a call is made to a function in the DLL the function will therefore return an application busy error.
         */
        // typedef void (__cdecl *RegisterStatusCallbackFuncPtr)(const char* portname,                       // current port name
        //                                                       const unsigned char devId,                  // current device id
        //                                                       const unsigned char regId,                  // current device id
        //                                                       const RegisterStatusTypes status,           // current register status
        //                                                       const RegisterDataTypes regType,            // current register type
        //                                                       const unsigned char regDataLen,             // number of bytes in regData
        //                                                       const void *regData);                       // register data
        [UnmanagedFunctionPointer(CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public delegate void RegisterStatusCallbackFuncPtr([MarshalAs(UnmanagedType.LPStr)]String portname, byte devId, byte regId, RegisterStatusTypes status, RegisterDataTypes regType, byte regDataLen, [MarshalAs(UnmanagedType.LPArray,SizeParamIndex=5)]byte[] regData);

        /*!
         * \brief Enables/Disables callback for register status changes.
         * \param callback The ::RegisterStatusCallbackFuncPtr function pointer. Disable callbacks by parsing in a zero value.
         */
        // extern "C" NKTPDLL_EXPORT void setCallbackPtrRegisterInfo(RegisterStatusCallbackFuncPtr callback);
        [DllImport("NKTPDLL.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern void setCallbackPtrRegisterInfo(RegisterStatusCallbackFuncPtr callback);




    }

}

