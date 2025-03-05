Imports System.IO
Imports System.Runtime.InteropServices
Imports System.Text

Public Class NKTPDLL

    ' Try preloading the OS related DLL, x86 or x64 version.
    ' Alternatively copy the correct version into your applications folder.

    <DllImport("kernel32.dll", SetLastError:=True)> _
    Private Shared Function LoadLibrary(ByVal lpFileName As String) As IntPtr
    End Function

    Private Shared refUnmanaged As IntPtr

    Shared Sub New()
        Dim dllFolder As String = Environment.GetEnvironmentVariable("NKTP_SDK_PATH")
        Dim subfolder As String
        If (IntPtr.Size = 8) Then
            subfolder = "\\NKTPDLL\\x64\\"
        Else
            subfolder = "\\NKTPDLL\\x86\\"
        End If
        refUnmanaged = LoadLibrary(dllFolder & subfolder & "NKTPDLL.dll")
    End Sub

    ' The PortResultTypes enum
    Enum PortResultTypes As Byte
        OPSuccess = 0
        OPFailed = 1
        OPPortNotFound = 2
        OPNoDevices = 3
        OPApplicationBusy = 4
    End Enum

    ' The PointToPointPortStatus enum
    Enum P2PPortResultTypes As Byte
        P2PSuccess = 0
        P2PInvalidPortname = 1
        P2PInvalidLocalIP = 2
        P2PInvalidRemoteIP = 3
        P2PPortnameNotFound = 4
        P2PPortnameExists = 5
        P2PApplicationBusy = 6
    End Enum

    ' The DeviceResultTypes enum
    Enum DeviceResultTypes As Byte
        DevResultSuccess = 0
        DevResultWaitTimeout = 1
        DevResultFailed = 2
        DevResultDeviceNotFound = 3
        DevResultPortNotFound = 4
        DevResultPortOpenError = 5
        DevResultApplicationBusy = 6
    End Enum

    ' The DeviceModeTypes enum
    Enum DeviceModeTypes As Byte
        DevModeDisabled = 0
        DevModeAnalyzeInit = 1
        DevModeAnalyze = 2
        DevModeNormal = 3
        DevModeLogDownload = 4
        DevModeError = 5
        DevModeTimeout = 6
        DevModeUpload = 7
    End Enum

    ' The RegisterResultTypes enum
    Enum RegisterResultTypes As Byte
        RegResultSuccess = 0
        RegResultReadError = 1
        RegResultFailed = 2
        RegResultBusy = 3
        RegResultNacked = 4
        RegResultCRCErr = 5
        RegResultTimeout = 6
        RegResultComError = 7
        RegResultTypeError = 8
        RegResultIndexError = 9
        RegResultPortClosed = 10
        RegResultRegisterNotFound = 11
        RegResultDeviceNotFound = 12
        RegResultPortNotFound = 13
        RegResultPortOpenError = 14
        RegResultApplicationBusy = 15
    End Enum

    ' The RegisterDataTypes enum
    Enum RegisterDataTypes As Byte
        RegData_Unknown = 0
        RegData_Array = 1
        RegData_U8 = 2
        RegData_S8 = 3
        RegData_U16 = 4
        RegData_S16 = 5
        RegData_U32 = 6
        RegData_S32 = 7
        RegData_F32 = 8
        RegData_U64 = 9
        RegData_S64 = 10
        RegData_F64 = 11
        RegData_Ascii = 12
        RegData_Paramset = 13
        RegData_B8 = 14
        RegData_H8 = 15
        RegData_B16 = 16
        RegData_H16 = 17
        RegData_B32 = 18
        RegData_H32 = 19
        RegData_B64 = 20
        RegData_H64 = 21
        RegData_DateTime = 22
    End Enum

    ' The RegisterPriorityTypes enum
    Enum RegisterPriorityTypes As Byte
        RegPriority_Low = 0
        RegPriority_High = 1
    End Enum

    ' The PortStatusTypes enum
    Enum PortStatusTypes As Byte
        PortStatusUnknown = 0
        PortOpening = 1
        PortOpened = 2
        PortOpenFail = 3
        PortScanStarted = 4
        PortScanProgress = 5
        PortScanDeviceFound = 6
        PortScanEnded = 7
        PortClosing = 8
        PortClosed = 9
        PortReady = 10
    End Enum

    ' The DeviceStatusTypes enum
    Enum DeviceStatusTypes As Byte
        DeviceModeChanged = 0           '  0 - devData contains 1 unsigned byte ::DeviceModeTypes
        DeviceLiveChanged = 1           '  1 - devData contains 1 unsigned byte, 0=live off, 1=live on.
        DeviceTypeChanged = 2           '  2 - devData contains 1 unsigned byte with DeviceType (module type).
        DevicePartNumberChanged = 3     '  3 - devData contains a string with partnumber.
        DevicePCBVersionChanged = 4     '  4 - devData contains 1 unsigned byte with PCB version number.
        DeviceStatusBitsChanged = 5     '  5 - devData contains 1 unsigned long with statusbits.
        DeviceErrorCodeChanged = 6      '  6 - devData contains 1 unsigned short with errorcode.
        DeviceBlVerChanged = 7          '  7 - devData contains a string with Bootloader version.
        DeviceFwVerChanged = 8          '  8 - devData contains a string with Firmware version.
        DeviceModuleSerialChanged = 9   '  9 - devData contains a string with Module serialnumber.
        DevicePCBSerialChanged = 10     ' 10 - devData contains a string with PCB serialnumber.
		DeviceSysTypeChanged = 11       ' 11 - devData contains 1 unsigned byte with SystemType (system type).
    End Enum

    ' The RegisterStatusTypes enum
    Enum RegisterStatusTypes As Byte
        RegSuccess = 0
        RegBusy = 1
        RegNacked = 2
        RegCRCErr = 3
        RegTimeout = 4
        RegComError = 5
    End Enum


    ' tDateTimeStruct, The DateTime struct 24 hour format
    <StructLayout(LayoutKind.Sequential, CharSet:=CharSet.Ansi, Pack:=1)>
    Structure tDateTimeStruct
        Public Sec As Byte
        Public Min As Byte
        Public Hour As Byte
        Public Day As Byte
        Public Month As Byte
        Public Year As Byte
    End Structure

    ' The ParamSetUnitTypes enum
    Enum ParamSetUnitTypes As Byte
        ' Unit codes
        UnitNone = 0        '  0 - none/unknown
        UnitmV = 1          '  1 - mV
        UnitV = 2           '  2 - V
        UnituA = 3          '  3 - µA
        UnitmA = 4          '  4 - mA
        UnitA = 5           '  5 - A
        UnituW = 6          '  6 - µW
        UnitcmW = 7         '  7 - mW/100
        UnitdmW = 8         '  8 - mW/10
        UnitmW = 9          '  9 - mW
        UnitW = 10          ' 10 - W
        UnitmC = 11         ' 11 - °C/1000
        UnitcC = 12         ' 12 - °C/100
        UnitdC = 13         ' 13 - °C/10
        Unitpm = 14         ' 14 - pm
        Unitdnm = 15        ' 15 - nm/10
        Unitnm = 16         ' 16 - nm
        UnitPerCent = 17    ' 17 - %
        UnitPerMille = 18   ' 18 - ‰
        UnitcmA = 19        ' 19 - mA/100
        UnitdmA = 20        ' 20 - mA/10
        UnitRPM = 21        ' 21 - RPM
        UnitdBm = 22        ' 22 - dBm
        UnitcBm = 23        ' 23 - dBm/10
        UnitmBm = 24        ' 24 - dBm/100
        UnitdB = 25         ' 25 - dB
        UnitcB = 26         ' 26 - dB/10
        UnitmB = 27         ' 27 - dB/100
        Unitdpm = 28        ' 28 - pm/10
        UnitcV = 29         ' 29 - V/100
        UnitdV = 30         ' 30 - V/10
        Unitlm = 31         ' 31 - lm (lumen)
        Unitdlm = 32        ' 32 - lm/10
        Unitclm = 33        ' 33 - lm/100
        Unitmlm = 34        ' 34 - lm/1000
    End Enum

    ' The ParameterSet struct
    ' How calculation on parametersets is done internally by modules:
    ' DAC_value = (value * (X/Y)) + Offset; Where value is either StartVal or FactoryVal
    ' value = (ADC_value * (X/Y)) + Offset; Where value often is available via another measurement register
    <StructLayout(LayoutKind.Sequential, CharSet:=CharSet.Ansi, Pack:=1)>
    Structure tParamSetStruct
        Public Unit As ParamSetUnitTypes    ' Unit type as defined in ParamSetUnitTypes
        Public ErrorHandler As Byte         ' Warning/Errorhandler not used.
        Public StartVal As UShort           ' Setpoint for Settings parameterset, unused in Measurement parametersets.
        Public FactoryVal As UShort         ' Factory Setpoint for Settings parameterset, unused in Measurement parametersets.
        Public ULimit As UShort             ' Upper limit.
        Public LLimit As UShort             ' Lower limit.
        Public Numerator As Short           ' Numerator(X) for calculation.
        Public Denominator As Short         ' Denominator(Y) for calculation.
        Public Offset As Short              ' Offset for calculation
    End Structure


    '*******************************************************************************************************
    ' Helper functions
    '*******************************************************************************************************

    Public Shared Function getPortResultMsg(ByVal result As PortResultTypes) As String
        Select Case result
            Case PortResultTypes.OPSuccess : Return result.ToString() + ":Success"
            Case PortResultTypes.OPFailed : Return result.ToString() + ":Failed"
            Case PortResultTypes.OPPortNotFound : Return result.ToString() + ":Port not found"
            Case PortResultTypes.OPNoDevices : Return result.ToString() + ":Success, but no devices found"
            Case PortResultTypes.OPApplicationBusy : Return result.ToString() + ":Application busy - Call orginating from callback function, not allowed"
            Case Else
                Return "Unknown result:" + result.ToString()
        End Select
    End Function

    Public Shared Function getP2PPortResultMsg(ByVal result As P2PPortResultTypes) As String
        Select Case result
            Case P2PPortResultTypes.P2PSuccess : Return result.ToString() + ":Success"
            Case P2PPortResultTypes.P2PInvalidPortname : Return result.ToString() + ":Invalid portname"
            Case P2PPortResultTypes.P2PInvalidLocalIP : Return result.ToString() + ":Invalid local IP"
            Case P2PPortResultTypes.P2PInvalidRemoteIP : Return result.ToString() + ":Invalid remote IP"
            Case P2PPortResultTypes.P2PPortnameNotFound : Return result.ToString() + ":Portname not found"
            Case P2PPortResultTypes.P2PPortnameExists : Return result.ToString() + ":Portname already exists"
            Case P2PPortResultTypes.P2PApplicationBusy : Return result.ToString() + ":Application busy - Call orginating from callback function, not allowed"
            Case Else
                Return "Unknown result:" + result.ToString()
        End Select
    End Function

    Public Shared Function getRegisterResultMsg(ByVal result As RegisterResultTypes) As String
        Select Case result
            Case RegisterResultTypes.RegResultSuccess : Return result.ToString() + ":Success"
            Case RegisterResultTypes.RegResultReadError : Return result.ToString() + ":ReadError"
            Case RegisterResultTypes.RegResultFailed : Return result.ToString() + ":Failed"
            Case RegisterResultTypes.RegResultBusy : Return result.ToString() + ":Busy"
            Case RegisterResultTypes.RegResultNacked : Return result.ToString() + ":Nacked"
            Case RegisterResultTypes.RegResultCRCErr : Return result.ToString() + ":CRCError"
            Case RegisterResultTypes.RegResultTimeout : Return result.ToString() + ":Timeout"
            Case RegisterResultTypes.RegResultComError : Return result.ToString() + ":ComError"
            Case RegisterResultTypes.RegResultTypeError : Return result.ToString() + ":TypeError"
            Case RegisterResultTypes.RegResultIndexError : Return result.ToString() + ":IndexError"
            Case RegisterResultTypes.RegResultPortClosed : Return result.ToString() + ":PortClosed"
            Case RegisterResultTypes.RegResultRegisterNotFound : Return result.ToString() + ":RegisterNotFound"
            Case RegisterResultTypes.RegResultDeviceNotFound : Return result.ToString() + ":DeviceNotFound"
            Case RegisterResultTypes.RegResultPortNotFound : Return result.ToString() + ":PortNotFound"
            Case RegisterResultTypes.RegResultPortOpenError : Return result.ToString() + ":PortOpenError"
            Case RegisterResultTypes.RegResultApplicationBusy : Return result.ToString() + ":ApplicationBusy - Call orginating from callback function, not allowed"
            Case Else
                Return "Unknown result:" + result.ToString()
        End Select
    End Function

    Public Shared Function getRegisterDataTypeMsg(ByVal dataType As RegisterDataTypes) As String
        Select Case dataType
            Case NKTPDLL.RegisterDataTypes.RegData_Unknown : Return dataType.ToString() & ":Unknown datatype"
            Case NKTPDLL.RegisterDataTypes.RegData_Array : Return dataType.ToString() & "Array datatype"
            Case NKTPDLL.RegisterDataTypes.RegData_U8 : Return dataType.ToString() & "U8 datatype"
            Case NKTPDLL.RegisterDataTypes.RegData_S8 : Return dataType.ToString() & "S8 datatype"
            Case NKTPDLL.RegisterDataTypes.RegData_U16 : Return dataType.ToString() & "U16 datatype"
            Case NKTPDLL.RegisterDataTypes.RegData_S16 : Return dataType.ToString() & "S16 datatype"
            Case NKTPDLL.RegisterDataTypes.RegData_U32 : Return dataType.ToString() & "U32 datatype"
            Case NKTPDLL.RegisterDataTypes.RegData_S32 : Return dataType.ToString() & "S32 datatype"
            Case NKTPDLL.RegisterDataTypes.RegData_F32 : Return dataType.ToString() & "F32 datatype"
            Case NKTPDLL.RegisterDataTypes.RegData_U64 : Return dataType.ToString() & "U64 datatype"
            Case NKTPDLL.RegisterDataTypes.RegData_S64 : Return dataType.ToString() & "S64 datatype"
            Case NKTPDLL.RegisterDataTypes.RegData_F64 : Return dataType.ToString() & "F64 datatype"
            Case NKTPDLL.RegisterDataTypes.RegData_Ascii : Return dataType.ToString() & "Ascii datatype"
            Case NKTPDLL.RegisterDataTypes.RegData_Paramset : Return dataType.ToString() & "Paramset datatype"
            Case NKTPDLL.RegisterDataTypes.RegData_B8 : Return dataType.ToString() & "B8 datatype"
            Case NKTPDLL.RegisterDataTypes.RegData_H8 : Return dataType.ToString() & "H8 datatype"
            Case NKTPDLL.RegisterDataTypes.RegData_B16 : Return dataType.ToString() & "B16 datatype"
            Case NKTPDLL.RegisterDataTypes.RegData_H16 : Return dataType.ToString() & "H16 datatype"
            Case NKTPDLL.RegisterDataTypes.RegData_B32 : Return dataType.ToString() & "B32 datatype"
            Case NKTPDLL.RegisterDataTypes.RegData_H32 : Return dataType.ToString() & "H32 datatype"
            Case NKTPDLL.RegisterDataTypes.RegData_B64 : Return dataType.ToString() & "B64 datatype"
            Case NKTPDLL.RegisterDataTypes.RegData_H64 : Return dataType.ToString() & "H64 datatype"
            Case NKTPDLL.RegisterDataTypes.RegData_DateTime : Return dataType.ToString() & "DateTime datatype"
            Case Else
                Return "Unknown datatype:" & dataType.ToString()
        End Select
    End Function


    Public Shared Function getDeviceResultMsg(ByVal result As DeviceResultTypes) As String
        Select Case result
            Case DeviceResultTypes.DevResultSuccess : Return result.ToString() + ":Success"
            Case DeviceResultTypes.DevResultWaitTimeout : Return result.ToString() + ":Timeout"
            Case DeviceResultTypes.DevResultFailed : Return result.ToString() + ":Failed"
            Case DeviceResultTypes.DevResultDeviceNotFound : Return result.ToString() + ":DeviceNotFound"
            Case DeviceResultTypes.DevResultPortNotFound : Return result.ToString() + ":PortNotFound"
            Case DeviceResultTypes.DevResultPortOpenError : Return result.ToString() + ":PortOpenErr"
            Case DeviceResultTypes.DevResultApplicationBusy : Return result.ToString() + ":ApplicationBusy - Call orginating from callback function, not allowed"
            Case Else
                Return "Unknown result:" + result.ToString()
        End Select
    End Function

    Public Shared Function getPortStatusMsg(ByVal status As PortStatusTypes) As String
        Select Case status
            Case PortStatusTypes.PortStatusUnknown : Return status.ToString + ":PortStatusUnknown"
            Case PortStatusTypes.PortOpening : Return status.ToString() + ":PortOpening"
            Case PortStatusTypes.PortOpened : Return status.ToString() + ":PortOpened"
            Case PortStatusTypes.PortOpenFail : Return status.ToString() + ":PortOpenFail"
            Case PortStatusTypes.PortScanStarted : Return status.ToString() + ":PortScanStarted"
            Case PortStatusTypes.PortScanProgress : Return status.ToString() + ":PortScanProgress"
            Case PortStatusTypes.PortScanDeviceFound : Return status.ToString() + ":PortScanDeviceFound"
            Case PortStatusTypes.PortScanEnded : Return status.ToString() + ":PortScanEnded"
            Case PortStatusTypes.PortClosing : Return status.ToString() + ":PortClosing"
            Case PortStatusTypes.PortClosed : Return status.ToString() + ":PortClosed"
            Case PortStatusTypes.PortReady : Return status.ToString() + ":PortReady"
            Case Else
                Return "Unknown status:" + status.ToString()
        End Select
    End Function

    Public Shared Function getDeviceStatusMsg(ByVal status As DeviceStatusTypes) As String
        Select Case status
            Case DeviceStatusTypes.DeviceModeChanged : Return status.ToString() + ":DeviceModeChanged"
            Case DeviceStatusTypes.DeviceLiveChanged : Return status.ToString() + ":DeviceLiveChanged"
            Case DeviceStatusTypes.DeviceTypeChanged : Return status.ToString() + ":DeviceTypeChanged"
            Case DeviceStatusTypes.DevicePartNumberChanged : Return status.ToString() + ":DevicePartNumberChanged"
            Case DeviceStatusTypes.DevicePCBVersionChanged : Return status.ToString() + ":DevicePCBVersionChanged"
            Case DeviceStatusTypes.DeviceStatusBitsChanged : Return status.ToString() + ":DeviceStatusBitsChanged"
            Case DeviceStatusTypes.DeviceErrorCodeChanged : Return status.ToString() + ":DeviceErrorCodeChanged"
            Case DeviceStatusTypes.DeviceBlVerChanged : Return status.ToString() + ":DeviceBlVerChanged"
            Case DeviceStatusTypes.DeviceFwVerChanged : Return status.ToString() + ":DeviceFwVerChanged"
            Case DeviceStatusTypes.DeviceModuleSerialChanged : Return status.ToString() + ":DeviceModuleSerialChanged"
            Case DeviceStatusTypes.DevicePCBSerialChanged : Return status.ToString() + ":DevicePCBSerialChanged"
            Case Else
                Return "Unknown status:" + status.ToString()
        End Select
    End Function

    Public Shared Function getRegisterStatusMsg(ByVal status As RegisterStatusTypes) As String
        Select Case status
            Case RegisterStatusTypes.RegSuccess : Return status.ToString() + ":RegSuccess"
            Case RegisterStatusTypes.RegBusy : Return status.ToString() + ":RegBusy"
            Case RegisterStatusTypes.RegNacked : Return status.ToString() + ":RegNacked"
            Case RegisterStatusTypes.RegCRCErr : Return status.ToString() + ":RegCRCErr"
            Case RegisterStatusTypes.RegTimeout : Return status.ToString() + ":RegTimeout"
            Case RegisterStatusTypes.RegComError : Return status.ToString() + ":RegComError"
            Case Else
                Return "Unknown status:" + status.ToString()
        End Select
    End Function


    '*******************************************************************************************************
    ' Port functions
    '*******************************************************************************************************

    ' \brief Returns a comma separated string with all existing ports.
    ' \param portnames Pointer to a preallocated string area where the function will store the comma separated string.
    ' \param maxLen Size of preallocated string area. The returned string may be truncated to fit into the allocated area.
    '
    ' extern "C" NKTPDLL_EXPORT void getAllPorts(char *portnames, unsigned short *maxLen);
    <DllImport("NKTPDLL.dll", EntryPoint:="getAllPorts", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Sub getAllPorts(<MarshalAs(UnmanagedType.LPStr)> ByVal portnames As StringBuilder, ByRef maxLen As UShort)
    End Sub

    ' \brief Returns a comma separated string with all allready opened ports.
    ' \param portnames Pointer to a preallocated string area where the function will store the comma separated string.
    ' \param maxLen Size of preallocated string area. The returned string may be truncated to fit into the allocated area.
    '
    ' extern "C" NKTPDLL_EXPORT void getOpenPorts(char *portnames, unsigned short *maxLen);
    <DllImport("NKTPDLL.dll", EntryPoint:="getOpenPorts", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Sub getOpenPorts(<MarshalAs(UnmanagedType.LPStr)> ByVal portnames As StringBuilder, ByRef maxLen As UShort)
    End Sub

    ' \brief Creates or Modifies a point to point port.
    ' \param portname Zero terminated string giving the portname. ex. "AcoustikPort1"
    ' \param hostAddress Zero terminated string giving the local ip address. ex. "192.168.1.67"
    ' \param hostPort The local port number.
    ' \param clientAddress Zero terminated string giving the remote ip address. ex. "192.168.1.100"
    ' \param clientPort The remote port number.
    ' \param protocol \arg 0 Specifies TCP protocol.
    '                 \arg 1 Specifies UDP protocol.
    ' \param msTimeout Telegram timeout value in milliseconds, typically set to 100ms.
    ' \return ::P2PPortResultTypes
    '
    ' extern "C" NKTPDLL_EXPORT P2PPortResultTypes pointToPointPortAdd(const char *portname, const char *hostAddress, const unsigned short hostPort, const char *clientAddress, const unsigned short clientPort, const unsigned char protocol, const unsigned char msTimeout);
    <DllImport("NKTPDLL.dll", EntryPoint:="pointToPointPortAdd", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function pointToPointPortAdd(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, <MarshalAs(UnmanagedType.LPStr)> ByVal hostAddress As String, ByVal hostPort As UShort, <MarshalAs(UnmanagedType.LPStr)> ByVal clientAddress As String, ByVal clientPort As UShort, ByVal protocol As Byte, ByVal msTimeout As Byte) As P2PPortResultTypes
    End Function

    ' \brief Retrieve an already created point to point port setting.
    ' \param portname Zero terminated string giving the portname (case sensitive). ex. "AcoustikPort1"
    ' \param hostAddress Pointer to a preallocated string area where the function will store the zero terminated string, describing the local ip address.
    ' \param hostMaxLen Pointer to an unsigned char giving the size of the preallocated hostAddress area, modified by the function to reflect the actual length of the returned string. The returned string may be truncated to fit into the allocated area.
    ' \param hostPort Pointer to a preallocated short where the function will store the local port number.
    ' \param clientAddress Pointer to a preallocated string area where the function will store the zero terminated string, describing the remote ip address.
    ' \param clientMaxLen Pointer to an unsigned char giving the size of the preallocated clientAddress area, modified by the function to reflect the actual length of the returned string. The returned string may be truncated to fit into the allocated area.
    ' \param clientPort Pointer to a preallocated short where the function will store the client port number.
    ' \param protocol Pointer to a preallocated char where the function will store the protocol.
    '               \arg 0 Specifies TCP protocol.
    '               \arg 1 Specifies UDP protocol.
    ' \param msTimeout Pointer to a preallocated char where the function will store the timeout value.
    ' \return ::P2PPortResultTypes
    '
    ' extern "C" NKTPDLL_EXPORT P2PPortResultTypes pointToPointPortGet(const char *portname, char *hostAddress, unsigned char *hostMaxLen, unsigned short *hostPort, char *clientAddress, unsigned char *clientMaxLen, unsigned short *clientPort, unsigned char *protocol, unsigned char *msTimeout);
    <DllImport("NKTPDLL.dll", EntryPoint:="pointToPointPortGet", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function pointToPointPortGet(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, <MarshalAs(UnmanagedType.LPStr)> ByVal hostAddress As StringBuilder, ByRef hostMaxLen As Byte, ByRef hostPort As UShort, <MarshalAs(UnmanagedType.LPStr)> ByVal clientAddress As StringBuilder, ByRef clientMaxLen As Byte, ByRef clientPort As UShort, ByRef protocol As Byte, ByRef msTimeout As Byte) As P2PPortResultTypes
    End Function

    ' \brief Delete an already created point to point port.
    ' \param portname Zero terminated string giving the portname (case sensitive). ex. "AcoustikPort1"
    ' \return ::P2PPortResultTypes
    '
    ' extern "C" NKTPDLL_EXPORT P2PPortResultTypes pointToPointPortDel(const char *portname);
    <DllImport("NKTPDLL.dll", EntryPoint:="pointToPointPortDel", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function pointToPointPortDel(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String) As P2PPortResultTypes
    End Function

    ' \brief Opens the provided portname(s), or all available ports if an empty string provided. Repeatedly calls is allowed to reopen and/or rescan for devices.\n
    ' \param portnames Zero terminated comma separated string giving the portnames to open (case sensitive). An empty string opens all available ports.
    ' \param autoMode \arg 0 the openPorts function only opens the port. Busscanning and device creation is NOT automatically handled.
    '                 \arg 1 the openPorts function will automatically start the busscanning and create the found devices in the internal devicelist. The port is automatically closed if no devices found.
    ' \param liveMode \arg 0 the openPorts function disables the continuously monitoring of the registers. No callback possible on register changes. Use ::registerRead, ::registerWrite & ::registerWriteRead functions.
    '                 \arg 1 the openPorts function will keep all the found or created devices in live mode, which means the Interbus kernel keeps monitoring all the found devices and their registers.
    '                  Please note that this will keep the modules watchdog alive as long as the port is open.
    ' \return ::PortResultTypes
    ' \note The function may timeout after 2 seconds waiting for port ready status and return ::OPFailed.\n
    '       In case autoMode is specified this timeout is extended to 20 seconds to allow for busscanning to complete.
    '
    ' extern "C" NKTPDLL_EXPORT PortResultTypes openPorts(const char *portnames, const char autoMode, const char liveMode);
    <DllImport("NKTPDLL.dll", EntryPoint:="openPorts", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function openPorts(<MarshalAs(UnmanagedType.LPStr)> ByVal portnames As String, ByVal autoMode As Byte, ByVal liveMode As Byte) As PortResultTypes
    End Function

    ' \brief Closes the provided portname(s), or all opened ports if an empty string provided.
    ' \param portnames Zero terminated comma separated string giving the portnames to close (case sensitive). An empty string closes all open ports.
    ' \return ::PortResultTypes
    ' \note The function may timeout after 2 seconds waiting for port close to complete and return ::OPFailed.
    '
    ' extern "C" NKTPDLL_EXPORT PortResultTypes closePorts(const char *portnames);
    <DllImport("NKTPDLL.dll", EntryPoint:="closePorts", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function closePorts(<MarshalAs(UnmanagedType.LPStr)> ByVal portnames As String) As PortResultTypes
    End Function

    ' \brief Sets legacy busscanning on or off.
    ' \param legacyScanning \arg 0 the busscanning is set to normal mode and allows for rolling masterId. In this mode the masterId is changed for each message to allow for out of sync. detection.
    '                       \arg 1 the busscanning is set to legacy mode and fixes the masterId at address 66(0x42). Some older modules does not accept masterIds other than 66(ox42).
    ' extern "C" NKTPDLL_EXPORT void setLegacyBusScanning(const char legacyScanning);
    <DllImport("NKTPDLL.dll", EntryPoint:="setLegacyBusScanning", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Sub setLegacyBusScanning(ByVal legacyScanning As Byte)
    End Sub

    ' \brief Gets legacy busscanning status.
    ' \return An unsigned char, with legacyScanning status. 0 the busscanning is currently in normal mode. 1 the busscanning is currently in legacy mode.
    ' extern "C" NKTPDLL_EXPORT unsigned char getLegacyBusScanning();
    <DllImport("NKTPDLL.dll", EntryPoint:="getLegacyBusScanning", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function getLegacyBusScanning() As Byte
    End Function

    ' \brief Retrieve ::PortStatusTypes for a given port.
    ' \param portname Zero terminated string giving the portname (case sensitive). ex. "COM1"
    ' \param portStatus Pointer to a ::PortStatusTypes where the function will store the port status.
    ' \return ::PortResultTypes
    '
    ' extern "C" NKTPDLL_EXPORT PortResultTypes getPortStatus(const char *portname, PortStatusTypes *portStatus);
    <DllImport("NKTPDLL.dll", EntryPoint:="getPortStatus", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function getPortStatus(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByRef portStatus As PortStatusTypes) As PortResultTypes
    End Function

    ' \brief Retrieve error message for a given port. An empty string indicates no error.
    ' \param portname Zero terminated string giving the portname (case sensitive). ex. "COM1"
    ' \param errorMessage Pointer to a preallocated string area where the function will store the zero terminated error string.
    ' \param maxLen Pointer to an unsigned short giving the size of the preallocated string area, modified by the function to reflect the actual length of the returned string. The returned string may be truncated to fit into the allocated area.
    '
    ' extern "C" NKTPDLL_EXPORT PortResultTypes getPortErrorMsg(const char *portname, char *errorMessage, unsigned short *maxLen);
    <DllImport("NKTPDLL.dll", EntryPoint:="getPortErrorMsg", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function getPortErrorMsg(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, <MarshalAs(UnmanagedType.LPStr)> ByVal errorMessage As StringBuilder, ByRef maxLen As UShort) As PortResultTypes
    End Function


    '*******************************************************************************************************
    ' Dedicated - Register read functions
    '******************************************************************************************************/
    ' It is not necessary to open the port, create the device or register before using those functions, since they will do a dedicated action.
    ' Even though an already opened port would be preffered in time critical situations where a lot of reads is required.

    ' \brief Reads a register value and returns the result in readData area.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param readData Pointer to a preallocated data area where the function will store the register value.
    ' \param readSize Size of preallocated data area, modified by the function to reflect the actual length of the returned register value. The returned register value may be truncated to fit into the allocated area.
    ' \param index Data index. Typically -1, but could be used to extract data from a specific position in the register. Index is byte counted.
    ' \return A status result value ::RegisterResultTypes
    ' \sa ::registerReadU8, ::registerReadS8 etc.
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerRead(const char *portname, const unsigned char devId, const unsigned char regId, void *readData, unsigned char *readSize, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerRead", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerRead(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, <MarshalAs(UnmanagedType.LPArray, SizeParamIndex:=4)> ByRef readData As Byte(), ByRef readSize As Byte, ByVal index As Short) As RegisterResultTypes
    End Function

    ' \brief Reads an unsigned char (8bit) register value and returns the result in value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param value Pointer to an unsigned char where the function will store the register value.
    ' \param index Value index. Typically -1, but could be used to extract a value in a multi value register. Index is byte counted.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
    '
    'extern "C" NKTPDLL_EXPORT RegisterResultTypes registerReadU8(const char *portname, const unsigned char devId, const unsigned char regId, unsigned char *value, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerReadU8", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerReadU8(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByRef value As Byte, ByVal index As Short) As RegisterResultTypes
    End Function

    ' \brief Reads a signed char (8bit) register value and returns the result in value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param value Pointer to a signed char where the function will store the register value.
    ' \param index Value index. Typically -1, but could be used to extract a value in a multi value register. Index is byte counted.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerReadS8(const char *portname, const unsigned char devId, const unsigned char regId, signed char *value, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerReadS8", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerReadS8(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByRef value As SByte, ByVal index As Short) As RegisterResultTypes
    End Function

    ' \brief Reads an unsigned short (16bit) register value and returns the result in value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param value Pointer to an unsigned short where the function will store the register value.
    ' \param index Value index. Typically -1, but could be used to extract a value in a multi value register. Index is byte counted.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerReadU16(const char *portname, const unsigned char devId, const unsigned char regId, unsigned short *value, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerReadU16", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerReadU16(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByRef value As UInt16, ByVal index As Short) As RegisterResultTypes
    End Function


    ' \brief Reads a signed short (16bit) register value and returns the result in value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param value Pointer to a signed short where the function will store the register value.
    ' \param index Value index. Typically -1, but could be used to extract a value in a multi value register. Index is byte counted.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerReadS16(const char *portname, const unsigned char devId, const unsigned char regId, signed short *value, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerReadS16", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerReadS16(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByRef value As Int16, ByVal index As Short) As RegisterResultTypes
    End Function

    ' \brief Reads an unsigned long (32bit) register value and returns the result in value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param value Pointer to an unsigned long where the function will store the register value.
    ' \param index Value index. Typically -1, but could be used to extract a value in a multi value register. Index is byte counted.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerReadU32(const char *portname, const unsigned char devId, const unsigned char regId, unsigned long *value, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerReadU32", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerReadU32(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByRef value As UInt32, ByVal index As Short) As RegisterResultTypes
    End Function

    ' \brief Reads a signed long (32bit) register value and returns the result in value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param value Pointer to a signed long where the function will store the register value.
    ' \param index Value index. Typically -1, but could be used to extract a value in a multi value register. Index is byte counted.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerReadS32(const char *portname, const unsigned char devId, const unsigned char regId, signed long *value, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerReadS32", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerReadS32(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByRef value As Int32, ByVal index As Short) As RegisterResultTypes
    End Function


    ' \brief Reads an unsigned long long (64bit) register value and returns the result in value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param value Pointer to an unsigned long long where the function will store the register value.
    ' \param index Value index. Typically -1, but could be used to extract a value in a multi value register. Index is byte counted.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerReadU64(const char *portname, const unsigned char devId, const unsigned char regId, unsigned long long *value, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerReadU64", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerReadU64(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByRef value As UInt64, ByVal index As Short) As RegisterResultTypes
    End Function


    ' \brief Reads a signed long long (64bit) register value and returns the result in value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param value Pointer to a signed long long where the function will store the register value.
    ' \param index Value index. Typically -1, but could be used to extract a value in a multi value register. Index is byte counted.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerReadS64(const char *portname, const unsigned char devId, const unsigned char regId, signed long long *value, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerReadS64", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerReadS64(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByRef value As Int64, ByVal index As Short) As RegisterResultTypes
    End Function


    ' \brief Reads a float (32bit) register value and returns the result in value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param value Pointer to a float where the function will store the register value.
    ' \param index Value index. Typically -1, but could be used to extract a value in a multi value register. Index is byte counted.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerReadF32(const char *portname, const unsigned char devId, const unsigned char regId, float *value, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerReadF32", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerReadF32(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByRef value As Single, ByVal index As Short) As RegisterResultTypes
    End Function


    ' \brief Reads a double (64bit) register value and returns the result in value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param value Pointer to a double where the function will store the register value.
    ' \param index Value index. Typically -1, but could be used to extract a value in a multi value register. Index is byte counted.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerReadF64(const char *portname, const unsigned char devId, const unsigned char regId, double *value, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerReadF64", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerReadF64(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByRef value As Double, ByVal index As Short) As RegisterResultTypes
    End Function


    ' \brief Reads a Ascii string register value and returns the result in readStr area.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param readStr Pointer to a preallocated string area where the function will store the register value.
    ' \param maxLen Size of preallocated string area, modified by the function to reflect the actual length of the returned string. The returned string may be truncated to fit into the allocated area.
    ' \param index Value index. Typically -1, but could be used to extract a string in a mixed type register. Index is byte counted.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerReadAscii(const char *portname, const unsigned char devId, const unsigned char regId, char *readStr, unsigned char *maxLen, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerReadAscii", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerReadAscii(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, <MarshalAs(UnmanagedType.LPStr)> ByVal readStr As StringBuilder, ByRef maxLen As Byte, ByVal index As Short) As RegisterResultTypes
    End Function


    '*******************************************************************************************************
    ' Dedicated - Register write functions
    '*******************************************************************************************************
    ' It is not necessary to open the port, create the device or register before using those functions, since they will do a dedicated action.
    ' Even though an already opened port would be preffered in time critical situations where a lot of writes is required.

    ' \brief Writes a register value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param writeData Pointer to a data area from where the write value will be extracted.
    ' \param writeSize Size of data area, ex. number of bytes to write. Write size is limited to max 240 bytes
    ' \param index Data index. Typically -1, but could be used to write data at a specific position in the register. Index is byte counted.
    '                          Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
    '                          indexed content is modified and finally the complete content is written to the register.
    ' \return A status result value ::RegisterResultTypes
    ' \sa ::registerWriteU8, ::registerWriteS8 etc.
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWrite(const char *portname, const unsigned char devId, const unsigned char regId, const void *writeData, const unsigned char writeSize, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerWrite", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerWrite(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, <MarshalAs(UnmanagedType.LPArray)> ByVal writeData As Byte(), ByVal writeSize As Byte, ByVal index As Short) As RegisterResultTypes
    End Function


    ' \brief Writes an unsigned char (8bit) register value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param value The register value to write.
    ' \param index Value index. Typically -1, but could be used to write a value in a multi value register. Index is byte counted.
    '                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
    '                           indexed content is modified and finally the complete content is written to the register.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteU8(const char *portname, const unsigned char devId, const unsigned char regId, const unsigned char value, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerWriteU8", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerWriteU8(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByVal value As Byte, ByVal index As Short) As RegisterResultTypes
    End Function


    ' \brief Writes a signed char (8bit) register value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param value The register value to write.
    ' \param index Value index. Typically -1, but could be used to write a value in a multi value register. Index is byte counted.
    '                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
    '                           indexed content is modified and finally the complete content is written to the register.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteS8(const char *portname, const unsigned char devId, const unsigned char regId, const signed char value, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerWriteS8", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerWriteS8(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByVal value As SByte, ByVal index As Short) As RegisterResultTypes
    End Function


    ' \brief Writes an unsigned short (16bit) register value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param value The register value to write.
    ' \param index Value index. Typically -1, but could be used to write a value in a multi value register. Index is byte counted.
    '                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
    '                           indexed content is modified and finally the complete content is written to the register.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteU16(const char *portname, const unsigned char devId, const unsigned char regId, const unsigned short value, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerWriteU16", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerWriteU16(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByVal value As UInt16, ByVal index As Short) As RegisterResultTypes
    End Function


    ' \brief Writes a signed short (16bit) register value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param value The register value to write.
    ' \param index Value index. Typically -1, but could be used to write a value in a multi value register. Index is byte counted.
    '                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
    '                           indexed content is modified and finally the complete content is written to the register.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteS16(const char *portname, const unsigned char devId, const unsigned char regId, const signed short value, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerWriteS16", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerWriteS16(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByVal value As Int16, ByVal index As Short) As RegisterResultTypes
    End Function


    ' \brief Writes an unsigned long (32bit) register value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param value The register value to write.
    ' \param index Value index. Typically -1, but could be used to write a value in a multi value register. Index is byte counted.
    '                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
    '                           indexed content is modified and finally the complete content is written to the register.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteU32(const char *portname, const unsigned char devId, const unsigned char regId, const unsigned long value, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerWriteU32", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerWriteU32(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByVal value As UInt32, ByVal index As Short) As RegisterResultTypes
    End Function


    ' \brief Writes a signed long (32bit) register value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param value The register value to write.
    ' \param index Value index. Typically -1, but could be used to write a value in a multi value register. Index is byte counted.
    '                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
    '                           indexed content is modified and finally the complete content is written to the register.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteS32(const char *portname, const unsigned char devId, const unsigned char regId, const signed long value, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerWriteS32", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerWriteS32(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByVal value As Int32, ByVal index As Short) As RegisterResultTypes
    End Function


    ' \brief Writes an unsigned long long (64bit) register value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param value The register value to write.
    ' \param index Value index. Typically -1, but could be used to write a value in a multi value register. Index is byte counted.
    '                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
    '                           indexed content is modified and finally the complete content is written to the register.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteU64(const char *portname, const unsigned char devId, const unsigned char regId, const unsigned long long value, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerWriteU64", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerWriteU64(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByVal value As UInt64, ByVal index As Short) As RegisterResultTypes
    End Function


    ' \brief Writes a signed long long (64bit) register value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param value The register value to write.
    ' \param index Value index. Typically -1, but could be used to write a value in a multi value register. Index is byte counted.
    '                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
    '                           indexed content is modified and finally the complete content is written to the register.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteS64(const char *portname, const unsigned char devId, const unsigned char regId, const signed long long value, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerWriteS64", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerWriteS64(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByVal value As Int64, ByVal index As Short) As RegisterResultTypes
    End Function

    ' \brief Writes a float (32bit) register value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param value The register value to write.
    ' \param index Value index. Typically -1, but could be used to write a value in a multi value register. Index is byte counted.
    '                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
    '                           indexed content is modified and finally the complete content is written to the register.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteF32(const char *portname, const unsigned char devId, const unsigned char regId, const float value, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerWriteF32", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerWriteF32(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByVal value As Single, ByVal index As Short) As RegisterResultTypes
    End Function

    ' \brief Writes a double (64bit) register value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param value The register value to write.
    ' \param index Value index. Typically -1, but could be used to write a value in a multi value register. Index is byte counted.
    '                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
    '                           indexed content is modified and finally the complete content is written to the register.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteF64(const char *portname, const unsigned char devId, const unsigned char regId, const double value, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerWriteF64", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerWriteF64(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByVal value As Double, ByVal index As Short) As RegisterResultTypes
    End Function

    ' \brief Writes a string register value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param writeStr The zero terminated string to write. WriteStr will be limited to 239 characters and the terminating zero, totally 240 bytes.
    ' \param writeEOL \arg 0 Do NOT append End Of Line character (a null character) to the string.
    '                 \arg 1 Append End Of Line character to the string.
    ' \param index Value index. Typically -1, but could be used to write a value in a mixed type register. Index is byte counted.
    '                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
    '                           indexed content is modified and finally the complete content is written to the register.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteAscii(const char *portname, const unsigned char devId, const unsigned char regId, const char* writeStr, const char writeEOL, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerWriteAscii", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerWriteAscii(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, <MarshalAs(UnmanagedType.LPStr)> ByVal writeStr As String, ByVal writeEOL As Byte, ByVal index As Short) As RegisterResultTypes
    End Function


    '*******************************************************************************************************
    ' Dedicated - Register write/read functions (A write immediately followed by a read)
    '*******************************************************************************************************
    ' It is not necessary to open the port, create the device or register before using those functions, since they will do a dedicated action.
    ' Even though an already opened port would be preffered in time critical situations where a lot of readwrites is required.

    ' \brief Writes and Reads a register value before returning.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param writeData Pointer to a data area from where the write value will be extracted.
    ' \param writeSize Size of write data area, ex. number of bytes to write.
    ' \param readData Pointer to a preallocated data area where the function will store the register read value.
    ' \param readSize Size of preallocated read data area, modified by the function to reflect the actual length of the read register value. The read register value may be truncated to fit into the allocated area.
    ' \param index Data index. Typically -1, but could be used to write/read data at/from a specific position in the register. Index is byte counted.
    '                          Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
    '                          indexed content is modified and finally the complete content is written to the register.
    ' \return A status result value ::RegisterResultTypes
    ' \sa ::registerWriteReadU8, ::registerWriteReadS8 etc.
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write followed by a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteRead(const char *portname, const unsigned char devId, const unsigned char regId, const void *writeData, const unsigned char writeSize, void *readData, unsigned char *readSize, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerWriteRead", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerWriteRead(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, <MarshalAs(UnmanagedType.LPArray)> ByVal writeData As Byte(), ByVal writeSize As Byte, <MarshalAs(UnmanagedType.LPArray, SizeParamIndex:=6)> ByRef readData As Byte(), ByRef readSize As Byte, ByVal index As Short) As RegisterResultTypes
    End Function

    ' \brief Writes and Reads an unsigned char (8bit) register value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param writeValue The register value to write.
    ' \param readValue Pointer to an unsigned char where the function will store the register read value.
    ' \param index Value index. Typically -1, but could be used to write and read a value in a multi value register. Index is byte counted.
    '                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
    '                           indexed content is modified and finally the complete content is written to the register.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write followed by a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteReadU8(const char *portname, const unsigned char devId, const unsigned char regId, const unsigned char writeValue, unsigned char *readValue, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerWriteReadU8", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerWriteReadU8(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByVal writeValue As Byte, ByRef readValue As Byte, ByVal index As Short) As RegisterResultTypes
    End Function

    ' \brief Writes and Reads a signed char (8bit) register value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param writeValue The register value to write.
    ' \param readValue Pointer to a signed char where the function will store the register read value.
    ' \param index Value index. Typically -1, but could be used to write and read a value in a multi value register. Index is byte counted.
    '                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
    '                           indexed content is modified and finally the complete content is written to the register.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write followed by a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteReadS8(const char *portname, const unsigned char devId, const unsigned char regId, const signed char writeValue, signed char *readValue, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerWriteReadS8", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerWriteReadS8(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByVal writeValue As SByte, ByRef readValue As SByte, ByVal index As Short) As RegisterResultTypes
    End Function

    ' \brief Writes and Reads an unsigned short (16bit) register value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param writeValue The register value to write.
    ' \param readValue Pointer to an unsigned short where the function will store the register read value.
    ' \param index Value index. Typically -1, but could be used to write and read a value in a multi value register. Index is byte counted.
    '                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
    '                           indexed content is modified and finally the complete content is written to the register.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write followed by a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteReadU16(const char *portname, const unsigned char devId, const unsigned char regId, const unsigned short writeValue, unsigned short *readValue, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerWriteReadU16", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerWriteReadU16(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByVal writeValue As UInt16, ByRef readValue As UInt16, ByVal index As Short) As RegisterResultTypes
    End Function

    ' \brief Writes and Reads a signed short (16bit) register value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param writeValue The register value to write.
    ' \param readValue Pointer to a signed short where the function will store the register read value.
    ' \param index Value index. Typically -1, but could be used to write and read a value in a multi value register. Index is byte counted.
    '                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
    '                           indexed content is modified and finally the complete content is written to the register.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write followed by a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteReadS16(const char *portname, const unsigned char devId, const unsigned char regId, const signed short writeValue, signed short *readValue, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerWriteReadS16", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerWriteReadS16(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByVal writeValue As Int16, ByRef readValue As Int16, ByVal index As Short) As RegisterResultTypes
    End Function

    ' \brief Writes and Reads an unsigned long (32bit) register value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param writeValue The register value to write.
    ' \param readValue Pointer to an unsigned long where the function will store the register read value.
    ' \param index Value index. Typically -1, but could be used to write and read a value in a multi value register. Index is byte counted.
    '                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
    '                           indexed content is modified and finally the complete content is written to the register.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write followed by a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteReadU32(const char *portname, const unsigned char devId, const unsigned char regId, const unsigned long writeValue, unsigned long *readValue, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerWriteReadU32", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerWriteReadU32(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByVal writeValue As UInt32, ByRef readValue As UInt32, ByVal index As Short) As RegisterResultTypes
    End Function

    ' \brief Writes and Reads a signed long (32bit) register value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param writeValue The register value to write.
    ' \param readValue Pointer to a signed long where the function will store the register read value.
    ' \param index Value index. Typically -1, but could be used to write and read a value in a multi value register. Index is byte counted.
    '                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
    '                           indexed content is modified and finally the complete content is written to the register.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write followed by a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteReadS32(const char *portname, const unsigned char devId, const unsigned char regId, const signed long writeValue, signed long *readValue, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerWriteReadS32", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerWriteReadS32(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByVal writeValue As Int32, ByRef readValue As Int32, ByVal index As Short) As RegisterResultTypes
    End Function

    ' \brief Writes and Reads an unsigned long long (64bit) register value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param writeValue The register value to write.
    ' \param readValue Pointer to an unsigned long long where the function will store the register read value.
    ' \param index Value index. Typically -1, but could be used to write and read a value in a multi value register. Index is byte counted.
    '                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
    '                           indexed content is modified and finally the complete content is written to the register.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write followed by a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteReadU64(const char *portname, const unsigned char devId, const unsigned char regId, const unsigned long long writeValue, unsigned long long *readValue, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerWriteReadU64", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerWriteReadU64(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByVal writeValue As UInt64, ByRef readValue As UInt64, ByVal index As Short) As RegisterResultTypes
    End Function

    ' \brief Writes and Reads a signed long long (64bit) register value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param writeValue The register value to write.
    ' \param readValue Pointer to a signed long long where the function will store the register read value.
    ' \param index Value index. Typically -1, but could be used to write and read a value in a multi value register. Index is byte counted.
    '                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
    '                           indexed content is modified and finally the complete content is written to the register.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write followed by a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteReadS64(const char *portname, const unsigned char devId, const unsigned char regId, const signed long long writeValue, signed long long *readValue, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerWriteReadS64", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerWriteReadS64(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByVal writeValue As Int64, ByRef readValue As Int64, ByVal index As Short) As RegisterResultTypes
    End Function

    ' \brief Writes and Reads a float (32bit) register value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param writeValue The register value to write.
    ' \param readValue Pointer to a float where the function will store the register read value.
    ' \param index Value index. Typically -1, but could be used to write and read a value in a multi value register. Index is byte counted.
    '                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
    '                           indexed content is modified and finally the complete content is written to the register.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write followed by a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteReadF32(const char *portname, const unsigned char devId, const unsigned char regId, const float writeValue, float *readValue, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerWriteReadF32", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerWriteReadF32(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByVal writeValue As Single, ByRef readValue As Single, ByVal index As Short) As RegisterResultTypes
    End Function

    ' \brief Writes and Reads a double (64bit) register value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param writeValue The register value to write.
    ' \param readValue Pointer to a double where the function will store the register read value.
    ' \param index Value index. Typically -1, but could be used to write and read a value in a multi value register. Index is byte counted.
    '                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
    '                           indexed content is modified and finally the complete content is written to the register.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write followed by a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteReadF64(const char *portname, const unsigned char devId, const unsigned char regId, const double writeValue, double *readValue, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerWriteReadF64", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerWriteReadF64(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByVal writeValue As Double, ByRef readValue As Double, ByVal index As Short) As RegisterResultTypes
    End Function

    ' \brief Writes and Reads a string register value.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param writeStr The zero terminated string to write. WriteStr will be limited to 239 characters and the terminating zero, totally 240 bytes.
    ' \param writeEOL \arg 0 Do NOT append End Of Line character (a null character) to the string.
    '                 \arg 1 Append End Of Line character to the string.
    ' \param readStr Pointer to a preallocated string area where the function will store the register read value.
    ' \param maxLen Size of preallocated string area, modified by the function to reflect the actual length of the returned string. The returned string may be truncated to fit into the allocated area.
    ' \param index Value index. Typically -1, but could be used to write and read a string in a mixed type register. Index is byte counted.
    '                           Index >= 0 activates a read-modify-write sequence: The complete register content is being read, then the
    '                           indexed content is modified and finally the complete content is written to the register.
    ' \return A status result value ::RegisterResultTypes
    ' \note It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated write followed by a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerWriteReadAscii(const char *portname, const unsigned char devId, const unsigned char regId, const char* writeStr, const char writeEOL, char *readStr, unsigned char *maxLen, const unsigned char index);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerWriteReadAscii", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerWriteReadAscii(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, <MarshalAs(UnmanagedType.LPStr)> ByVal writeStr As String, ByVal writeEOL As Byte, <MarshalAs(UnmanagedType.LPStr)> ByVal readStr As StringBuilder, ByRef maxLen As Byte, ByVal index As Short) As RegisterResultTypes
    End Function

    '*******************************************************************************************************
    ' Dedicated - Device functions
    '*******************************************************************************************************
    ' Dedicated - Device functions could be used directly.\n
    ' It is not necessary to open the port, create the device or register before using those functions, since they will do a dedicated action.
    ' Even though an already opened port would be preffered in time critical situations where a lot of reads is required.

    ' \brief Returns the module type for a specific device id (module address).
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId Given device id to retrieve device type for (module type).
    ' \param devType Pointer to an unsigned char where the function stores the device type.
    ' \return A status result value ::DeviceResultTypes
    ' \note Register address 0x61\n
    '       It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetType(const char *portname, const unsigned char devId, unsigned char *devType);
    <DllImport("NKTPDLL.dll", EntryPoint:="deviceGetType", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function deviceGetType(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByRef devType As Byte) As DeviceResultTypes
    End Function


    ' \brief Returns the partnumber for a given device (module address).
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param partnumber Pointer to a preallocated string area where the function will store the partnumber.
    ' \param maxLen Size of preallocated string area, modified by the function to reflect the actual length of the returned string. The returned string may be truncated to fit into the allocated area.
    ' \return A status result value ::RegisterResultTypes
    ' \note Register address 0x8E <b>Not all modules have a partnumber register.</b>\n
    '       It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetPartNumberStr(const char *portname, const unsigned char devId, char *partnumber, unsigned char *maxLen);
    <DllImport("NKTPDLL.dll", EntryPoint:="deviceGetPartNumberStr", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function deviceGetPartNumberStr(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, <MarshalAs(UnmanagedType.LPStr)> ByVal partnumber As StringBuilder, ByRef maxLen As Byte) As DeviceResultTypes
    End Function


    ' \brief Returns the PCB version for a given device (module address).
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param PCBVersion Pointer to a preallocated unsigned char where the function will store the PCB version.
    ' \return A status result value ::RegisterResultTypes
    ' \note Register address 0x62\n
    '       It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetPCBVersion(const char *portname, const unsigned char devId, unsigned char *PCBVersion);
    <DllImport("NKTPDLL.dll", EntryPoint:="deviceGetPCBVersion", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function deviceGetPCBVersion(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByRef PCBVersion As Byte) As DeviceResultTypes
    End Function


    ' \brief Returns the status bits for a given device (module address).
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param statusBits Pointer to a preallocated unsigned long where the function will store the status bits.
    ' \return A status result value ::RegisterResultTypes
    ' \note Register address 0x66\n
    '       It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetStatusBits(const char *portname, const unsigned char devId, unsigned long *statusBits);
    <DllImport("NKTPDLL.dll", EntryPoint:="deviceGetStatusBits", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function deviceGetStatusBits(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByRef statusBits As UInt32) As DeviceResultTypes
    End Function


    ' \brief Returns the error code for a given device (module address).
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param errorCode Pointer to a preallocated unsigned short where the function will store the error code.
    ' \return A status result value ::RegisterResultTypes
    ' \note Register address 0x67\n
    '       It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetErrorCode(const char *portname, const unsigned char devId, unsigned short *errorCode);
    <DllImport("NKTPDLL.dll", EntryPoint:="deviceGetErrorCode", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function deviceGetErrorCode(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByRef errorCode As UInt16) As DeviceResultTypes
    End Function


    ' \brief Returns the bootloader version for a given device (module address).
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param version Pointer to a preallocated unsigned short where the function will store the bootloader version.
    ' \return A status result value ::RegisterResultTypes
    ' \note Register address 0x6D\n
    '       It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetBootloaderVersion(const char *portname, const unsigned char devId, unsigned short *version);
    <DllImport("NKTPDLL.dll", EntryPoint:="deviceGetBootloaderVersion", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function deviceGetBootloaderVersion(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByRef version As UInt16) As DeviceResultTypes
    End Function


    ' \brief Returns the bootloader version (string) for a given device (module address).
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param versionStr Pointer to a preallocated string area where the function will store the bootloader version.
    ' \param maxLen Size of preallocated string area, modified by the function to reflect the actual length of the returned string. The returned string may be truncated to fit into the allocated area.
    ' \return A status result value ::RegisterResultTypes
    ' \note Register address 0x6D\n
    '       It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetBootloaderVersionStr(const char *portname, const unsigned char devId, char *versionStr, unsigned char *maxLen);
    <DllImport("NKTPDLL.dll", EntryPoint:="deviceGetBootloaderVersionStr", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function deviceGetBootloaderVersionStr(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, <MarshalAs(UnmanagedType.LPStr)> ByVal versionStr As StringBuilder, ByRef maxLen As Byte) As DeviceResultTypes
    End Function


    ' \brief Returns the firmware version for a given device (module address).
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param version Pointer to a preallocated unsigned short where the function will store the firmware version.
    ' \return A status result value ::RegisterResultTypes
    ' \note Register address 0x64\n
    '       It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetFirmwareVersion(const char *portname, const unsigned char devId, unsigned short *version);
    <DllImport("NKTPDLL.dll", EntryPoint:="deviceGetFirmwareVersion", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function deviceGetFirmwareVersion(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByRef version As UInt16) As DeviceResultTypes
    End Function


    ' \brief Returns the firmware version (string) for a given device (module address).
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param versionStr Pointer to a preallocated string area where the function will store the firmware version.
    ' \param maxLen Size of preallocated string area, modified by the function to reflect the actual length of the returned string. The returned string may be truncated to fit into the allocated area.
    ' \return A status result value ::RegisterResultTypes
    ' \note Register address 0x64\n
    '       It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetFirmwareVersionStr(const char *portname, const unsigned char devId, char *versionStr, unsigned char *maxLen);
    <DllImport("NKTPDLL.dll", EntryPoint:="deviceGetFirmwareVersionStr", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function deviceGetFirmwareVersionStr(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, <MarshalAs(UnmanagedType.LPStr)> ByVal versionStr As StringBuilder, ByRef maxLen As Byte) As DeviceResultTypes
    End Function


    ' \brief Returns the Module serialnumber (string) for a given device (module address).
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param serialNumber Pointer to a preallocated string area where the function will store the serialnumber version.
    ' \param maxLen Size of preallocated string area, modified by the function to reflect the actual length of the returned string. The returned string may be truncated to fit into the allocated area.
    ' \return A status result value ::RegisterResultTypes
    ' \note Register address 0x65\n
    '       It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetModuleSerialNumberStr(const char *portname, const unsigned char devId, char *serialNumber, unsigned char *maxLen);
    <DllImport("NKTPDLL.dll", EntryPoint:="deviceGetModuleSerialNumberStr", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function deviceGetModuleSerialNumberStr(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, <MarshalAs(UnmanagedType.LPStr)> ByVal serialNumber As StringBuilder, ByRef maxLen As Byte) As DeviceResultTypes
    End Function


    ' \brief Returns the PCB serialnumber (string) for a given device (module address).
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param serialNumber Pointer to a preallocated string area where the function will store the serialnumber version.
    ' \param maxLen Size of preallocated string area, modified by the function to reflect the actual length of the returned string. The returned string may be truncated to fit into the allocated area.
    ' \return A status result value ::RegisterResultTypes
    ' \note Register address 0x6E\n
    '       It is not necessary to open the port, create the device or register before using this function, since it will do a dedicated read.
    '
    ' extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetPCBSerialNumberStr(const char *portname, const unsigned char devId, char *serialNumber, unsigned char *maxLen);
    <DllImport("NKTPDLL.dll", EntryPoint:="deviceGetPCBSerialNumberStr", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function deviceGetPCBSerialNumberStr(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, <MarshalAs(UnmanagedType.LPStr)> ByVal serialNumber As StringBuilder, ByRef maxLen As Byte) As DeviceResultTypes
    End Function


    '*******************************************************************************************************
    ' Callback - Device functions
    '*******************************************************************************************************
    ' Callback - Device functions
    ' Device functions primarly used in callback environments.

    ' \brief Creates a device in the internal devicelist. If the ::openPorts function has been called with the liveMode = 1 the kernel immediatedly starts to monitor the device.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param waitReady
    '        \arg 0 Don't wait for the device being ready.
    '        \arg 1 Wait up to 2 seconds for the device to complete its analyze cycle. (All standard registers being successfully read) 
    ' \return A status result value ::DeviceResultTypes
    '
    ' extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceCreate(const char *portname, const unsigned char devId, const char waitReady);
    <DllImport("NKTPDLL.dll", EntryPoint:="deviceCreate", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function deviceCreate(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal waitReady As Byte) As DeviceResultTypes
    End Function


    ' \brief Checks if a specific device already exists in the internal devicelist.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param exists Pointer to an unsigned char where the function will store the exists status.
    '        \arg 0 Device does not exists.
    '        \arg 1 Device exists.
    ' \return A status result value ::DeviceResultTypes
    '
    ' extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceExists(const char *portname, const unsigned char devId, unsigned char *exists);
    <DllImport("NKTPDLL.dll", EntryPoint:="deviceExists", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function deviceExists(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByRef exists As Byte) As DeviceResultTypes
    End Function

    ' \brief Remove a specific device from the internal devicelist.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \return A status result value ::DeviceResultTypes
    '
    ' extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceRemove(const char *portname, const unsigned char devId);
    <DllImport("NKTPDLL.dll", EntryPoint:="deviceRemove", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function deviceRemove(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte) As DeviceResultTypes
    End Function

    ' \brief Remove all devices from the internal devicelist. No confirmation given, the list is simply cleared.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \return A status result value ::DeviceResultTypes
    '
    ' extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceRemoveAll(const char *portname);
    <DllImport("NKTPDLL.dll", EntryPoint:="deviceRemoveAll", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function deviceRemoveAll(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String) As DeviceResultTypes
    End Function

    ' \brief Returns a list with device types (module types) from the internal devicelist.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param types Pointer to a preallocated area where the function stores the list of module types. The default list size is 256 bytes long (0-255) where each position indicates module address, containing 0 for no module or the module type for addresses having a module.\n
    '  ex. 00h 61h 62h 63h 64h 65h 00h 00h 00h 00h 00h 00h 00h 00h 00h 60h 00h 00h etc.\n
    ' Indicates module type 61h at address 1, module type 62h at address 2 etc. and module type 60h at address 15
    ' \param maxTypes Pointer to an unsigned char giving the maximum number of types to retrieve.
    '         The returned list may be truncated to fit into the allocated area.
    ' \return A status result value ::DeviceResultTypes
    '
    ' extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetAllTypes(const char *portname, unsigned char *types, unsigned char *maxTypes);
    <DllImport("NKTPDLL.dll", EntryPoint:="deviceGetAllTypes", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function deviceGetAllTypes(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, <MarshalAs(UnmanagedType.LPArray, SizeParamIndex:=2)> ByRef types As Byte(), ByRef maxTypes As Byte) As DeviceResultTypes
    End Function

    ' \brief Returns the internal device mode for a specific device id (module address).
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId Given device id to retrieve device mode for.
    ' \param devMode Pointer to an unsigned char where the function stores the device mode. ::DeviceModeTypes
    ' \return A status result value ::DeviceResultTypes
    ' \note Requires the port being already opened with the ::openPorts function and the device being already created, either automatically or with the ::deviceCreate function.
    '
    ' extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetMode(const char *portname, const unsigned char devId, unsigned char *devMode);
    <DllImport("NKTPDLL.dll", EntryPoint:="deviceGetMode", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function deviceGetMode(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByRef devMode As Byte) As DeviceResultTypes
    End Function

    ' \brief Returns the internal device live status for a specific device id (module address).
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId Given device id to retrieve liveMode.
    ' \param liveMode Pointer to an unsigned char where the function stores the live status.
    '        \arg 0 liveMode off
    '        \arg 1 liveMode on
    ' \return A status result value ::DeviceResultTypes
    ' \note Requires the port being already opened with the ::openPorts function and the device being already created, either automatically or with the ::deviceCreate function.
    '
    ' extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceGetLive(const char *portname, const unsigned char devId, unsigned char *liveMode);
    <DllImport("NKTPDLL.dll", EntryPoint:="deviceGetLive", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function deviceGetLive(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByRef liveMode As Byte) As DeviceResultTypes
    End Function

    ' \brief Sets the internal device live status for a specific device id (module address).
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId Given device id to set liveMode on.
    ' \param liveMode An unsigned char giving the new live status.
    '        \arg 0 liveMode off
    '        \arg 1 liveMode on
    ' \return A status result value ::DeviceResultTypes
    ' \note Requires the port being already opened with the ::openPorts function and the device being already created, either automatically or with the ::deviceCreate function.
    '
    ' extern "C" NKTPDLL_EXPORT DeviceResultTypes deviceSetLive(const char *portname, const unsigned char devId, const unsigned char liveMode);
    <DllImport("NKTPDLL.dll", EntryPoint:="deviceSetLive", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function deviceSetLive(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal liveMode As Byte) As DeviceResultTypes
    End Function


    '*******************************************************************************************************
    ' Callback - Register functions
    '*******************************************************************************************************
    ' Callback - Register functions

    ' \brief Creates a register in the internal registerlist. If the ::openPorts function has been called with the liveMode = 1 the kernel immediatedly starts to monitor the register.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param priority The ::RegisterPriorityTypes (monitoring priority).
    ' \param dataType The ::RegisterDataTypes, not used internally but could be used in a common callback function to determine data type.
    ' \return A status result value ::RegisterResultTypes
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerCreate(const char *portname, const unsigned char devId, const unsigned char regId, const RegisterPriorityTypes priority, const RegisterDataTypes dataType);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerCreate", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerCreate(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByVal priority As RegisterPriorityTypes, ByVal dataType As RegisterDataTypes) As RegisterResultTypes
    End Function

    ' \brief Checks if a specific register already exists in the internal registerlist.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \param exists Pointer to an unsigned char where the function will store the exists status.
    '        \arg 0 Register does not exists.
    '        \arg 1 Register exists.
    ' \return A status result value ::RegisterResultTypes
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerExists(const char *portname, const unsigned char devId, const unsigned char regId, unsigned char *exists);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerExists", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerExists(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByRef exists As Byte) As RegisterResultTypes
    End Function

    ' \brief Remove a specific register from the internal registerlist.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regId The register id (register address).
    ' \return A status result value ::RegisterResultTypes
    '/
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerRemove(const char *portname, const unsigned char devId, const unsigned char regId);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerRemove", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerRemove(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte) As RegisterResultTypes
    End Function

    ' \brief Remove all registers from the internal registerlist. No confirmation given, the list is simply cleared.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \return A status result value ::RegisterResultTypes
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerRemoveAll(const char *portname, const unsigned char devId);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerRemoveAll", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerRemoveAll(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte) As RegisterResultTypes
    End Function

    ' \brief Returns a list with register ids (register addresses) from the internal registerlist.
    ' \param portname Zero terminated string giving the portname (case sensitive).
    ' \param devId The device id (module address).
    ' \param regs Pointer to a preallocated area where the function stores the list of registers ids (register addresses).
    ' \param maxRegs Pointer to an unsigned char giving the maximum number of register ids to retrieve.
    '        Modified by the function to reflect the actual number of register ids returned. The returned list may be truncated to fit into the allocated area.
    ' \return A status result value ::RegisterResultTypes
    '
    ' extern "C" NKTPDLL_EXPORT RegisterResultTypes registerGetAll(const char *portname, const unsigned char devId, unsigned char *regs, unsigned char *maxRegs);
    <DllImport("NKTPDLL.dll", EntryPoint:="registerGetAll", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Function registerGetAll(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, <MarshalAs(UnmanagedType.LPArray, SizeParamIndex:=3)> ByVal regs As Byte(), ByRef maxRegs As Byte) As RegisterResultTypes
    End Function


    '*******************************************************************************************************
    '* Callback - Support functions
    '*******************************************************************************************************

    ' \brief Defines the PortStatusCallbackFuncPtr for the ::openPorts and ::closePorts functions.
    ' \param portname Zero terminated string giving the current portname.
    ' \param status The current port status as ::PortStatusTypes
    ' \param curScanAdr When status is ::PortScanProgress or ::PortScanDeviceFound this indicates the current module address scanned or found.
    ' \param maxScanAdr When status is ::PortScanProgress or ::PortScanDeviceFound this indicates the last module address to be scanned.
    ' \param foundType When status is ::PortScanDeviceFound this value will represent the found module type.
    ' \note Please note that due to risk of circular runaway leading to stack overflow, it is not allowed to call functions in the DLL from within the callback function.
    ' If a call is made to a function in the DLL the function will therefore return an application busy error.
    '
    ' typedef void (__cdecl *PortStatusCallbackFuncPtr)(const char* portname,           // current port name
    '                                                   const PortStatusTypes status,   // current port status
    '                                                   const unsigned char curScanAdr, // current scanned address or device found address
    '                                                   const unsigned char maxScanAdr, // total addresses to scan
    '                                                   const unsigned char foundType); // device found type
    <UnmanagedFunctionPointer(CallingConvention.Cdecl, CharSet:=CharSet.Auto)> _
    Public Delegate Sub PortStatusCallbackFuncPtr(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal status As PortStatusTypes, ByVal curScanAdr As Byte, ByVal maxScanAdr As Byte, ByVal foundType As Byte)

    ' \brief Enables/Disables callback for port status changes.
    ' \param callback The ::PortStatusCallbackFuncPtr function pointer. Disable callbacks by parsing in a zero value.
    '
    ' extern "C" NKTPDLL_EXPORT void setCallbackPtrPortInfo(PortStatusCallbackFuncPtr callback);
    <DllImport("NKTPDLL.dll", EntryPoint:="setCallbackPtrPortInfo", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Sub setCallbackPtrPortInfo(ByVal callback As PortStatusCallbackFuncPtr)
    End Sub


    ' \brief Defines the DeviceStatusCallbackFuncPtr for the devices created or connected with the ::deviceCreate function.
    ' \param portname Zero terminated string giving the current portname.
    ' \param devId The device id (module address).
    ' \param status The current port status as ::DeviceStatusTypes
    ' \note Please note that due to risk of circular runaway leading to stack overflow, it is not allowed to call functions in the DLL from within the callback function.
    ' If a call is made to a function in the DLL the function will therefore return an application busy error.
    '
    ' typedef void (__cdecl *DeviceStatusCallbackFuncPtr)(const char* portname,                     // current port name
    '                                                     const unsigned char devId,                // current device id
    '                                                     const DeviceStatusTypes status,           // current device status
    '                                                     const unsigned char devDataLen,           // number of bytes in devData
    '                                                     const void* devData);                     // device data as specified in status
    <UnmanagedFunctionPointer(CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Delegate Sub DeviceStatusCallbackFuncPtr(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal status As DeviceStatusTypes, ByVal devDataLen As Byte, <MarshalAs(UnmanagedType.LPArray, SizeParamIndex:=3)> ByVal devData As Byte())

    ' \brief Enables/Disables callback for device status changes.
    ' \param callback The ::DeviceStatusCallbackFuncPtr function pointer. Disable callbacks by parsing in a zero value.
    '
    ' extern "C" NKTPDLL_EXPORT void setCallbackPtrDeviceInfo(DeviceStatusCallbackFuncPtr callback);
    <DllImport("NKTPDLL.dll", EntryPoint:="setCallbackPtrDeviceInfo", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Sub setCallbackPtrDeviceInfo(ByVal callback As DeviceStatusCallbackFuncPtr)
    End Sub

    ' \brief Defines the RegisterStatusCallbackFuncPtr for the registers created or connected with the ::registerCreate function.
    ' \param portname Zero terminated string giving the current portname.
    ' \param status The current register status as ::RegisterStatusTypes
    ' \param regType The ::RegisterDataTypes, not used internally but could be used in a common callback function to determine data type.
    ' \param regDataLen Number of databytes.
    ' \param regData The register data.
    ' \note Please note that due to risk of circular runaway leading to stack overflow, it is not allowed to to call functions in the DLL from within the callback function.
    ' If a call is made to a function in the DLL the function will therefore return an application busy error.
    '
    ' typedef void (__cdecl *RegisterStatusCallbackFuncPtr)(const char* portname,                       // current port name
    '                                                       const unsigned char devId,                  // current device id
    '                                                       const unsigned char regId,                  // current device id
    '                                                       const RegisterStatusTypes status,           // current register status
    '                                                       const RegisterDataTypes regType,            // current register type
    '                                                       const unsigned char regDataLen,             // number of bytes in regData
    '                                                       const void *regData);                       // register data
    <UnmanagedFunctionPointer(CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Delegate Sub RegisterStatusCallbackFuncPtr(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByVal status As RegisterStatusTypes, ByVal regType As RegisterDataTypes, ByVal regDataLen As Byte, <MarshalAs(UnmanagedType.LPArray, SizeParamIndex:=5)> ByVal regData As Byte())

    ' \brief Enables/Disables callback for register status changes.
    ' \param callback The ::RegisterStatusCallbackFuncPtr function pointer. Disable callbacks by parsing in a zero value.
    '
    ' extern "C" NKTPDLL_EXPORT void setCallbackPtrRegisterInfo(RegisterStatusCallbackFuncPtr callback);
    <DllImport("NKTPDLL.dll", EntryPoint:="setCallbackPtrRegisterInfo", CallingConvention:=CallingConvention.Cdecl, CharSet:=CharSet.Ansi)> _
    Public Shared Sub setCallbackPtrRegisterInfo(ByVal callback As RegisterStatusCallbackFuncPtr)
    End Sub


End Class

