Imports System.Text
Imports System.Runtime.InteropServices



Public Class Form1

    '*******************************************************************************************************
    ' Misc. helpers
    '*******************************************************************************************************

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
    ' Button handlers
    '*******************************************************************************************************

    Private Sub GetAllPorts_Click(sender As Object, e As EventArgs) Handles GetAllPorts.Click
        Dim maxLen As UShort = 400
        Dim portNames As New StringBuilder(maxLen)

        NKTPDLL.getAllPorts(portNames, maxLen)
        StatusTextBox.AppendText(vbCrLf & "getAllPorts: " & portNames.ToString())
    End Sub

    Private Sub GetOpenPorts_Click(sender As Object, e As EventArgs) Handles GetOpenPorts.Click
        Dim maxLen As UShort = 400
        Dim openPortNames As New StringBuilder(maxLen)

        NKTPDLL.getOpenPorts(openPortNames, maxLen)
        StatusTextBox.AppendText(vbCrLf & "getOpenPorts: " & openPortNames.ToString())
    End Sub

    Private Sub OpenPorts_Click(sender As Object, e As EventArgs) Handles OpenPorts.Click
        Dim autoMode As Byte = 0
        If checkBoxAutoMode.Checked Then autoMode = 1

        Dim liveMode As Byte = 0
        If checkBoxLiveMode.Checked Then liveMode = 1
        Dim portName As String = openPortsPortname.Text

        Dim result As NKTPDLL.PortResultTypes = NKTPDLL.openPorts(portName, autoMode, liveMode)
        ShowPortResultTypes("openPorts(""" & portName.ToString() & """, " & autoMode.ToString() & ", " & liveMode.ToString() & ")", result)
    End Sub

    Private Sub ClosePorts_Click(sender As Object, e As EventArgs) Handles ClosePorts.Click
        Dim portName As String = closePortsPortname.Text

        Dim result As NKTPDLL.PortResultTypes = NKTPDLL.closePorts(portName)
        ShowPortResultTypes("closePorts(""" & portName.ToString & """)", result)
    End Sub

    Private Sub PointToPointPortAdd_Click(sender As Object, e As EventArgs) Handles PointToPointPortAdd.Click
        Dim portName As String = P2PPortAddName.Text
        Dim hostAddr As String = P2PPortAddHostIP.Text
        Dim hostPort As UShort
        Dim clientAddr As String = P2PPortAddClientIP.Text
        Dim clientPort As UShort
        Dim protocol As Byte
        Dim timeout As Byte

        If Not Int32.TryParse(P2PPortAddHostPort.Text, hostPort) Then hostPort = 0
        If Not Int32.TryParse(P2PPortAddClientPort.Text, clientPort) Then clientPort = 0
        If P2PPortAddProtocol.SelectedIndex >= 0 Then
            protocol = P2PPortAddProtocol.SelectedIndex
        Else
            protocol = 0
        End If

        If Not Int32.TryParse(P2PPortAddTimeout.Text, timeout) Then timeout = 0

        Dim result As NKTPDLL.P2PPortResultTypes = NKTPDLL.pointToPointPortAdd(portName, hostAddr, hostPort, clientAddr, clientPort, protocol, timeout)
        ShowP2PPortResultTypes("pointToPointPortAdd(""" & portName.ToString() & """, """ & hostAddr.ToString() & """, " & hostPort.ToString() & ", """ & clientAddr.ToString() & """, " & clientPort.ToString() & ", " & protocol.ToString() & ", " & timeout.ToString(), result)

    End Sub

    Private Sub pointToPointPortGet_Click(sender As Object, e As EventArgs) Handles pointToPointPortGet.Click
        Dim portName As String = P2PPortGetName.Text

        Dim hostAddrMax As Byte = 255
        Dim hostAddr As StringBuilder = New StringBuilder(hostAddrMax)
        Dim hostPort As UShort = 0

        Dim clientAddrMax As Byte = 255
        Dim clientAddr As StringBuilder = New StringBuilder(clientAddrMax)
        Dim clientPort As UShort = 0

        Dim protocol As Byte = 0
        Dim timeout As Byte = 0

        Dim result As NKTPDLL.P2PPortResultTypes = NKTPDLL.pointToPointPortGet(portName, hostAddr, hostAddrMax, hostPort, clientAddr, clientAddrMax, clientPort, protocol, timeout)
        ShowP2PPortResultTypes("pointToPointPortGet(""" & portName.ToString() & """, """ & hostAddr.ToString() & """, " & hostPort.ToString() & ", """ & clientAddr.ToString() & """, " & clientPort.ToString() & ", " & protocol.ToString() & ", " & timeout.ToString(), result)

        P2PPortGetHostIP.Text = hostAddr.ToString()
        P2PPortGetHostPort.Text = hostPort.ToString()
        P2PPortGetClientIP.Text = clientAddr.ToString()
        P2PPortGetClientPort.Text = clientPort.ToString()
        P2PPortGetProtocol.SelectedIndex = protocol
        P2PPortGetTimeout.Text = timeout.ToString()

    End Sub

    Private Sub pointToPointPortDel_Click(sender As Object, e As EventArgs) Handles pointToPointPortDel.Click
        Dim portName As String = P2PPortDelName.Text

        Dim result As NKTPDLL.P2PPortResultTypes = NKTPDLL.pointToPointPortDel(portName)
        ShowP2PPortResultTypes("pointToPointPortDel(""" & portName.ToString() & """)", result)

    End Sub

    Private Sub ExitButton_Click(sender As Object, e As EventArgs) Handles ExitButton.Click
        Application.Exit()
    End Sub

    '*******************************************************************************************************
    ' Dedicated - Register read functions
    '*******************************************************************************************************

    Private Sub registerReadU8_Click(sender As Object, e As EventArgs) Handles registerReadU8.Click
        Dim portName As String = registerReadPortname.Text
        Dim devId As Byte = Convert.ToByte(registerReadDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerReadRegId.Value)
        Dim value As Byte = 0
        Dim index As Int16 = Convert.ToInt16(registerReadIndex.Value)

        Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerReadU8(portName, devId, regId, value, index)
        ShowRegisterResultTypes("registerReadU8(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & 0 & ", " & index.ToString() & ") : " + value.ToString(), result)

    End Sub

    Private Sub registerReadS8_Click(sender As Object, e As EventArgs) Handles registerReadS8.Click
        Dim portName As String = registerReadPortname.Text
        Dim devId As Byte = Convert.ToByte(registerReadDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerReadRegId.Value)
        Dim value As SByte = 0
        Dim index As Int16 = Convert.ToInt16(registerReadIndex.Value)

        Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerReadS8(portName, devId, regId, value, index)
        ShowRegisterResultTypes("registerReadS8(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & 0 & ", " & index.ToString() & ") : " + value.ToString(), result)

    End Sub

    Private Sub registerReadU16_Click(sender As Object, e As EventArgs) Handles registerReadU16.Click
        Dim portName As String = registerReadPortname.Text
        Dim devId As Byte = Convert.ToByte(registerReadDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerReadRegId.Value)
        Dim value As UInt16 = 0
        Dim index As Int16 = Convert.ToInt16(registerReadIndex.Value)

        Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerReadU16(portName, devId, regId, value, index)
        ShowRegisterResultTypes("registerReadU16(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & 0 & ", " & index.ToString() & ") : " + value.ToString(), result)

    End Sub

    Private Sub registerReadS16_Click(sender As Object, e As EventArgs) Handles registerReadS16.Click
        Dim portName As String = registerReadPortname.Text
        Dim devId As Byte = Convert.ToByte(registerReadDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerReadRegId.Value)
        Dim value As Int16 = 0
        Dim index As Int16 = Convert.ToInt16(registerReadIndex.Value)

        Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerReadS16(portName, devId, regId, value, index)
        ShowRegisterResultTypes("registerReadS16(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & 0 & ", " & index.ToString() & ") : " + value.ToString(), result)

    End Sub

    Private Sub registerReadU32_Click(sender As Object, e As EventArgs) Handles registerReadU32.Click
        Dim portName As String = registerReadPortname.Text
        Dim devId As Byte = Convert.ToByte(registerReadDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerReadRegId.Value)
        Dim value As UInt32 = 0
        Dim index As Int16 = Convert.ToInt16(registerReadIndex.Value)

        Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerReadU32(portName, devId, regId, value, index)
        ShowRegisterResultTypes("registerReadU32(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & 0 & ", " & index.ToString() & ") : " + value.ToString(), result)

    End Sub

    Private Sub registerReadS32_Click(sender As Object, e As EventArgs) Handles registerReadS32.Click
        Dim portName As String = registerReadPortname.Text
        Dim devId As Byte = Convert.ToByte(registerReadDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerReadRegId.Value)
        Dim value As Int32 = 0
        Dim index As Int16 = Convert.ToInt16(registerReadIndex.Value)

        Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerReadS32(portName, devId, regId, value, index)
        ShowRegisterResultTypes("registerReadS32(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & 0 & ", " & index.ToString() & ") : " + value.ToString(), result)

    End Sub

    Private Sub registerReadU64_Click(sender As Object, e As EventArgs) Handles registerReadU64.Click
        Dim portName As String = registerReadPortname.Text
        Dim devId As Byte = Convert.ToByte(registerReadDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerReadRegId.Value)
        Dim value As UInt64 = 0
        Dim index As Int16 = Convert.ToInt16(registerReadIndex.Value)

        Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerReadU64(portName, devId, regId, value, index)
        ShowRegisterResultTypes("registerReadU64(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & 0 & ", " & index.ToString() & ") : " + value.ToString(), result)

    End Sub

    Private Sub registerReadS64_Click(sender As Object, e As EventArgs) Handles registerReadS64.Click
        Dim portName As String = registerReadPortname.Text
        Dim devId As Byte = Convert.ToByte(registerReadDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerReadRegId.Value)
        Dim value As Int64 = 0
        Dim index As Int16 = Convert.ToInt16(registerReadIndex.Value)

        Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerReadS64(portName, devId, regId, value, index)
        ShowRegisterResultTypes("registerReadS64(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & 0 & ", " & index.ToString() & ") : " + value.ToString(), result)

    End Sub

    Private Sub registerReadF32_Click(sender As Object, e As EventArgs) Handles registerReadF32.Click
        Dim portName As String = registerReadPortname.Text
        Dim devId As Byte = Convert.ToByte(registerReadDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerReadRegId.Value)
        Dim value As Single = 0
        Dim index As Int16 = Convert.ToInt16(registerReadIndex.Value)

        Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerReadF32(portName, devId, regId, value, index)
        ShowRegisterResultTypes("registerReadF32(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & 0 & ", " & index.ToString() & ") : " + value.ToString(), result)

    End Sub

    Private Sub registerReadF64_Click(sender As Object, e As EventArgs) Handles registerReadF64.Click
        Dim portName As String = registerReadPortname.Text
        Dim devId As Byte = Convert.ToByte(registerReadDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerReadRegId.Value)
        Dim value As Double = 0
        Dim index As Int16 = Convert.ToInt16(registerReadIndex.Value)

        Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerReadF64(portName, devId, regId, value, index)
        ShowRegisterResultTypes("registerReadF64(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & 0 & ", " & index.ToString() & ") : " + value.ToString(), result)

    End Sub

    Private Sub registerReadAscii_Click(sender As Object, e As EventArgs) Handles registerReadAscii.Click
        Dim portName As String = registerReadPortname.Text
        Dim devId As Byte = Convert.ToByte(registerReadDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerReadRegId.Value)
        Dim maxLen As Byte = 255
        Dim value As StringBuilder = New StringBuilder(maxLen)
        Dim index As Int16 = Convert.ToInt16(registerReadIndex.Value)

        Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerReadAscii(portName, devId, regId, value, maxLen, index)
        ShowRegisterResultTypes("registerReadAscii(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & """""" + ", " & index.ToString() & ") : " & value.ToString(), result)

    End Sub


    '*******************************************************************************************************
    ' Dedicated - Register write functions
    '*******************************************************************************************************

    Private Sub registerWriteU8_Click(sender As Object, e As EventArgs) Handles registerWriteU8.Click
        Dim portName As String = registerWritePortname.Text
        Dim devId As Byte = Convert.ToByte(registerWriteDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerWriteRegId.Value)
        Dim value As Byte = 0
        Dim index As Int16 = Convert.ToInt16(registerWriteIndex.Value)

        Try
            value = Convert.ToByte(registerWriteU8Value.Text)

            Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerWriteU8(portName, devId, regId, value, index)
            ShowRegisterResultTypes("registerWriteU8(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & value.ToString() & ", " & index.ToString() & ")", result)

        Catch ex As Exception

            StatusTextBox.AppendText(vbCrLf & "*** Invalid write value ***")

        End Try
    End Sub

    Private Sub registerWriteS8_Click(sender As Object, e As EventArgs) Handles registerWriteS8.Click
        Dim portName As String = registerWritePortname.Text
        Dim devId As Byte = Convert.ToByte(registerWriteDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerWriteRegId.Value)
        Dim value As SByte = 0
        Dim index As Int16 = Convert.ToInt16(registerWriteIndex.Value)

        Try
            value = Convert.ToSByte(registerWriteS8Value.Text)

            Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerWriteS8(portName, devId, regId, value, index)
            ShowRegisterResultTypes("registerWriteS8(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & value.ToString() & ", " & index.ToString() & ")", result)

        Catch ex As Exception

            StatusTextBox.AppendText(vbCrLf & "*** Invalid write value ***")

        End Try
    End Sub

    Private Sub registerWriteU16_Click(sender As Object, e As EventArgs) Handles registerWriteU16.Click
        Dim portName As String = registerWritePortname.Text
        Dim devId As Byte = Convert.ToByte(registerWriteDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerWriteRegId.Value)
        Dim value As UInt16 = 0
        Dim index As Int16 = Convert.ToInt16(registerWriteIndex.Value)

        Try
            value = Convert.ToUInt16(registerWriteU16Value.Text)

            Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerWriteU16(portName, devId, regId, value, index)
            ShowRegisterResultTypes("registerWriteU16(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & value.ToString() & ", " & index.ToString() & ")", result)

        Catch ex As Exception

            StatusTextBox.AppendText(vbCrLf & "*** Invalid write value ***")

        End Try
    End Sub

    Private Sub registerWriteS16_Click(sender As Object, e As EventArgs) Handles registerWriteS16.Click
        Dim portName As String = registerWritePortname.Text
        Dim devId As Byte = Convert.ToByte(registerWriteDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerWriteRegId.Value)
        Dim value As Int16 = 0
        Dim index As Int16 = Convert.ToInt16(registerWriteIndex.Value)

        Try
            value = Convert.ToInt16(registerWriteS16Value.Text)

            Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerWriteS16(portName, devId, regId, value, index)
            ShowRegisterResultTypes("registerWriteS16(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & value.ToString() & ", " & index.ToString() & ")", result)

        Catch ex As Exception

            StatusTextBox.AppendText(vbCrLf & "*** Invalid write value ***")

        End Try
    End Sub

    Private Sub registerWriteU32_Click(sender As Object, e As EventArgs) Handles registerWriteU32.Click
        Dim portName As String = registerWritePortname.Text
        Dim devId As Byte = Convert.ToByte(registerWriteDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerWriteRegId.Value)
        Dim value As UInt32 = 0
        Dim index As Int16 = Convert.ToInt16(registerWriteIndex.Value)

        Try
            value = Convert.ToUInt32(registerWriteU32Value.Text)

            Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerWriteU32(portName, devId, regId, value, index)
            ShowRegisterResultTypes("registerWriteU32(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & value.ToString() & ", " & index.ToString() & ")", result)

        Catch ex As Exception

            StatusTextBox.AppendText(vbCrLf & "*** Invalid write value ***")

        End Try
    End Sub

    Private Sub registerWriteS32_Click(sender As Object, e As EventArgs) Handles registerWriteS32.Click
        Dim portName As String = registerWritePortname.Text
        Dim devId As Byte = Convert.ToByte(registerWriteDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerWriteRegId.Value)
        Dim value As Int32 = 0
        Dim index As Int16 = Convert.ToInt16(registerWriteIndex.Value)

        Try
            value = Convert.ToInt32(registerWriteS32Value.Text)

            Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerWriteS32(portName, devId, regId, value, index)
            ShowRegisterResultTypes("registerWriteS32(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & value.ToString() & ", " & index.ToString() & ")", result)

        Catch ex As Exception

            StatusTextBox.AppendText(vbCrLf & "*** Invalid write value ***")

        End Try
    End Sub

    Private Sub registerWriteU64_Click(sender As Object, e As EventArgs) Handles registerWriteU64.Click
        Dim portName As String = registerWritePortname.Text
        Dim devId As Byte = Convert.ToByte(registerWriteDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerWriteRegId.Value)
        Dim value As UInt64 = 0
        Dim index As Int16 = Convert.ToInt16(registerWriteIndex.Value)

        Try
            value = Convert.ToUInt64(registerWriteU64Value.Text)

            Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerWriteU64(portName, devId, regId, value, index)
            ShowRegisterResultTypes("registerWriteU64(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & value.ToString() & ", " & index.ToString() & ")", result)

        Catch ex As Exception

            StatusTextBox.AppendText(vbCrLf & "*** Invalid write value ***")

        End Try
    End Sub

    Private Sub registerWriteS64_Click(sender As Object, e As EventArgs) Handles registerWriteS64.Click
        Dim portName As String = registerWritePortname.Text
        Dim devId As Byte = Convert.ToByte(registerWriteDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerWriteRegId.Value)
        Dim value As Int64 = 0
        Dim index As Int16 = Convert.ToInt16(registerWriteIndex.Value)

        Try
            value = Convert.ToInt64(registerWriteS64Value.Text)

            Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerWriteS64(portName, devId, regId, value, index)
            ShowRegisterResultTypes("registerWriteS64(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & value.ToString() & ", " & index.ToString() & ")", result)

        Catch ex As Exception

            StatusTextBox.AppendText(vbCrLf & "*** Invalid write value ***")

        End Try
    End Sub

    Private Sub registerWriteF32_Click(sender As Object, e As EventArgs) Handles registerWriteF32.Click
        Dim portName As String = registerWritePortname.Text
        Dim devId As Byte = Convert.ToByte(registerWriteDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerWriteRegId.Value)
        Dim value As Single = 0
        Dim index As Int16 = Convert.ToInt16(registerWriteIndex.Value)

        Try
            value = Convert.ToSingle(registerWriteF32Value.Text)

            Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerWriteF32(portName, devId, regId, value, index)
            ShowRegisterResultTypes("registerWriteF32(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & value.ToString() & ", " & index.ToString() & ")", result)

        Catch ex As Exception

            StatusTextBox.AppendText(vbCrLf & "*** Invalid write value ***")

        End Try
    End Sub

    Private Sub registerWriteF64_Click(sender As Object, e As EventArgs) Handles registerWriteF64.Click
        Dim portName As String = registerWritePortname.Text
        Dim devId As Byte = Convert.ToByte(registerWriteDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerWriteRegId.Value)
        Dim value As Double = 0
        Dim index As Int16 = Convert.ToInt16(registerWriteIndex.Value)

        Try
            value = Convert.ToDouble(registerWriteF64Value.Text)

            Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerWriteF64(portName, devId, regId, value, index)
            ShowRegisterResultTypes("registerWriteF64(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & value.ToString() & ", " & index.ToString() & ")", result)

        Catch ex As Exception

            StatusTextBox.AppendText(vbCrLf & "*** Invalid write value ***")

        End Try
    End Sub

    Private Sub registerWriteAscii_Click(sender As Object, e As EventArgs) Handles registerWriteAscii.Click
        Dim portName As String = registerWritePortname.Text
        Dim devId As Byte = Convert.ToByte(registerWriteDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerWriteRegId.Value)
        Dim value As String = registerWriteAsciiValue.Text
        Dim wrEOL As Byte = Convert.ToByte(registerWriteAsciiEOL.Checked)
        Dim index As Int16 = Convert.ToInt16(registerWriteIndex.Value)

        Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerWriteAscii(portName, devId, regId, value, wrEOL, index)
        ShowRegisterResultTypes("registerWriteAscii(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & value.ToString() & ", " & wrEOL.ToString() & ", " & index.ToString() & ")", result)

    End Sub


    '*******************************************************************************************************
    ' Dedicated - Register write/read functions (A write immediately followed by a read)
    '*******************************************************************************************************

    Private Sub registerWriteReadU8_Click(sender As Object, e As EventArgs) Handles registerWriteReadU8.Click
        Dim portName As String = registerWriteReadPortname.Text
        Dim devId As Byte = Convert.ToByte(registerWriteReadDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerWriteReadRegId.Value)
        Dim index As Int16 = Convert.ToInt16(registerWriteReadIndex.Value)

        Try
            Dim wrValue As Byte = Convert.ToByte(registerWriteReadU8WrValue.Text)
            Dim rdValue As Byte = 0

            Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerWriteReadU8(portName, devId, regId, wrValue, rdValue, index)
            ShowRegisterResultTypes("registerWriteReadU8(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & wrValue.ToString() & ", " & "0, " & index.ToString() & ") : " & rdValue.ToString(), result)

        Catch ex As Exception
            StatusTextBox.AppendText(vbCrLf & "*** Invalid write value ***")
        End Try
    End Sub

    Private Sub registerWriteReadS8_Click(sender As Object, e As EventArgs) Handles registerWriteReadS8.Click
        Dim portName As String = registerWriteReadPortname.Text
        Dim devId As Byte = Convert.ToByte(registerWriteReadDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerWriteReadRegId.Value)
        Dim index As Int16 = Convert.ToInt16(registerWriteReadIndex.Value)

        Try
            Dim wrValue As SByte = Convert.ToSByte(registerWriteReadS8WrValue.Text)
            Dim rdValue As SByte = 0

            Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerWriteReadS8(portName, devId, regId, wrValue, rdValue, index)
            ShowRegisterResultTypes("registerWriteReadS8(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & wrValue.ToString() & ", " & "0, " & index.ToString() & ") : " & rdValue.ToString(), result)

        Catch ex As Exception
            StatusTextBox.AppendText(vbCrLf & "*** Invalid write value ***")
        End Try
    End Sub

    Private Sub registerWriteReadU16_Click(sender As Object, e As EventArgs) Handles registerWriteReadU16.Click
        Dim portName As String = registerWriteReadPortname.Text
        Dim devId As Byte = Convert.ToByte(registerWriteReadDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerWriteReadRegId.Value)
        Dim index As Int16 = Convert.ToInt16(registerWriteReadIndex.Value)

        Try
            Dim wrValue As UInt16 = Convert.ToUInt16(registerWriteReadU16WrValue.Text)
            Dim rdValue As UInt16 = 0

            Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerWriteReadU16(portName, devId, regId, wrValue, rdValue, index)
            ShowRegisterResultTypes("registerWriteReadU16(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & wrValue.ToString() & ", " & "0, " & index.ToString() & ") : " & rdValue.ToString(), result)

        Catch ex As Exception
            StatusTextBox.AppendText(vbCrLf & "*** Invalid write value ***")
        End Try
    End Sub

    Private Sub registerWriteReadS16_Click(sender As Object, e As EventArgs) Handles registerWriteReadS16.Click
        Dim portName As String = registerWriteReadPortname.Text
        Dim devId As Byte = Convert.ToByte(registerWriteReadDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerWriteReadRegId.Value)
        Dim index As Int16 = Convert.ToInt16(registerWriteReadIndex.Value)

        Try
            Dim wrValue As Int16 = Convert.ToInt16(registerWriteReadS16WrValue.Text)
            Dim rdValue As Int16 = 0

            Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerWriteReadS16(portName, devId, regId, wrValue, rdValue, index)
            ShowRegisterResultTypes("registerWriteReadS16(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & wrValue.ToString() & ", " & "0, " & index.ToString() & ") : " & rdValue.ToString(), result)

        Catch ex As Exception
            StatusTextBox.AppendText(vbCrLf & "*** Invalid write value ***")
        End Try
    End Sub

    Private Sub registerWriteReadU32_Click(sender As Object, e As EventArgs) Handles registerWriteReadU32.Click
        Dim portName As String = registerWriteReadPortname.Text
        Dim devId As Byte = Convert.ToByte(registerWriteReadDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerWriteReadRegId.Value)
        Dim index As Int16 = Convert.ToInt16(registerWriteReadIndex.Value)

        Try
            Dim wrValue As UInt32 = Convert.ToUInt32(registerWriteReadU32WrValue.Text)
            Dim rdValue As UInt32 = 0

            Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerWriteReadU32(portName, devId, regId, wrValue, rdValue, index)
            ShowRegisterResultTypes("registerWriteReadU32(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & wrValue.ToString() & ", " & "0, " & index.ToString() & ") : " & rdValue.ToString(), result)

        Catch ex As Exception
            StatusTextBox.AppendText(vbCrLf & "*** Invalid write value ***")
        End Try
    End Sub

    Private Sub registerWriteReadS32_Click(sender As Object, e As EventArgs) Handles registerWriteReadS32.Click
        Dim portName As String = registerWriteReadPortname.Text
        Dim devId As Byte = Convert.ToByte(registerWriteReadDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerWriteReadRegId.Value)
        Dim index As Int16 = Convert.ToInt16(registerWriteReadIndex.Value)

        Try
            Dim wrValue As Int32 = Convert.ToInt32(registerWriteReadS32WrValue.Text)
            Dim rdValue As Int32 = 0

            Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerWriteReadS32(portName, devId, regId, wrValue, rdValue, index)
            ShowRegisterResultTypes("registerWriteReadS32(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & wrValue.ToString() & ", " & "0, " & index.ToString() & ") : " & rdValue.ToString(), result)

        Catch ex As Exception
            StatusTextBox.AppendText(vbCrLf & "*** Invalid write value ***")
        End Try
    End Sub

    Private Sub registerWriteReadU64_Click(sender As Object, e As EventArgs) Handles registerWriteReadU64.Click
        Dim portName As String = registerWriteReadPortname.Text
        Dim devId As Byte = Convert.ToByte(registerWriteReadDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerWriteReadRegId.Value)
        Dim index As Int16 = Convert.ToInt16(registerWriteReadIndex.Value)

        Try
            Dim wrValue As UInt64 = Convert.ToUInt64(registerWriteReadU64WrValue.Text)
            Dim rdValue As UInt64 = 0

            Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerWriteReadU64(portName, devId, regId, wrValue, rdValue, index)
            ShowRegisterResultTypes("registerWriteReadU64(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & wrValue.ToString() & ", " & "0, " & index.ToString() & ") : " & rdValue.ToString(), result)

        Catch ex As Exception
            StatusTextBox.AppendText(vbCrLf & "*** Invalid write value ***")
        End Try
    End Sub

    Private Sub registerWriteReadS64_Click(sender As Object, e As EventArgs) Handles registerWriteReadS64.Click
        Dim portName As String = registerWriteReadPortname.Text
        Dim devId As Byte = Convert.ToByte(registerWriteReadDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerWriteReadRegId.Value)
        Dim index As Int16 = Convert.ToInt16(registerWriteReadIndex.Value)

        Try
            Dim wrValue As Int64 = Convert.ToInt64(registerWriteReadS64WrValue.Text)
            Dim rdValue As Int64 = 0

            Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerWriteReadS64(portName, devId, regId, wrValue, rdValue, index)
            ShowRegisterResultTypes("registerWriteReadS64(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & wrValue.ToString() & ", " & "0, " & index.ToString() & ") : " & rdValue.ToString(), result)

        Catch ex As Exception
            StatusTextBox.AppendText(vbCrLf & "*** Invalid write value ***")
        End Try
    End Sub

    Private Sub registerWriteReadF32_Click(sender As Object, e As EventArgs) Handles registerWriteReadF32.Click
        Dim portName As String = registerWriteReadPortname.Text
        Dim devId As Byte = Convert.ToByte(registerWriteReadDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerWriteReadRegId.Value)
        Dim index As Int16 = Convert.ToInt16(registerWriteReadIndex.Value)

        Try
            Dim wrValue As Single = Convert.ToSingle(registerWriteReadF32WrValue.Text)
            Dim rdValue As Single = 0

            Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerWriteReadF32(portName, devId, regId, wrValue, rdValue, index)
            ShowRegisterResultTypes("registerWriteReadF32(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & wrValue.ToString() & ", " & "0, " & index.ToString() & ") : " & rdValue.ToString(), result)

        Catch ex As Exception
            StatusTextBox.AppendText(vbCrLf & "*** Invalid write value ***")
        End Try
    End Sub

    Private Sub registerWriteReadF64_Click(sender As Object, e As EventArgs) Handles registerWriteReadF64.Click
        Dim portName As String = registerWriteReadPortname.Text
        Dim devId As Byte = Convert.ToByte(registerWriteReadDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerWriteReadRegId.Value)
        Dim index As Int16 = Convert.ToInt16(registerWriteReadIndex.Value)

        Try
            Dim wrValue As Double = Convert.ToDouble(registerWriteReadF64WrValue.Text)
            Dim rdValue As Double = 0

            Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerWriteReadF64(portName, devId, regId, wrValue, rdValue, index)
            ShowRegisterResultTypes("registerWriteReadF64(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", " & wrValue.ToString() & ", " & "0, " & index.ToString() & ") : " & rdValue.ToString(), result)

        Catch ex As Exception
            StatusTextBox.AppendText(vbCrLf & "*** Invalid write value ***")
        End Try
    End Sub

    Private Sub registerWriteReadAscii_Click(sender As Object, e As EventArgs) Handles registerWriteReadAscii.Click
        Dim portName As String = registerWriteReadPortname.Text
        Dim devId As Byte = Convert.ToByte(registerWriteReadDevId.Value)
        Dim regId As Byte = Convert.ToByte(registerWriteReadRegId.Value)

        Dim wrValue As String = registerWriteReadAsciiWrValue.Text

        Dim maxLen As Byte = 255
        Dim rdValue As StringBuilder = New StringBuilder(maxLen)

        Dim wrEOL As Byte = Convert.ToByte(registerWriteReadAsciiEOL.Checked)
        Dim index As Int16 = Convert.ToInt16(registerWriteReadIndex.Value)

        Dim result As NKTPDLL.RegisterResultTypes = NKTPDLL.registerWriteReadAscii(portName, devId, regId, wrValue, wrEOL, rdValue, maxLen, index)
        ShowRegisterResultTypes("registerWriteAscii(""" & portName.ToString() & """, " & devId.ToString() & ", 0x" & regId.ToString("X2") & ", """ & wrValue.ToString() & """, " & wrEOL.ToString() & ", """"" & ", " & index.ToString() & ", " & index.ToString() & ") : """ & rdVAlue.ToString() & """", result)

    End Sub

    '*******************************************************************************************************
    ' Dedicated - Device functions
    '*******************************************************************************************************

    Private Sub deviceGetType_Click(sender As Object, e As EventArgs) Handles deviceGetType.Click
        Dim portName As String = dedicatedDevicePortname.Text
        Dim devId As Byte = Convert.ToByte(dedicatedDeviceDevId.Value)
        Dim devType As Byte = 0

        Dim result As NKTPDLL.DeviceResultTypes = NKTPDLL.deviceGetType(portName, devId, devType)
        ShowDeviceResultTypes("deviceGetType(""" & portName.ToString() & """, " & devId.ToString() & ", 0) : 0x" & devType.ToString("X2"), result)

    End Sub

    Private Sub deviceGetPartnumberStr_Click(sender As Object, e As EventArgs) Handles deviceGetPartnumberStr.Click
        Dim portName As String = dedicatedDevicePortname.Text
        Dim devId As Byte = Convert.ToByte(dedicatedDeviceDevId.Value)
        Dim maxLen As Byte = 255
        Dim partnmb As StringBuilder = New StringBuilder(maxLen)

        Dim result As NKTPDLL.DeviceResultTypes = NKTPDLL.deviceGetPartNumberStr(portName, devId, partnmb, maxLen)
        ShowDeviceResultTypes("deviceGetPartNumberStr(""" & portName & """, " & devId.ToString() & ", """", " & maxLen & ") : """ & partnmb.ToString() & """", result)

    End Sub

    Private Sub deviceGetPCBVersion_Click(sender As Object, e As EventArgs) Handles deviceGetPCBVersion.Click
        Dim portName As String = dedicatedDevicePortname.Text
        Dim devId As Byte = Convert.ToByte(dedicatedDeviceDevId.Value)
        Dim pcbVer As Byte = 0

        Dim result As NKTPDLL.DeviceResultTypes = NKTPDLL.deviceGetPCBVersion(portName, devId, pcbVer)
        ShowDeviceResultTypes("deviceGetPCBVersion(""" & portName & """, " & devId.ToString() & ", 0) : " & pcbVer.ToString(), result)

    End Sub

    Private Sub deviceGetStatusBits_Click(sender As Object, e As EventArgs) Handles deviceGetStatusBits.Click
        Dim portName As String = dedicatedDevicePortname.Text
        Dim devId As Byte = Convert.ToByte(dedicatedDeviceDevId.Value)
        Dim statusBits As ULong = 0

        Dim result As NKTPDLL.DeviceResultTypes = NKTPDLL.deviceGetStatusBits(portName, devId, statusBits)
        ShowDeviceResultTypes("deviceGetStatusBits(""" & portName & """, " & devId.ToString() & ", 0) : 0x" & statusBits.ToString("X8"), result)

    End Sub

    Private Sub deviceGetErrorCode_Click(sender As Object, e As EventArgs) Handles deviceGetErrorCode.Click
        Dim portName As String = dedicatedDevicePortname.Text
        Dim devId As Byte = Convert.ToByte(dedicatedDeviceDevId.Value)
        Dim errorCode As UShort = 0

        Dim result As NKTPDLL.DeviceResultTypes = NKTPDLL.deviceGetErrorCode(portName, devId, errorCode)
        ShowDeviceResultTypes("deviceGetErrorCode(""" & portName & """, " & devId.ToString() & ", 0) : 0x" & errorCode.ToString("X4"), result)

    End Sub

    Private Sub deviceGetBootloaderVersion_Click(sender As Object, e As EventArgs) Handles deviceGetBootloaderVersion.Click
        Dim portName As String = dedicatedDevicePortname.Text
        Dim devId As Byte = Convert.ToByte(dedicatedDeviceDevId.Value)
        Dim blVer As UShort = 0

        Dim result As NKTPDLL.DeviceResultTypes = NKTPDLL.deviceGetBootloaderVersion(portName, devId, blVer)
        ShowDeviceResultTypes("deviceGetBootLoaderVersion(""" & portName & """, " & devId.ToString() & ", 0) : " & blVer.ToString(), result)

    End Sub

    Private Sub deviceGetBootloaderVersionStr_Click(sender As Object, e As EventArgs) Handles deviceGetBootloaderVersionStr.Click
        Dim portName As String = dedicatedDevicePortname.Text
        Dim devId As Byte = Convert.ToByte(dedicatedDeviceDevId.Value)
        Dim maxLen As Byte = 255
        Dim blVerStr As StringBuilder = New StringBuilder(maxLen)

        Dim result As NKTPDLL.DeviceResultTypes = NKTPDLL.deviceGetBootloaderVersionStr(portName, devId, blVerStr, maxLen)
        ShowDeviceResultTypes("deviceGetBootloaderVersionStr(""" & portName & """, " & devId.ToString() & ", """", " & maxLen & ") : """ & blVerStr.ToString() & """", result)

    End Sub

    Private Sub deviceGetFirmwareVersion_Click(sender As Object, e As EventArgs) Handles deviceGetFirmwareVersion.Click
        Dim portName As String = dedicatedDevicePortname.Text
        Dim devId As Byte = Convert.ToByte(dedicatedDeviceDevId.Value)
        Dim fwVer As UShort = 0

        Dim result As NKTPDLL.DeviceResultTypes = NKTPDLL.deviceGetFirmwareVersion(portName, devId, fwVer)
        ShowDeviceResultTypes("deviceGetFirmwareVersion(""" & portName & """, " & devId.ToString() & ", 0) : " & fwVer.ToString(), result)

    End Sub

    Private Sub deviceGetFirmwareVersionStr_Click(sender As Object, e As EventArgs) Handles deviceGetFirmwareVersionStr.Click
        Dim portName As String = dedicatedDevicePortname.Text
        Dim devId As Byte = Convert.ToByte(dedicatedDeviceDevId.Value)
        Dim maxLen As Byte = 255
        Dim fwVerStr As StringBuilder = New StringBuilder(maxLen)

        Dim result As NKTPDLL.DeviceResultTypes = NKTPDLL.deviceGetFirmwareVersionStr(portName, devId, fwVerStr, maxLen)
        ShowDeviceResultTypes("deviceGetFirmwareVersionStr(""" & portName & """, " & devId.ToString() & ", """", " & maxLen & ") : """ & fwVerStr.ToString() & """", result)

    End Sub

    Private Sub deviceGetModuleSerialNumberStr_Click(sender As Object, e As EventArgs) Handles deviceGetModuleSerialNumberStr.Click
        Dim portName As String = dedicatedDevicePortname.Text
        Dim devId As Byte = Convert.ToByte(dedicatedDeviceDevId.Value)
        Dim maxLen As Byte = 255
        Dim modSerialStr As StringBuilder = New StringBuilder(maxLen)

        Dim result As NKTPDLL.DeviceResultTypes = NKTPDLL.deviceGetModuleSerialNumberStr(portName, devId, modSerialStr, maxLen)
        ShowDeviceResultTypes("deviceGetModuleSerialNumberStr(""" & portName & """, " & devId.ToString() & ", """", " & maxLen & ") : """ & modSerialStr.ToString() & """", result)

    End Sub

    Private Sub deviceGetPCBSerialNumberStr_Click(sender As Object, e As EventArgs) Handles deviceGetPCBSerialNumberStr.Click
        Dim portName As String = dedicatedDevicePortname.Text
        Dim devId As Byte = Convert.ToByte(dedicatedDeviceDevId.Value)
        Dim maxLen As Byte = 255
        Dim pcbSerialStr As StringBuilder = New StringBuilder(maxLen)

        Dim result As NKTPDLL.DeviceResultTypes = NKTPDLL.deviceGetPCBSerialNumberStr(portName, devId, pcbSerialStr, maxLen)
        ShowDeviceResultTypes("deviceGetPCBSerialNumberStr(""" & portName & """, " & devId.ToString() & ", """", " & maxLen & ") : """ & pcbSerialStr.ToString() & """", result)

    End Sub
End Class
