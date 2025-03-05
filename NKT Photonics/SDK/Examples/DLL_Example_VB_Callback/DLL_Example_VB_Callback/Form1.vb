Imports System.Text
Imports System.Runtime.InteropServices

Public Class Form1


    '*******************************************************************************************************
    ' Misc. helpers
    '*******************************************************************************************************

    Private Sub comboBoxPortname_SelectedIndexChanged(sender As Object, e As EventArgs) Handles comboBoxPortname.SelectedIndexChanged
        If comboBoxPortname.SelectedIndex >= 0 Then
            openPortsPortname.Text = comboBoxPortname.SelectedItem.ToString()
            closePortsPortname.Text = comboBoxPortname.SelectedItem.ToString()
            deviceCreatePortname.Text = comboBoxPortname.SelectedItem.ToString()
            registerCreatePortname.Text = comboBoxPortname.SelectedItem.ToString()
        End If
    End Sub


    Private Sub ShowPortResultTypes(ByVal funcName As String, ByVal result As NKTPDLL.PortResultTypes)
        StatusTextBox.AppendText(vbCrLf & funcName & ": " & NKTPDLL.getPortResultMsg(result))
    End Sub


    Private Sub ShowP2PPortResultTypes(ByVal funcName As String, ByVal result As NKTPDLL.P2PPortResultTypes)
        StatusTextBox.AppendText(vbCrLf & funcName & ": " & NKTPDLL.getP2PPortResultMsg(result))
    End Sub


    Private Sub ShowDeviceResultTypes(ByVal funcName As String, ByVal result As NKTPDLL.DeviceResultTypes)
        StatusTextBox.AppendText(vbCrLf & funcName & ": " & NKTPDLL.getDeviceResultMsg(result))
    End Sub


    Private Sub ShowRegisterResultTypes(ByVal funcName As String, ByVal result As NKTPDLL.RegisterResultTypes)
        StatusTextBox.AppendText(vbCrLf & funcName & ": " & NKTPDLL.getRegisterResultMsg(result))
    End Sub


    '*******************************************************************************************************
    ' Callback handlers
    '*******************************************************************************************************

    Private _PortStatusInstance As NKTPDLL.PortStatusCallbackFuncPtr = New NKTPDLL.PortStatusCallbackFuncPtr(AddressOf PortStatusCallback) ' Allocated to prevent garbage collection
    Private Sub PortStatusCallback(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal status As NKTPDLL.PortStatusTypes, ByVal curScanAdr As Byte, ByVal maxScanAdr As Byte, ByVal foundType As Byte)
        Dim statusMsg As String = vbCrLf & "PortInfo Callback: " & portname & " status:" & status.ToString() & " curScanAdr:" & curScanAdr.ToString() & " maxScanAdr:" & maxScanAdr.ToString() & " foundType:" & foundType.ToString("X2")

        StatusTextBox.Invoke(Sub() StatusTextBox.AppendText(statusMsg))

        Console.Write(statusMsg)
    End Sub

    Private _DeviceStatusInstance As NKTPDLL.DeviceStatusCallbackFuncPtr = New NKTPDLL.DeviceStatusCallbackFuncPtr(AddressOf DeviceStatusCallback) ' Allocated to prevent garbage collection
    Private Sub DeviceStatusCallback(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal status As NKTPDLL.DeviceStatusTypes, ByVal devDataLen As Byte, <MarshalAs(UnmanagedType.LPArray, SizeParamIndex:=3)> ByVal devData As Byte())
        Dim statusMsg As String = vbCrLf & "DeviceInfo Callback: " & portname & " devId: " & devId.ToString() & " status:" & status.ToString() & " "

        Select Case status
            Case NKTPDLL.DeviceStatusTypes.DeviceModeChanged
                ' 0 - devData contains 1 unsigned byte ::DeviceModeTypes
                Select Case CType(devData(0), NKTPDLL.DeviceModeTypes)
                    Case NKTPDLL.DeviceModeTypes.DevModeDisabled
                        statusMsg = statusMsg & "Mode: disabled"
                    Case NKTPDLL.DeviceModeTypes.DevModeAnalyzeInit
                        statusMsg = statusMsg & "Mode: analyze init"
                    Case NKTPDLL.DeviceModeTypes.DevModeAnalyze
                        statusMsg = statusMsg & "Mode: analyzing"
                    Case NKTPDLL.DeviceModeTypes.DevModeNormal
                        statusMsg = statusMsg & "Mode: normal"
                    Case NKTPDLL.DeviceModeTypes.DevModeLogDownload
                        statusMsg = statusMsg & "Mode: logDownload"
                    Case NKTPDLL.DeviceModeTypes.DevModeError
                        statusMsg = statusMsg & "Mode: error"
                    Case NKTPDLL.DeviceModeTypes.DevModeTimeout
                        statusMsg = statusMsg & "Mode: timeout"
                    Case NKTPDLL.DeviceModeTypes.DevModeUpload
                        statusMsg = statusMsg & "Mode: firmwareUpload"
                End Select

            Case NKTPDLL.DeviceStatusTypes.DeviceLiveChanged
                ' 1 - devData contains 1 unsigned byte, 0=live off, 1=live on.
                If devData(0) = 0 Then
                    statusMsg = statusMsg & "live: off"
                Else
                    statusMsg = statusMsg & "live: on"
                End If
            Case NKTPDLL.DeviceStatusTypes.DeviceTypeChanged
                ' 2 - devData contains 1 unsigned byte with DeviceType (module type).
                statusMsg = statusMsg & "type: 0x" & devData(0).ToString("X2")
            Case NKTPDLL.DeviceStatusTypes.DevicePartNumberChanged
                ' 3 - devData contains a string with partnumber.
                statusMsg = statusMsg & "partnumber: " & System.Text.Encoding.Default.GetString(devData)
            Case NKTPDLL.DeviceStatusTypes.DevicePCBVersionChanged
                ' 4 - devData contains 1 unsigned byte with PCB version number.
                statusMsg = statusMsg & "PCB ver: " & devData(0).ToString()
            Case NKTPDLL.DeviceStatusTypes.DeviceStatusBitsChanged
                ' 5 - devData contains 1 unsigned long with statusbits.
                statusMsg = statusMsg & "status bits: 0x" & BitConverter.ToUInt32(devData, 0).ToString("X8")
            Case NKTPDLL.DeviceStatusTypes.DeviceErrorCodeChanged
                ' 6 - devData contains 1 unsigned short with errorcode.
                statusMsg = statusMsg & "error code: 0x" & BitConverter.ToUInt16(devData, 0).ToString("X4")
            Case NKTPDLL.DeviceStatusTypes.DeviceBlVerChanged
                ' 7 - devData contains a string with Bootloader version.
                statusMsg = statusMsg & "bootloader ver: " & System.Text.Encoding.Default.GetString(devData)
            Case NKTPDLL.DeviceStatusTypes.DeviceFwVerChanged
                ' 8 - devData contains a string with Firmware version.
                statusMsg = statusMsg & "firmware ver: " & System.Text.Encoding.Default.GetString(devData)
            Case NKTPDLL.DeviceStatusTypes.DeviceModuleSerialChanged
                ' 9 - devData contains a string with Module serialnumber.
                statusMsg = statusMsg & "module serialnumber: " & System.Text.Encoding.Default.GetString(devData)
            Case NKTPDLL.DeviceStatusTypes.DevicePCBSerialChanged
                ' 10 - devData contains a string with PCB serialnumber.
                statusMsg = statusMsg & "PCB serialnumber: " & System.Text.Encoding.Default.GetString(devData)
            Case NKTPDLL.DeviceStatusTypes.DeviceSysTypeChanged
                ' 11 - devData contains 1 unsigned byte with SystemType (system type).
                statusMsg = statusMsg & "sys type: " & devData(0).ToString()
        End Select

        StatusTextBox.Invoke(Sub() StatusTextBox.AppendText(statusMsg))

        Console.Write(statusMsg)
    End Sub


    Private _RegisterStatusInstance As NKTPDLL.RegisterStatusCallbackFuncPtr = New NKTPDLL.RegisterStatusCallbackFuncPtr(AddressOf RegisterStatusCallback) ' Allocated to prevent garbage collection
    Private Sub RegisterStatusCallback(<MarshalAs(UnmanagedType.LPStr)> ByVal portname As String, ByVal devId As Byte, ByVal regId As Byte, ByVal status As NKTPDLL.RegisterStatusTypes, ByVal regType As NKTPDLL.RegisterDataTypes, ByVal regDataLen As Byte, <MarshalAs(UnmanagedType.LPArray, SizeParamIndex:=5)> ByVal regData As Byte())
        Dim statusMsg As String = vbCrLf & "DeviceInfo Callback: " & portname & " devId: " & devId.ToString() & " regId:" & regId.ToString() & " status:" & status.ToString() & " regType: " & regType.ToString() & " "

        statusMsg = statusMsg & " regDataLen: " & regDataLen.ToString() & " regData:"
        For idx = 1 To regDataLen
            statusMsg = statusMsg & " 0x" & regData(idx - 1).ToString("X2")
        Next

        statusMsg = statusMsg & vbCrLf & NKTPDLL.getRegisterDataTypeMsg(regType)

        StatusTextBox.Invoke(Sub() StatusTextBox.AppendText(statusMsg))

        Console.Write(statusMsg)
    End Sub


    '*******************************************************************************************************
    ' Button handlers
    '*******************************************************************************************************

    Private Sub getOpenPorts_Click(sender As Object, e As EventArgs) Handles getOpenPorts.Click
        Dim maxLen As UShort = 400
        Dim openPortNames As New StringBuilder(maxLen)

        NKTPDLL.getOpenPorts(openPortNames, maxLen)
        StatusTextBox.AppendText(vbCrLf & "getOpenPorts: " & openPortNames.ToString())

    End Sub

    Private Sub getAllPorts_Click(sender As Object, e As EventArgs) Handles getAllPorts.Click
        Dim maxLen As UShort = 400
        Dim portNames As New StringBuilder(maxLen)

        NKTPDLL.getAllPorts(portNames, maxLen)
        StatusTextBox.AppendText(vbCrLf & "getAllPorts: " & portNames.ToString())

        ' Update the portname combobox
        comboBoxPortname.Items.Clear()
        comboBoxPortname.Items.AddRange(portNames.ToString().Split(","))
        comboBoxPortname.SelectedIndex = 0
    End Sub

    ' Enable/Disable port info callbacks
    Private Sub setCallbackPtrPortInfo_CheckedChanged(sender As Object, e As EventArgs) Handles setCallbackPtrPortInfo.CheckedChanged
        If setCallbackPtrPortInfo.Checked Then
            NKTPDLL.setCallbackPtrPortInfo(_PortStatusInstance)
        Else
            NKTPDLL.setCallbackPtrPortInfo(Nothing)
        End If
    End Sub

    Private Sub openPorts_Click(sender As Object, e As EventArgs) Handles openPorts.Click
        Dim autoMode As Byte = 0
        If CheckBoxAutoMode.Checked Then autoMode = 1

        Dim liveMode As Byte = 0
        If CheckBoxLiveMode.Checked Then liveMode = 1
        Dim portName As String = openPortsPortname.Text

        Dim result As NKTPDLL.PortResultTypes = NKTPDLL.openPorts(portName, autoMode, liveMode)
        ShowPortResultTypes("openPorts(""" & portName.ToString() & """, " & autoMode.ToString() & ", " & liveMode.ToString() & ")", result)
    End Sub

    Private Sub closePorts_Click(sender As Object, e As EventArgs) Handles closePorts.Click
        Dim portName As String = closePortsPortname.Text

        Dim result As NKTPDLL.PortResultTypes = NKTPDLL.closePorts(portName)
        ShowPortResultTypes("closePorts(""" & portName.ToString & """)", result)
    End Sub

    ' Enable/Disable device info callbacks
    Private Sub setCallbackPtrDeviceInfo_CheckedChanged(sender As Object, e As EventArgs) Handles setCallbackPtrDeviceInfo.CheckedChanged
        If setCallbackPtrDeviceInfo.Checked Then
            NKTPDLL.setCallbackPtrDeviceInfo(_DeviceStatusInstance)
        Else
            NKTPDLL.setCallbackPtrDeviceInfo(Nothing)
        End If
    End Sub

    Private Sub deviceCreate_Click(sender As Object, e As EventArgs) Handles deviceCreate.Click
        Dim portName As String = deviceCreatePortname.Text
        Dim devId As Byte = Convert.ToByte(deviceCreateDevId.Value)
        Dim waitReady As Byte = 0
        If deviceCreateWaitReady.Checked Then waitReady = 1

        Dim result As NKTPDLL.DeviceResultTypes = NKTPDLL.deviceCreate(portName, devId, waitReady)
        ShowDeviceResultTypes("deviceCreate(""" & portName.ToString() & """, " & devId.ToString() & ", " & waitReady.ToString() & ")", result)
    End Sub

    ' Enable/Disable register info callbacks
    Private Sub setCallbackPtrRegisterInfo_CheckedChanged(sender As Object, e As EventArgs) Handles setCallbackPtrRegisterInfo.CheckedChanged
        If setCallbackPtrRegisterInfo.Checked Then
            NKTPDLL.setCallbackPtrRegisterInfo(_RegisterStatusInstance)
        Else
            NKTPDLL.setCallbackPtrRegisterInfo(Nothing)
        End If
    End Sub

    Private Sub registerCreate_Click(sender As Object, e As EventArgs) Handles registerCreate.Click
        Dim portName As String = registerCreatePortname.Text
        Dim devId As Byte = Convert.ToByte(registerCreateDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerCreateRegId.Value)

        Dim priority As NKTPDLL.RegisterPriorityTypes = NKTPDLL.RegisterPriorityTypes.RegPriority_Low
        If registerCreatePriority.SelectedIndex >= 0 Then priority = CType(registerCreatePriority.SelectedIndex, NKTPDLL.RegisterPriorityTypes)

        Dim dataType As NKTPDLL.RegisterDataTypes = NKTPDLL.RegisterDataTypes.RegData_Unknown
        If registerCreateDataType.SelectedIndex >= 0 Then dataType = CType(registerCreateDataType.SelectedIndex, NKTPDLL.RegisterDataTypes)

        Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerCreate(portName, devId, regId, priority, dataType)
        ShowRegisterResultTypes("registerCreate(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & priority.ToString() & ", " & dataType.ToString(), result)
    End Sub

End Class
