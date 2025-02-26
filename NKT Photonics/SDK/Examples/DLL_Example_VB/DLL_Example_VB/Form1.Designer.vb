<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class Form1
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.tabControl1 = New System.Windows.Forms.TabControl()
        Me.tabPage0 = New System.Windows.Forms.TabPage()
        Me.panel9 = New System.Windows.Forms.Panel()
        Me.GetOpenPorts = New System.Windows.Forms.Button()
        Me.panel8 = New System.Windows.Forms.Panel()
        Me.GetAllPorts = New System.Windows.Forms.Button()
        Me.panel1 = New System.Windows.Forms.Panel()
        Me.checkBoxLiveMode = New System.Windows.Forms.CheckBox()
        Me.OpenPorts = New System.Windows.Forms.Button()
        Me.checkBoxAutoMode = New System.Windows.Forms.CheckBox()
        Me.openPortsPortname = New System.Windows.Forms.TextBox()
        Me.panel2 = New System.Windows.Forms.Panel()
        Me.ClosePorts = New System.Windows.Forms.Button()
        Me.closePortsPortname = New System.Windows.Forms.TextBox()
        Me.panel6 = New System.Windows.Forms.Panel()
        Me.label10 = New System.Windows.Forms.Label()
        Me.P2PPortGetTimeout = New System.Windows.Forms.TextBox()
        Me.label11 = New System.Windows.Forms.Label()
        Me.P2PPortGetProtocol = New System.Windows.Forms.ComboBox()
        Me.label12 = New System.Windows.Forms.Label()
        Me.P2PPortGetClientPort = New System.Windows.Forms.TextBox()
        Me.label13 = New System.Windows.Forms.Label()
        Me.P2PPortGetHostPort = New System.Windows.Forms.TextBox()
        Me.label14 = New System.Windows.Forms.Label()
        Me.P2PPortGetClientIP = New System.Windows.Forms.TextBox()
        Me.label15 = New System.Windows.Forms.Label()
        Me.P2PPortGetHostIP = New System.Windows.Forms.TextBox()
        Me.label16 = New System.Windows.Forms.Label()
        Me.pointToPointPortGet = New System.Windows.Forms.Button()
        Me.P2PPortGetName = New System.Windows.Forms.TextBox()
        Me.panel3 = New System.Windows.Forms.Panel()
        Me.label7 = New System.Windows.Forms.Label()
        Me.P2PPortAddTimeout = New System.Windows.Forms.TextBox()
        Me.label6 = New System.Windows.Forms.Label()
        Me.P2PPortAddProtocol = New System.Windows.Forms.ComboBox()
        Me.label5 = New System.Windows.Forms.Label()
        Me.P2PPortAddClientPort = New System.Windows.Forms.TextBox()
        Me.label4 = New System.Windows.Forms.Label()
        Me.P2PPortAddHostPort = New System.Windows.Forms.TextBox()
        Me.label3 = New System.Windows.Forms.Label()
        Me.P2PPortAddClientIP = New System.Windows.Forms.TextBox()
        Me.label2 = New System.Windows.Forms.Label()
        Me.P2PPortAddHostIP = New System.Windows.Forms.TextBox()
        Me.label1 = New System.Windows.Forms.Label()
        Me.PointToPointPortAdd = New System.Windows.Forms.Button()
        Me.P2PPortAddName = New System.Windows.Forms.TextBox()
        Me.panel7 = New System.Windows.Forms.Panel()
        Me.label23 = New System.Windows.Forms.Label()
        Me.pointToPointPortDel = New System.Windows.Forms.Button()
        Me.P2PPortDelName = New System.Windows.Forms.TextBox()
        Me.tabPage1 = New System.Windows.Forms.TabPage()
        Me.registerReadIndex = New System.Windows.Forms.NumericUpDown()
        Me.label8 = New System.Windows.Forms.Label()
        Me.registerReadDevId = New System.Windows.Forms.NumericUpDown()
        Me.label19 = New System.Windows.Forms.Label()
        Me.label22 = New System.Windows.Forms.Label()
        Me.registerReadPortname = New System.Windows.Forms.TextBox()
        Me.registerReadRegId = New System.Windows.Forms.NumericUpDown()
        Me.label30 = New System.Windows.Forms.Label()
        Me.registerReadAscii = New System.Windows.Forms.Button()
        Me.registerReadF64 = New System.Windows.Forms.Button()
        Me.registerReadF32 = New System.Windows.Forms.Button()
        Me.registerReadS64 = New System.Windows.Forms.Button()
        Me.registerReadU8 = New System.Windows.Forms.Button()
        Me.registerReadU64 = New System.Windows.Forms.Button()
        Me.registerReadS8 = New System.Windows.Forms.Button()
        Me.registerReadS32 = New System.Windows.Forms.Button()
        Me.registerReadU16 = New System.Windows.Forms.Button()
        Me.registerReadU32 = New System.Windows.Forms.Button()
        Me.registerReadS16 = New System.Windows.Forms.Button()
        Me.tabPage2 = New System.Windows.Forms.TabPage()
        Me.registerWriteAsciiEOL = New System.Windows.Forms.CheckBox()
        Me.registerWriteIndex = New System.Windows.Forms.NumericUpDown()
        Me.label20 = New System.Windows.Forms.Label()
        Me.registerWriteDevId = New System.Windows.Forms.NumericUpDown()
        Me.label25 = New System.Windows.Forms.Label()
        Me.label28 = New System.Windows.Forms.Label()
        Me.registerWritePortname = New System.Windows.Forms.TextBox()
        Me.registerWriteRegId = New System.Windows.Forms.NumericUpDown()
        Me.label29 = New System.Windows.Forms.Label()
        Me.label9 = New System.Windows.Forms.Label()
        Me.registerWriteAsciiValue = New System.Windows.Forms.TextBox()
        Me.registerWriteF64Value = New System.Windows.Forms.TextBox()
        Me.registerWriteF32Value = New System.Windows.Forms.TextBox()
        Me.registerWriteS64Value = New System.Windows.Forms.TextBox()
        Me.registerWriteU64Value = New System.Windows.Forms.TextBox()
        Me.registerWriteS32Value = New System.Windows.Forms.TextBox()
        Me.registerWriteU32Value = New System.Windows.Forms.TextBox()
        Me.registerWriteS16Value = New System.Windows.Forms.TextBox()
        Me.registerWriteU16Value = New System.Windows.Forms.TextBox()
        Me.registerWriteS8Value = New System.Windows.Forms.TextBox()
        Me.registerWriteU8Value = New System.Windows.Forms.TextBox()
        Me.registerWriteAscii = New System.Windows.Forms.Button()
        Me.registerWriteF64 = New System.Windows.Forms.Button()
        Me.registerWriteF32 = New System.Windows.Forms.Button()
        Me.registerWriteS64 = New System.Windows.Forms.Button()
        Me.registerWriteU8 = New System.Windows.Forms.Button()
        Me.registerWriteU64 = New System.Windows.Forms.Button()
        Me.registerWriteS8 = New System.Windows.Forms.Button()
        Me.registerWriteS32 = New System.Windows.Forms.Button()
        Me.registerWriteU16 = New System.Windows.Forms.Button()
        Me.registerWriteU32 = New System.Windows.Forms.Button()
        Me.registerWriteS16 = New System.Windows.Forms.Button()
        Me.tabPage3 = New System.Windows.Forms.TabPage()
        Me.registerWriteReadAsciiEOL = New System.Windows.Forms.CheckBox()
        Me.registerWriteReadAscii = New System.Windows.Forms.Button()
        Me.registerWriteReadIndex = New System.Windows.Forms.NumericUpDown()
        Me.label17 = New System.Windows.Forms.Label()
        Me.registerWriteReadDevId = New System.Windows.Forms.NumericUpDown()
        Me.label24 = New System.Windows.Forms.Label()
        Me.label26 = New System.Windows.Forms.Label()
        Me.registerWriteReadPortname = New System.Windows.Forms.TextBox()
        Me.registerWriteReadRegId = New System.Windows.Forms.NumericUpDown()
        Me.label27 = New System.Windows.Forms.Label()
        Me.label18 = New System.Windows.Forms.Label()
        Me.registerWriteReadAsciiWrValue = New System.Windows.Forms.TextBox()
        Me.registerWriteReadF64WrValue = New System.Windows.Forms.TextBox()
        Me.registerWriteReadF32WrValue = New System.Windows.Forms.TextBox()
        Me.registerWriteReadS64WrValue = New System.Windows.Forms.TextBox()
        Me.registerWriteReadU64WrValue = New System.Windows.Forms.TextBox()
        Me.registerWriteReadS32WrValue = New System.Windows.Forms.TextBox()
        Me.registerWriteReadU32WrValue = New System.Windows.Forms.TextBox()
        Me.registerWriteReadS16WrValue = New System.Windows.Forms.TextBox()
        Me.registerWriteReadU16WrValue = New System.Windows.Forms.TextBox()
        Me.registerWriteReadS8WrValue = New System.Windows.Forms.TextBox()
        Me.registerWriteReadU8WrValue = New System.Windows.Forms.TextBox()
        Me.registerWriteReadF64 = New System.Windows.Forms.Button()
        Me.registerWriteReadF32 = New System.Windows.Forms.Button()
        Me.registerWriteReadS64 = New System.Windows.Forms.Button()
        Me.registerWriteReadU64 = New System.Windows.Forms.Button()
        Me.registerWriteReadS32 = New System.Windows.Forms.Button()
        Me.registerWriteReadU32 = New System.Windows.Forms.Button()
        Me.registerWriteReadS16 = New System.Windows.Forms.Button()
        Me.registerWriteReadU16 = New System.Windows.Forms.Button()
        Me.registerWriteReadS8 = New System.Windows.Forms.Button()
        Me.registerWriteReadU8 = New System.Windows.Forms.Button()
        Me.tabPage4 = New System.Windows.Forms.TabPage()
        Me.deviceGetPCBSerialNumberStr = New System.Windows.Forms.Button()
        Me.deviceGetModuleSerialNumberStr = New System.Windows.Forms.Button()
        Me.deviceGetFirmwareVersionStr = New System.Windows.Forms.Button()
        Me.deviceGetFirmwareVersion = New System.Windows.Forms.Button()
        Me.deviceGetBootloaderVersionStr = New System.Windows.Forms.Button()
        Me.deviceGetBootloaderVersion = New System.Windows.Forms.Button()
        Me.deviceGetErrorCode = New System.Windows.Forms.Button()
        Me.deviceGetStatusBits = New System.Windows.Forms.Button()
        Me.deviceGetPCBVersion = New System.Windows.Forms.Button()
        Me.deviceGetPartnumberStr = New System.Windows.Forms.Button()
        Me.dedicatedDeviceDevId = New System.Windows.Forms.NumericUpDown()
        Me.label31 = New System.Windows.Forms.Label()
        Me.label32 = New System.Windows.Forms.Label()
        Me.dedicatedDevicePortname = New System.Windows.Forms.TextBox()
        Me.deviceGetType = New System.Windows.Forms.Button()
        Me.ExitButton = New System.Windows.Forms.Button()
        Me.StatusTextBox = New System.Windows.Forms.TextBox()
        Me.tabControl1.SuspendLayout()
        Me.tabPage0.SuspendLayout()
        Me.panel9.SuspendLayout()
        Me.panel8.SuspendLayout()
        Me.panel1.SuspendLayout()
        Me.panel2.SuspendLayout()
        Me.panel6.SuspendLayout()
        Me.panel3.SuspendLayout()
        Me.panel7.SuspendLayout()
        Me.tabPage1.SuspendLayout()
        CType(Me.registerReadIndex, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.registerReadDevId, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.registerReadRegId, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.tabPage2.SuspendLayout()
        CType(Me.registerWriteIndex, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.registerWriteDevId, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.registerWriteRegId, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.tabPage3.SuspendLayout()
        CType(Me.registerWriteReadIndex, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.registerWriteReadDevId, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.registerWriteReadRegId, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.tabPage4.SuspendLayout()
        CType(Me.dedicatedDeviceDevId, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.SuspendLayout()
        '
        'tabControl1
        '
        Me.tabControl1.Controls.Add(Me.tabPage0)
        Me.tabControl1.Controls.Add(Me.tabPage1)
        Me.tabControl1.Controls.Add(Me.tabPage2)
        Me.tabControl1.Controls.Add(Me.tabPage3)
        Me.tabControl1.Controls.Add(Me.tabPage4)
        Me.tabControl1.Location = New System.Drawing.Point(12, 12)
        Me.tabControl1.Name = "tabControl1"
        Me.tabControl1.SelectedIndex = 0
        Me.tabControl1.Size = New System.Drawing.Size(780, 400)
        Me.tabControl1.TabIndex = 19
        '
        'tabPage0
        '
        Me.tabPage0.Controls.Add(Me.panel9)
        Me.tabPage0.Controls.Add(Me.panel8)
        Me.tabPage0.Controls.Add(Me.panel1)
        Me.tabPage0.Controls.Add(Me.panel2)
        Me.tabPage0.Controls.Add(Me.panel6)
        Me.tabPage0.Controls.Add(Me.panel3)
        Me.tabPage0.Controls.Add(Me.panel7)
        Me.tabPage0.Location = New System.Drawing.Point(4, 22)
        Me.tabPage0.Name = "tabPage0"
        Me.tabPage0.Size = New System.Drawing.Size(772, 374)
        Me.tabPage0.TabIndex = 3
        Me.tabPage0.Text = "Port Functions"
        Me.tabPage0.UseVisualStyleBackColor = True
        '
        'panel9
        '
        Me.panel9.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.panel9.Controls.Add(Me.GetOpenPorts)
        Me.panel9.Location = New System.Drawing.Point(97, 4)
        Me.panel9.Name = "panel9"
        Me.panel9.Size = New System.Drawing.Size(100, 32)
        Me.panel9.TabIndex = 0
        '
        'GetOpenPorts
        '
        Me.GetOpenPorts.Location = New System.Drawing.Point(3, 4)
        Me.GetOpenPorts.Name = "GetOpenPorts"
        Me.GetOpenPorts.Size = New System.Drawing.Size(87, 23)
        Me.GetOpenPorts.TabIndex = 2
        Me.GetOpenPorts.Text = "getOpenPorts"
        Me.GetOpenPorts.UseVisualStyleBackColor = True
        '
        'panel8
        '
        Me.panel8.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.panel8.Controls.Add(Me.GetAllPorts)
        Me.panel8.Location = New System.Drawing.Point(3, 4)
        Me.panel8.Name = "panel8"
        Me.panel8.Size = New System.Drawing.Size(88, 32)
        Me.panel8.TabIndex = 32
        '
        'GetAllPorts
        '
        Me.GetAllPorts.Location = New System.Drawing.Point(4, 3)
        Me.GetAllPorts.Name = "GetAllPorts"
        Me.GetAllPorts.Size = New System.Drawing.Size(75, 23)
        Me.GetAllPorts.TabIndex = 1
        Me.GetAllPorts.Text = "getAllPorts"
        Me.GetAllPorts.UseVisualStyleBackColor = True
        '
        'panel1
        '
        Me.panel1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.panel1.Controls.Add(Me.checkBoxLiveMode)
        Me.panel1.Controls.Add(Me.OpenPorts)
        Me.panel1.Controls.Add(Me.checkBoxAutoMode)
        Me.panel1.Controls.Add(Me.openPortsPortname)
        Me.panel1.Location = New System.Drawing.Point(3, 186)
        Me.panel1.Name = "panel1"
        Me.panel1.Size = New System.Drawing.Size(429, 32)
        Me.panel1.TabIndex = 4
        '
        'checkBoxLiveMode
        '
        Me.checkBoxLiveMode.AutoSize = True
        Me.checkBoxLiveMode.Location = New System.Drawing.Point(358, 7)
        Me.checkBoxLiveMode.Name = "checkBoxLiveMode"
        Me.checkBoxLiveMode.Size = New System.Drawing.Size(69, 17)
        Me.checkBoxLiveMode.TabIndex = 18
        Me.checkBoxLiveMode.Text = "liveMode"
        Me.checkBoxLiveMode.UseVisualStyleBackColor = True
        '
        'OpenPorts
        '
        Me.OpenPorts.Location = New System.Drawing.Point(3, 3)
        Me.OpenPorts.Name = "OpenPorts"
        Me.OpenPorts.Size = New System.Drawing.Size(75, 23)
        Me.OpenPorts.TabIndex = 15
        Me.OpenPorts.Text = "openPorts"
        Me.OpenPorts.UseVisualStyleBackColor = True
        '
        'checkBoxAutoMode
        '
        Me.checkBoxAutoMode.AutoSize = True
        Me.checkBoxAutoMode.Location = New System.Drawing.Point(278, 7)
        Me.checkBoxAutoMode.Name = "checkBoxAutoMode"
        Me.checkBoxAutoMode.Size = New System.Drawing.Size(74, 17)
        Me.checkBoxAutoMode.TabIndex = 17
        Me.checkBoxAutoMode.Text = "autoMode"
        Me.checkBoxAutoMode.UseVisualStyleBackColor = True
        '
        'openPortsPortname
        '
        Me.openPortsPortname.Location = New System.Drawing.Point(84, 5)
        Me.openPortsPortname.Name = "openPortsPortname"
        Me.openPortsPortname.Size = New System.Drawing.Size(188, 20)
        Me.openPortsPortname.TabIndex = 16
        '
        'panel2
        '
        Me.panel2.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.panel2.Controls.Add(Me.ClosePorts)
        Me.panel2.Controls.Add(Me.closePortsPortname)
        Me.panel2.Location = New System.Drawing.Point(438, 186)
        Me.panel2.Name = "panel2"
        Me.panel2.Size = New System.Drawing.Size(284, 32)
        Me.panel2.TabIndex = 5
        '
        'ClosePorts
        '
        Me.ClosePorts.Location = New System.Drawing.Point(3, 3)
        Me.ClosePorts.Name = "ClosePorts"
        Me.ClosePorts.Size = New System.Drawing.Size(75, 21)
        Me.ClosePorts.TabIndex = 19
        Me.ClosePorts.Text = "closePorts"
        Me.ClosePorts.UseVisualStyleBackColor = True
        '
        'closePortsPortname
        '
        Me.closePortsPortname.Location = New System.Drawing.Point(84, 4)
        Me.closePortsPortname.Name = "closePortsPortname"
        Me.closePortsPortname.Size = New System.Drawing.Size(188, 20)
        Me.closePortsPortname.TabIndex = 20
        '
        'panel6
        '
        Me.panel6.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.panel6.Controls.Add(Me.label10)
        Me.panel6.Controls.Add(Me.P2PPortGetTimeout)
        Me.panel6.Controls.Add(Me.label11)
        Me.panel6.Controls.Add(Me.P2PPortGetProtocol)
        Me.panel6.Controls.Add(Me.label12)
        Me.panel6.Controls.Add(Me.P2PPortGetClientPort)
        Me.panel6.Controls.Add(Me.label13)
        Me.panel6.Controls.Add(Me.P2PPortGetHostPort)
        Me.panel6.Controls.Add(Me.label14)
        Me.panel6.Controls.Add(Me.P2PPortGetClientIP)
        Me.panel6.Controls.Add(Me.label15)
        Me.panel6.Controls.Add(Me.P2PPortGetHostIP)
        Me.panel6.Controls.Add(Me.label16)
        Me.panel6.Controls.Add(Me.pointToPointPortGet)
        Me.panel6.Controls.Add(Me.P2PPortGetName)
        Me.panel6.Location = New System.Drawing.Point(3, 90)
        Me.panel6.Name = "panel6"
        Me.panel6.Size = New System.Drawing.Size(765, 42)
        Me.panel6.TabIndex = 2
        '
        'label10
        '
        Me.label10.AutoSize = True
        Me.label10.Location = New System.Drawing.Point(703, 0)
        Me.label10.Name = "label10"
        Me.label10.Size = New System.Drawing.Size(48, 13)
        Me.label10.TabIndex = 13
        Me.label10.Text = "Timeout:"
        '
        'P2PPortGetTimeout
        '
        Me.P2PPortGetTimeout.Location = New System.Drawing.Point(703, 16)
        Me.P2PPortGetTimeout.Name = "P2PPortGetTimeout"
        Me.P2PPortGetTimeout.ReadOnly = True
        Me.P2PPortGetTimeout.Size = New System.Drawing.Size(48, 20)
        Me.P2PPortGetTimeout.TabIndex = 14
        Me.P2PPortGetTimeout.TabStop = False
        Me.P2PPortGetTimeout.Text = "100"
        '
        'label11
        '
        Me.label11.AutoSize = True
        Me.label11.Location = New System.Drawing.Point(651, 0)
        Me.label11.Name = "label11"
        Me.label11.Size = New System.Drawing.Size(49, 13)
        Me.label11.TabIndex = 11
        Me.label11.Text = "Protocol:"
        '
        'P2PPortGetProtocol
        '
        Me.P2PPortGetProtocol.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.P2PPortGetProtocol.Enabled = False
        Me.P2PPortGetProtocol.FormattingEnabled = True
        Me.P2PPortGetProtocol.Items.AddRange(New Object() {"TCP", "UDP"})
        Me.P2PPortGetProtocol.Location = New System.Drawing.Point(651, 15)
        Me.P2PPortGetProtocol.Name = "P2PPortGetProtocol"
        Me.P2PPortGetProtocol.Size = New System.Drawing.Size(46, 21)
        Me.P2PPortGetProtocol.TabIndex = 12
        Me.P2PPortGetProtocol.TabStop = False
        '
        'label12
        '
        Me.label12.AutoSize = True
        Me.label12.Location = New System.Drawing.Point(594, 0)
        Me.label12.Name = "label12"
        Me.label12.Size = New System.Drawing.Size(58, 13)
        Me.label12.TabIndex = 9
        Me.label12.Text = "Client Port:"
        '
        'P2PPortGetClientPort
        '
        Me.P2PPortGetClientPort.Location = New System.Drawing.Point(597, 16)
        Me.P2PPortGetClientPort.Name = "P2PPortGetClientPort"
        Me.P2PPortGetClientPort.ReadOnly = True
        Me.P2PPortGetClientPort.Size = New System.Drawing.Size(48, 20)
        Me.P2PPortGetClientPort.TabIndex = 10
        Me.P2PPortGetClientPort.TabStop = False
        Me.P2PPortGetClientPort.Text = "10001"
        '
        'label13
        '
        Me.label13.AutoSize = True
        Me.label13.Location = New System.Drawing.Point(431, 0)
        Me.label13.Name = "label13"
        Me.label13.Size = New System.Drawing.Size(54, 13)
        Me.label13.TabIndex = 5
        Me.label13.Text = "Host Port:"
        '
        'P2PPortGetHostPort
        '
        Me.P2PPortGetHostPort.Location = New System.Drawing.Point(434, 16)
        Me.P2PPortGetHostPort.Name = "P2PPortGetHostPort"
        Me.P2PPortGetHostPort.ReadOnly = True
        Me.P2PPortGetHostPort.Size = New System.Drawing.Size(48, 20)
        Me.P2PPortGetHostPort.TabIndex = 6
        Me.P2PPortGetHostPort.TabStop = False
        Me.P2PPortGetHostPort.Text = "10001"
        '
        'label14
        '
        Me.label14.AutoSize = True
        Me.label14.Location = New System.Drawing.Point(500, 0)
        Me.label14.Name = "label14"
        Me.label14.Size = New System.Drawing.Size(77, 13)
        Me.label14.TabIndex = 7
        Me.label14.Text = "Client Address:"
        '
        'P2PPortGetClientIP
        '
        Me.P2PPortGetClientIP.Location = New System.Drawing.Point(488, 16)
        Me.P2PPortGetClientIP.Name = "P2PPortGetClientIP"
        Me.P2PPortGetClientIP.ReadOnly = True
        Me.P2PPortGetClientIP.Size = New System.Drawing.Size(103, 20)
        Me.P2PPortGetClientIP.TabIndex = 8
        Me.P2PPortGetClientIP.TabStop = False
        Me.P2PPortGetClientIP.Text = "192.168.1.23"
        '
        'label15
        '
        Me.label15.AutoSize = True
        Me.label15.Location = New System.Drawing.Point(324, 0)
        Me.label15.Name = "label15"
        Me.label15.Size = New System.Drawing.Size(104, 13)
        Me.label15.TabIndex = 3
        Me.label15.Text = "Host Address (local):"
        '
        'P2PPortGetHostIP
        '
        Me.P2PPortGetHostIP.Location = New System.Drawing.Point(325, 16)
        Me.P2PPortGetHostIP.Name = "P2PPortGetHostIP"
        Me.P2PPortGetHostIP.ReadOnly = True
        Me.P2PPortGetHostIP.Size = New System.Drawing.Size(103, 20)
        Me.P2PPortGetHostIP.TabIndex = 13
        Me.P2PPortGetHostIP.TabStop = False
        Me.P2PPortGetHostIP.Text = "192.168.1.22"
        '
        'label16
        '
        Me.label16.AutoSize = True
        Me.label16.Location = New System.Drawing.Point(197, 0)
        Me.label16.Name = "label16"
        Me.label16.Size = New System.Drawing.Size(55, 13)
        Me.label16.TabIndex = 1
        Me.label16.Text = "Portname:"
        '
        'pointToPointPortGet
        '
        Me.pointToPointPortGet.Location = New System.Drawing.Point(3, 15)
        Me.pointToPointPortGet.Name = "pointToPointPortGet"
        Me.pointToPointPortGet.Size = New System.Drawing.Size(122, 21)
        Me.pointToPointPortGet.TabIndex = 11
        Me.pointToPointPortGet.Text = "pointToPointPortGet"
        Me.pointToPointPortGet.UseVisualStyleBackColor = True
        '
        'P2PPortGetName
        '
        Me.P2PPortGetName.Location = New System.Drawing.Point(131, 16)
        Me.P2PPortGetName.Name = "P2PPortGetName"
        Me.P2PPortGetName.Size = New System.Drawing.Size(188, 20)
        Me.P2PPortGetName.TabIndex = 12
        Me.P2PPortGetName.Text = "MyNewPort"
        '
        'panel3
        '
        Me.panel3.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.panel3.Controls.Add(Me.label7)
        Me.panel3.Controls.Add(Me.P2PPortAddTimeout)
        Me.panel3.Controls.Add(Me.label6)
        Me.panel3.Controls.Add(Me.P2PPortAddProtocol)
        Me.panel3.Controls.Add(Me.label5)
        Me.panel3.Controls.Add(Me.P2PPortAddClientPort)
        Me.panel3.Controls.Add(Me.label4)
        Me.panel3.Controls.Add(Me.P2PPortAddHostPort)
        Me.panel3.Controls.Add(Me.label3)
        Me.panel3.Controls.Add(Me.P2PPortAddClientIP)
        Me.panel3.Controls.Add(Me.label2)
        Me.panel3.Controls.Add(Me.P2PPortAddHostIP)
        Me.panel3.Controls.Add(Me.label1)
        Me.panel3.Controls.Add(Me.PointToPointPortAdd)
        Me.panel3.Controls.Add(Me.P2PPortAddName)
        Me.panel3.Location = New System.Drawing.Point(3, 42)
        Me.panel3.Name = "panel3"
        Me.panel3.Size = New System.Drawing.Size(765, 42)
        Me.panel3.TabIndex = 1
        '
        'label7
        '
        Me.label7.AutoSize = True
        Me.label7.Location = New System.Drawing.Point(703, 0)
        Me.label7.Name = "label7"
        Me.label7.Size = New System.Drawing.Size(48, 13)
        Me.label7.TabIndex = 13
        Me.label7.Text = "Timeout:"
        '
        'P2PPortAddTimeout
        '
        Me.P2PPortAddTimeout.Location = New System.Drawing.Point(703, 16)
        Me.P2PPortAddTimeout.Name = "P2PPortAddTimeout"
        Me.P2PPortAddTimeout.Size = New System.Drawing.Size(48, 20)
        Me.P2PPortAddTimeout.TabIndex = 10
        Me.P2PPortAddTimeout.Text = "100"
        '
        'label6
        '
        Me.label6.AutoSize = True
        Me.label6.Location = New System.Drawing.Point(651, 0)
        Me.label6.Name = "label6"
        Me.label6.Size = New System.Drawing.Size(49, 13)
        Me.label6.TabIndex = 11
        Me.label6.Text = "Protocol:"
        '
        'P2PPortAddProtocol
        '
        Me.P2PPortAddProtocol.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.P2PPortAddProtocol.FormattingEnabled = True
        Me.P2PPortAddProtocol.Items.AddRange(New Object() {"TCP", "UDP"})
        Me.P2PPortAddProtocol.Location = New System.Drawing.Point(651, 15)
        Me.P2PPortAddProtocol.Name = "P2PPortAddProtocol"
        Me.P2PPortAddProtocol.Size = New System.Drawing.Size(46, 21)
        Me.P2PPortAddProtocol.TabIndex = 9
        '
        'label5
        '
        Me.label5.AutoSize = True
        Me.label5.Location = New System.Drawing.Point(594, 0)
        Me.label5.Name = "label5"
        Me.label5.Size = New System.Drawing.Size(58, 13)
        Me.label5.TabIndex = 9
        Me.label5.Text = "Client Port:"
        '
        'P2PPortAddClientPort
        '
        Me.P2PPortAddClientPort.Location = New System.Drawing.Point(597, 16)
        Me.P2PPortAddClientPort.Name = "P2PPortAddClientPort"
        Me.P2PPortAddClientPort.Size = New System.Drawing.Size(48, 20)
        Me.P2PPortAddClientPort.TabIndex = 8
        Me.P2PPortAddClientPort.Text = "10001"
        '
        'label4
        '
        Me.label4.AutoSize = True
        Me.label4.Location = New System.Drawing.Point(431, 0)
        Me.label4.Name = "label4"
        Me.label4.Size = New System.Drawing.Size(54, 13)
        Me.label4.TabIndex = 5
        Me.label4.Text = "Host Port:"
        '
        'P2PPortAddHostPort
        '
        Me.P2PPortAddHostPort.Location = New System.Drawing.Point(434, 16)
        Me.P2PPortAddHostPort.Name = "P2PPortAddHostPort"
        Me.P2PPortAddHostPort.Size = New System.Drawing.Size(48, 20)
        Me.P2PPortAddHostPort.TabIndex = 6
        Me.P2PPortAddHostPort.Text = "10001"
        '
        'label3
        '
        Me.label3.AutoSize = True
        Me.label3.Location = New System.Drawing.Point(500, 0)
        Me.label3.Name = "label3"
        Me.label3.Size = New System.Drawing.Size(77, 13)
        Me.label3.TabIndex = 7
        Me.label3.Text = "Client Address:"
        '
        'P2PPortAddClientIP
        '
        Me.P2PPortAddClientIP.Location = New System.Drawing.Point(488, 16)
        Me.P2PPortAddClientIP.Name = "P2PPortAddClientIP"
        Me.P2PPortAddClientIP.Size = New System.Drawing.Size(103, 20)
        Me.P2PPortAddClientIP.TabIndex = 7
        Me.P2PPortAddClientIP.Text = "192.168.1.23"
        '
        'label2
        '
        Me.label2.AutoSize = True
        Me.label2.Location = New System.Drawing.Point(324, 0)
        Me.label2.Name = "label2"
        Me.label2.Size = New System.Drawing.Size(104, 13)
        Me.label2.TabIndex = 3
        Me.label2.Text = "Host Address (local):"
        '
        'P2PPortAddHostIP
        '
        Me.P2PPortAddHostIP.Location = New System.Drawing.Point(325, 16)
        Me.P2PPortAddHostIP.Name = "P2PPortAddHostIP"
        Me.P2PPortAddHostIP.Size = New System.Drawing.Size(103, 20)
        Me.P2PPortAddHostIP.TabIndex = 5
        Me.P2PPortAddHostIP.Text = "192.168.1.22"
        '
        'label1
        '
        Me.label1.AutoSize = True
        Me.label1.Location = New System.Drawing.Point(197, 0)
        Me.label1.Name = "label1"
        Me.label1.Size = New System.Drawing.Size(55, 13)
        Me.label1.TabIndex = 1
        Me.label1.Text = "Portname:"
        '
        'PointToPointPortAdd
        '
        Me.PointToPointPortAdd.Location = New System.Drawing.Point(3, 15)
        Me.PointToPointPortAdd.Name = "PointToPointPortAdd"
        Me.PointToPointPortAdd.Size = New System.Drawing.Size(122, 21)
        Me.PointToPointPortAdd.TabIndex = 3
        Me.PointToPointPortAdd.Text = "pointToPointPortAdd"
        Me.PointToPointPortAdd.UseVisualStyleBackColor = True
        '
        'P2PPortAddName
        '
        Me.P2PPortAddName.Location = New System.Drawing.Point(131, 16)
        Me.P2PPortAddName.Name = "P2PPortAddName"
        Me.P2PPortAddName.Size = New System.Drawing.Size(188, 20)
        Me.P2PPortAddName.TabIndex = 4
        Me.P2PPortAddName.Text = "MyNewPort"
        '
        'panel7
        '
        Me.panel7.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.panel7.Controls.Add(Me.label23)
        Me.panel7.Controls.Add(Me.pointToPointPortDel)
        Me.panel7.Controls.Add(Me.P2PPortDelName)
        Me.panel7.Location = New System.Drawing.Point(3, 138)
        Me.panel7.Name = "panel7"
        Me.panel7.Size = New System.Drawing.Size(330, 42)
        Me.panel7.TabIndex = 3
        '
        'label23
        '
        Me.label23.AutoSize = True
        Me.label23.Location = New System.Drawing.Point(197, 0)
        Me.label23.Name = "label23"
        Me.label23.Size = New System.Drawing.Size(55, 13)
        Me.label23.TabIndex = 1
        Me.label23.Text = "Portname:"
        '
        'pointToPointPortDel
        '
        Me.pointToPointPortDel.Location = New System.Drawing.Point(3, 15)
        Me.pointToPointPortDel.Name = "pointToPointPortDel"
        Me.pointToPointPortDel.Size = New System.Drawing.Size(122, 21)
        Me.pointToPointPortDel.TabIndex = 13
        Me.pointToPointPortDel.Text = "pointToPointPortDel"
        Me.pointToPointPortDel.UseVisualStyleBackColor = True
        '
        'P2PPortDelName
        '
        Me.P2PPortDelName.Location = New System.Drawing.Point(131, 16)
        Me.P2PPortDelName.Name = "P2PPortDelName"
        Me.P2PPortDelName.Size = New System.Drawing.Size(188, 20)
        Me.P2PPortDelName.TabIndex = 14
        Me.P2PPortDelName.Text = "MyNewPort"
        '
        'tabPage1
        '
        Me.tabPage1.Controls.Add(Me.registerReadIndex)
        Me.tabPage1.Controls.Add(Me.label8)
        Me.tabPage1.Controls.Add(Me.registerReadDevId)
        Me.tabPage1.Controls.Add(Me.label19)
        Me.tabPage1.Controls.Add(Me.label22)
        Me.tabPage1.Controls.Add(Me.registerReadPortname)
        Me.tabPage1.Controls.Add(Me.registerReadRegId)
        Me.tabPage1.Controls.Add(Me.label30)
        Me.tabPage1.Controls.Add(Me.registerReadAscii)
        Me.tabPage1.Controls.Add(Me.registerReadF64)
        Me.tabPage1.Controls.Add(Me.registerReadF32)
        Me.tabPage1.Controls.Add(Me.registerReadS64)
        Me.tabPage1.Controls.Add(Me.registerReadU8)
        Me.tabPage1.Controls.Add(Me.registerReadU64)
        Me.tabPage1.Controls.Add(Me.registerReadS8)
        Me.tabPage1.Controls.Add(Me.registerReadS32)
        Me.tabPage1.Controls.Add(Me.registerReadU16)
        Me.tabPage1.Controls.Add(Me.registerReadU32)
        Me.tabPage1.Controls.Add(Me.registerReadS16)
        Me.tabPage1.Location = New System.Drawing.Point(4, 22)
        Me.tabPage1.Name = "tabPage1"
        Me.tabPage1.Padding = New System.Windows.Forms.Padding(3)
        Me.tabPage1.Size = New System.Drawing.Size(772, 374)
        Me.tabPage1.TabIndex = 0
        Me.tabPage1.Text = "registerRead Functions"
        Me.tabPage1.UseVisualStyleBackColor = True
        '
        'registerReadIndex
        '
        Me.registerReadIndex.Location = New System.Drawing.Point(221, 19)
        Me.registerReadIndex.Maximum = New Decimal(New Integer() {255, 0, 0, 0})
        Me.registerReadIndex.Minimum = New Decimal(New Integer() {1, 0, 0, -2147483648})
        Me.registerReadIndex.Name = "registerReadIndex"
        Me.registerReadIndex.Size = New System.Drawing.Size(42, 20)
        Me.registerReadIndex.TabIndex = 7
        Me.registerReadIndex.TextAlign = System.Windows.Forms.HorizontalAlignment.Right
        Me.registerReadIndex.Value = New Decimal(New Integer() {1, 0, 0, -2147483648})
        '
        'label8
        '
        Me.label8.AutoSize = True
        Me.label8.Location = New System.Drawing.Point(218, 3)
        Me.label8.Name = "label8"
        Me.label8.Size = New System.Drawing.Size(36, 13)
        Me.label8.TabIndex = 6
        Me.label8.Text = "Index:"
        '
        'registerReadDevId
        '
        Me.registerReadDevId.Location = New System.Drawing.Point(119, 19)
        Me.registerReadDevId.Maximum = New Decimal(New Integer() {255, 0, 0, 0})
        Me.registerReadDevId.Minimum = New Decimal(New Integer() {1, 0, 0, 0})
        Me.registerReadDevId.Name = "registerReadDevId"
        Me.registerReadDevId.Size = New System.Drawing.Size(42, 20)
        Me.registerReadDevId.TabIndex = 3
        Me.registerReadDevId.TextAlign = System.Windows.Forms.HorizontalAlignment.Right
        Me.registerReadDevId.Value = New Decimal(New Integer() {1, 0, 0, 0})
        '
        'label19
        '
        Me.label19.AutoSize = True
        Me.label19.Location = New System.Drawing.Point(116, 3)
        Me.label19.Name = "label19"
        Me.label19.Size = New System.Drawing.Size(45, 13)
        Me.label19.TabIndex = 2
        Me.label19.Text = "Dev. Id:"
        '
        'label22
        '
        Me.label22.AutoSize = True
        Me.label22.Location = New System.Drawing.Point(6, 3)
        Me.label22.Name = "label22"
        Me.label22.Size = New System.Drawing.Size(55, 13)
        Me.label22.TabIndex = 0
        Me.label22.Text = "Portname:"
        '
        'registerReadPortname
        '
        Me.registerReadPortname.Location = New System.Drawing.Point(9, 19)
        Me.registerReadPortname.Name = "registerReadPortname"
        Me.registerReadPortname.Size = New System.Drawing.Size(102, 20)
        Me.registerReadPortname.TabIndex = 1
        '
        'registerReadRegId
        '
        Me.registerReadRegId.Hexadecimal = True
        Me.registerReadRegId.Location = New System.Drawing.Point(170, 19)
        Me.registerReadRegId.Maximum = New Decimal(New Integer() {254, 0, 0, 0})
        Me.registerReadRegId.Name = "registerReadRegId"
        Me.registerReadRegId.Size = New System.Drawing.Size(42, 20)
        Me.registerReadRegId.TabIndex = 5
        Me.registerReadRegId.TextAlign = System.Windows.Forms.HorizontalAlignment.Right
        Me.registerReadRegId.Value = New Decimal(New Integer() {1, 0, 0, 0})
        '
        'label30
        '
        Me.label30.AutoSize = True
        Me.label30.Location = New System.Drawing.Point(167, 3)
        Me.label30.Name = "label30"
        Me.label30.Size = New System.Drawing.Size(45, 13)
        Me.label30.TabIndex = 4
        Me.label30.Text = "Reg. Id:"
        '
        'registerReadAscii
        '
        Me.registerReadAscii.Location = New System.Drawing.Point(6, 345)
        Me.registerReadAscii.Name = "registerReadAscii"
        Me.registerReadAscii.Size = New System.Drawing.Size(122, 23)
        Me.registerReadAscii.TabIndex = 18
        Me.registerReadAscii.Text = "registerReadAscii"
        Me.registerReadAscii.UseVisualStyleBackColor = True
        '
        'registerReadF64
        '
        Me.registerReadF64.Location = New System.Drawing.Point(6, 316)
        Me.registerReadF64.Name = "registerReadF64"
        Me.registerReadF64.Size = New System.Drawing.Size(122, 23)
        Me.registerReadF64.TabIndex = 17
        Me.registerReadF64.Text = "registerReadF64"
        Me.registerReadF64.UseVisualStyleBackColor = True
        '
        'registerReadF32
        '
        Me.registerReadF32.Location = New System.Drawing.Point(6, 287)
        Me.registerReadF32.Name = "registerReadF32"
        Me.registerReadF32.Size = New System.Drawing.Size(122, 23)
        Me.registerReadF32.TabIndex = 16
        Me.registerReadF32.Text = "registerReadF32"
        Me.registerReadF32.UseVisualStyleBackColor = True
        '
        'registerReadS64
        '
        Me.registerReadS64.Location = New System.Drawing.Point(6, 258)
        Me.registerReadS64.Name = "registerReadS64"
        Me.registerReadS64.Size = New System.Drawing.Size(122, 23)
        Me.registerReadS64.TabIndex = 15
        Me.registerReadS64.Text = "registerReadS64"
        Me.registerReadS64.UseVisualStyleBackColor = True
        '
        'registerReadU8
        '
        Me.registerReadU8.Location = New System.Drawing.Point(6, 55)
        Me.registerReadU8.Name = "registerReadU8"
        Me.registerReadU8.Size = New System.Drawing.Size(122, 23)
        Me.registerReadU8.TabIndex = 8
        Me.registerReadU8.Text = "registerReadU8"
        Me.registerReadU8.UseVisualStyleBackColor = True
        '
        'registerReadU64
        '
        Me.registerReadU64.Location = New System.Drawing.Point(6, 229)
        Me.registerReadU64.Name = "registerReadU64"
        Me.registerReadU64.Size = New System.Drawing.Size(122, 23)
        Me.registerReadU64.TabIndex = 14
        Me.registerReadU64.Text = "registerReadU64"
        Me.registerReadU64.UseVisualStyleBackColor = True
        '
        'registerReadS8
        '
        Me.registerReadS8.Location = New System.Drawing.Point(6, 84)
        Me.registerReadS8.Name = "registerReadS8"
        Me.registerReadS8.Size = New System.Drawing.Size(122, 23)
        Me.registerReadS8.TabIndex = 9
        Me.registerReadS8.Text = "registerReadS8"
        Me.registerReadS8.UseVisualStyleBackColor = True
        '
        'registerReadS32
        '
        Me.registerReadS32.Location = New System.Drawing.Point(6, 200)
        Me.registerReadS32.Name = "registerReadS32"
        Me.registerReadS32.Size = New System.Drawing.Size(122, 23)
        Me.registerReadS32.TabIndex = 13
        Me.registerReadS32.Text = "registerReadS32"
        Me.registerReadS32.UseVisualStyleBackColor = True
        '
        'registerReadU16
        '
        Me.registerReadU16.Location = New System.Drawing.Point(6, 113)
        Me.registerReadU16.Name = "registerReadU16"
        Me.registerReadU16.Size = New System.Drawing.Size(122, 23)
        Me.registerReadU16.TabIndex = 10
        Me.registerReadU16.Text = "registerReadU16"
        Me.registerReadU16.UseVisualStyleBackColor = True
        '
        'registerReadU32
        '
        Me.registerReadU32.Location = New System.Drawing.Point(6, 171)
        Me.registerReadU32.Name = "registerReadU32"
        Me.registerReadU32.Size = New System.Drawing.Size(122, 23)
        Me.registerReadU32.TabIndex = 12
        Me.registerReadU32.Text = "registerReadU32"
        Me.registerReadU32.UseVisualStyleBackColor = True
        '
        'registerReadS16
        '
        Me.registerReadS16.Location = New System.Drawing.Point(6, 142)
        Me.registerReadS16.Name = "registerReadS16"
        Me.registerReadS16.Size = New System.Drawing.Size(122, 23)
        Me.registerReadS16.TabIndex = 11
        Me.registerReadS16.Text = "registerReadS16"
        Me.registerReadS16.UseVisualStyleBackColor = True
        '
        'tabPage2
        '
        Me.tabPage2.Controls.Add(Me.registerWriteAsciiEOL)
        Me.tabPage2.Controls.Add(Me.registerWriteIndex)
        Me.tabPage2.Controls.Add(Me.label20)
        Me.tabPage2.Controls.Add(Me.registerWriteDevId)
        Me.tabPage2.Controls.Add(Me.label25)
        Me.tabPage2.Controls.Add(Me.label28)
        Me.tabPage2.Controls.Add(Me.registerWritePortname)
        Me.tabPage2.Controls.Add(Me.registerWriteRegId)
        Me.tabPage2.Controls.Add(Me.label29)
        Me.tabPage2.Controls.Add(Me.label9)
        Me.tabPage2.Controls.Add(Me.registerWriteAsciiValue)
        Me.tabPage2.Controls.Add(Me.registerWriteF64Value)
        Me.tabPage2.Controls.Add(Me.registerWriteF32Value)
        Me.tabPage2.Controls.Add(Me.registerWriteS64Value)
        Me.tabPage2.Controls.Add(Me.registerWriteU64Value)
        Me.tabPage2.Controls.Add(Me.registerWriteS32Value)
        Me.tabPage2.Controls.Add(Me.registerWriteU32Value)
        Me.tabPage2.Controls.Add(Me.registerWriteS16Value)
        Me.tabPage2.Controls.Add(Me.registerWriteU16Value)
        Me.tabPage2.Controls.Add(Me.registerWriteS8Value)
        Me.tabPage2.Controls.Add(Me.registerWriteU8Value)
        Me.tabPage2.Controls.Add(Me.registerWriteAscii)
        Me.tabPage2.Controls.Add(Me.registerWriteF64)
        Me.tabPage2.Controls.Add(Me.registerWriteF32)
        Me.tabPage2.Controls.Add(Me.registerWriteS64)
        Me.tabPage2.Controls.Add(Me.registerWriteU8)
        Me.tabPage2.Controls.Add(Me.registerWriteU64)
        Me.tabPage2.Controls.Add(Me.registerWriteS8)
        Me.tabPage2.Controls.Add(Me.registerWriteS32)
        Me.tabPage2.Controls.Add(Me.registerWriteU16)
        Me.tabPage2.Controls.Add(Me.registerWriteU32)
        Me.tabPage2.Controls.Add(Me.registerWriteS16)
        Me.tabPage2.Location = New System.Drawing.Point(4, 22)
        Me.tabPage2.Name = "tabPage2"
        Me.tabPage2.Padding = New System.Windows.Forms.Padding(3)
        Me.tabPage2.Size = New System.Drawing.Size(772, 374)
        Me.tabPage2.TabIndex = 1
        Me.tabPage2.Text = "registerWrite Functions"
        Me.tabPage2.UseVisualStyleBackColor = True
        '
        'registerWriteAsciiEOL
        '
        Me.registerWriteAsciiEOL.AutoSize = True
        Me.registerWriteAsciiEOL.Location = New System.Drawing.Point(376, 350)
        Me.registerWriteAsciiEOL.Name = "registerWriteAsciiEOL"
        Me.registerWriteAsciiEOL.Size = New System.Drawing.Size(67, 17)
        Me.registerWriteAsciiEOL.TabIndex = 26
        Me.registerWriteAsciiEOL.Text = "Wr. EOL"
        Me.registerWriteAsciiEOL.UseVisualStyleBackColor = True
        '
        'registerWriteIndex
        '
        Me.registerWriteIndex.Location = New System.Drawing.Point(221, 19)
        Me.registerWriteIndex.Maximum = New Decimal(New Integer() {255, 0, 0, 0})
        Me.registerWriteIndex.Minimum = New Decimal(New Integer() {1, 0, 0, -2147483648})
        Me.registerWriteIndex.Name = "registerWriteIndex"
        Me.registerWriteIndex.Size = New System.Drawing.Size(42, 20)
        Me.registerWriteIndex.TabIndex = 3
        Me.registerWriteIndex.TextAlign = System.Windows.Forms.HorizontalAlignment.Right
        Me.registerWriteIndex.Value = New Decimal(New Integer() {1, 0, 0, -2147483648})
        '
        'label20
        '
        Me.label20.AutoSize = True
        Me.label20.Location = New System.Drawing.Point(218, 3)
        Me.label20.Name = "label20"
        Me.label20.Size = New System.Drawing.Size(36, 13)
        Me.label20.TabIndex = 135
        Me.label20.Text = "Index:"
        '
        'registerWriteDevId
        '
        Me.registerWriteDevId.Location = New System.Drawing.Point(119, 19)
        Me.registerWriteDevId.Maximum = New Decimal(New Integer() {255, 0, 0, 0})
        Me.registerWriteDevId.Minimum = New Decimal(New Integer() {1, 0, 0, 0})
        Me.registerWriteDevId.Name = "registerWriteDevId"
        Me.registerWriteDevId.Size = New System.Drawing.Size(42, 20)
        Me.registerWriteDevId.TabIndex = 1
        Me.registerWriteDevId.TextAlign = System.Windows.Forms.HorizontalAlignment.Right
        Me.registerWriteDevId.Value = New Decimal(New Integer() {1, 0, 0, 0})
        '
        'label25
        '
        Me.label25.AutoSize = True
        Me.label25.Location = New System.Drawing.Point(116, 3)
        Me.label25.Name = "label25"
        Me.label25.Size = New System.Drawing.Size(45, 13)
        Me.label25.TabIndex = 133
        Me.label25.Text = "Dev. Id:"
        '
        'label28
        '
        Me.label28.AutoSize = True
        Me.label28.Location = New System.Drawing.Point(6, 3)
        Me.label28.Name = "label28"
        Me.label28.Size = New System.Drawing.Size(55, 13)
        Me.label28.TabIndex = 132
        Me.label28.Text = "Portname:"
        '
        'registerWritePortname
        '
        Me.registerWritePortname.Location = New System.Drawing.Point(9, 19)
        Me.registerWritePortname.Name = "registerWritePortname"
        Me.registerWritePortname.Size = New System.Drawing.Size(102, 20)
        Me.registerWritePortname.TabIndex = 0
        '
        'registerWriteRegId
        '
        Me.registerWriteRegId.Hexadecimal = True
        Me.registerWriteRegId.Location = New System.Drawing.Point(170, 19)
        Me.registerWriteRegId.Maximum = New Decimal(New Integer() {254, 0, 0, 0})
        Me.registerWriteRegId.Name = "registerWriteRegId"
        Me.registerWriteRegId.Size = New System.Drawing.Size(42, 20)
        Me.registerWriteRegId.TabIndex = 2
        Me.registerWriteRegId.TextAlign = System.Windows.Forms.HorizontalAlignment.Right
        Me.registerWriteRegId.Value = New Decimal(New Integer() {1, 0, 0, 0})
        '
        'label29
        '
        Me.label29.AutoSize = True
        Me.label29.Location = New System.Drawing.Point(167, 3)
        Me.label29.Name = "label29"
        Me.label29.Size = New System.Drawing.Size(45, 13)
        Me.label29.TabIndex = 129
        Me.label29.Text = "Reg. Id:"
        '
        'label9
        '
        Me.label9.AutoSize = True
        Me.label9.Location = New System.Drawing.Point(135, 42)
        Me.label9.Name = "label9"
        Me.label9.Size = New System.Drawing.Size(64, 13)
        Me.label9.TabIndex = 75
        Me.label9.Text = "Write value:"
        '
        'registerWriteAsciiValue
        '
        Me.registerWriteAsciiValue.Location = New System.Drawing.Point(135, 348)
        Me.registerWriteAsciiValue.Name = "registerWriteAsciiValue"
        Me.registerWriteAsciiValue.Size = New System.Drawing.Size(235, 20)
        Me.registerWriteAsciiValue.TabIndex = 25
        '
        'registerWriteF64Value
        '
        Me.registerWriteF64Value.Location = New System.Drawing.Point(135, 318)
        Me.registerWriteF64Value.Name = "registerWriteF64Value"
        Me.registerWriteF64Value.Size = New System.Drawing.Size(143, 20)
        Me.registerWriteF64Value.TabIndex = 23
        '
        'registerWriteF32Value
        '
        Me.registerWriteF32Value.Location = New System.Drawing.Point(135, 289)
        Me.registerWriteF32Value.Name = "registerWriteF32Value"
        Me.registerWriteF32Value.Size = New System.Drawing.Size(143, 20)
        Me.registerWriteF32Value.TabIndex = 21
        '
        'registerWriteS64Value
        '
        Me.registerWriteS64Value.Location = New System.Drawing.Point(135, 260)
        Me.registerWriteS64Value.Name = "registerWriteS64Value"
        Me.registerWriteS64Value.Size = New System.Drawing.Size(143, 20)
        Me.registerWriteS64Value.TabIndex = 19
        '
        'registerWriteU64Value
        '
        Me.registerWriteU64Value.Location = New System.Drawing.Point(135, 231)
        Me.registerWriteU64Value.Name = "registerWriteU64Value"
        Me.registerWriteU64Value.Size = New System.Drawing.Size(143, 20)
        Me.registerWriteU64Value.TabIndex = 17
        '
        'registerWriteS32Value
        '
        Me.registerWriteS32Value.Location = New System.Drawing.Point(135, 202)
        Me.registerWriteS32Value.Name = "registerWriteS32Value"
        Me.registerWriteS32Value.Size = New System.Drawing.Size(107, 20)
        Me.registerWriteS32Value.TabIndex = 15
        '
        'registerWriteU32Value
        '
        Me.registerWriteU32Value.Location = New System.Drawing.Point(135, 173)
        Me.registerWriteU32Value.Name = "registerWriteU32Value"
        Me.registerWriteU32Value.Size = New System.Drawing.Size(107, 20)
        Me.registerWriteU32Value.TabIndex = 13
        '
        'registerWriteS16Value
        '
        Me.registerWriteS16Value.Location = New System.Drawing.Point(135, 144)
        Me.registerWriteS16Value.Name = "registerWriteS16Value"
        Me.registerWriteS16Value.Size = New System.Drawing.Size(77, 20)
        Me.registerWriteS16Value.TabIndex = 11
        '
        'registerWriteU16Value
        '
        Me.registerWriteU16Value.Location = New System.Drawing.Point(135, 115)
        Me.registerWriteU16Value.Name = "registerWriteU16Value"
        Me.registerWriteU16Value.Size = New System.Drawing.Size(77, 20)
        Me.registerWriteU16Value.TabIndex = 9
        '
        'registerWriteS8Value
        '
        Me.registerWriteS8Value.Location = New System.Drawing.Point(135, 86)
        Me.registerWriteS8Value.Name = "registerWriteS8Value"
        Me.registerWriteS8Value.Size = New System.Drawing.Size(54, 20)
        Me.registerWriteS8Value.TabIndex = 7
        '
        'registerWriteU8Value
        '
        Me.registerWriteU8Value.Location = New System.Drawing.Point(135, 57)
        Me.registerWriteU8Value.Name = "registerWriteU8Value"
        Me.registerWriteU8Value.Size = New System.Drawing.Size(54, 20)
        Me.registerWriteU8Value.TabIndex = 5
        '
        'registerWriteAscii
        '
        Me.registerWriteAscii.Location = New System.Drawing.Point(6, 345)
        Me.registerWriteAscii.Name = "registerWriteAscii"
        Me.registerWriteAscii.Size = New System.Drawing.Size(122, 23)
        Me.registerWriteAscii.TabIndex = 24
        Me.registerWriteAscii.Text = "registerWriteAscii"
        Me.registerWriteAscii.UseVisualStyleBackColor = True
        '
        'registerWriteF64
        '
        Me.registerWriteF64.Location = New System.Drawing.Point(6, 316)
        Me.registerWriteF64.Name = "registerWriteF64"
        Me.registerWriteF64.Size = New System.Drawing.Size(122, 23)
        Me.registerWriteF64.TabIndex = 22
        Me.registerWriteF64.Text = "registerWriteF64"
        Me.registerWriteF64.UseVisualStyleBackColor = True
        '
        'registerWriteF32
        '
        Me.registerWriteF32.Location = New System.Drawing.Point(6, 287)
        Me.registerWriteF32.Name = "registerWriteF32"
        Me.registerWriteF32.Size = New System.Drawing.Size(122, 23)
        Me.registerWriteF32.TabIndex = 20
        Me.registerWriteF32.Text = "registerWriteF32"
        Me.registerWriteF32.UseVisualStyleBackColor = True
        '
        'registerWriteS64
        '
        Me.registerWriteS64.Location = New System.Drawing.Point(6, 258)
        Me.registerWriteS64.Name = "registerWriteS64"
        Me.registerWriteS64.Size = New System.Drawing.Size(122, 23)
        Me.registerWriteS64.TabIndex = 18
        Me.registerWriteS64.Text = "registerWriteS64"
        Me.registerWriteS64.UseVisualStyleBackColor = True
        '
        'registerWriteU8
        '
        Me.registerWriteU8.Location = New System.Drawing.Point(6, 55)
        Me.registerWriteU8.Name = "registerWriteU8"
        Me.registerWriteU8.Size = New System.Drawing.Size(122, 23)
        Me.registerWriteU8.TabIndex = 4
        Me.registerWriteU8.Text = "registerWriteU8"
        Me.registerWriteU8.UseVisualStyleBackColor = True
        '
        'registerWriteU64
        '
        Me.registerWriteU64.Location = New System.Drawing.Point(6, 229)
        Me.registerWriteU64.Name = "registerWriteU64"
        Me.registerWriteU64.Size = New System.Drawing.Size(122, 23)
        Me.registerWriteU64.TabIndex = 16
        Me.registerWriteU64.Text = "registerWriteU64"
        Me.registerWriteU64.UseVisualStyleBackColor = True
        '
        'registerWriteS8
        '
        Me.registerWriteS8.Location = New System.Drawing.Point(6, 84)
        Me.registerWriteS8.Name = "registerWriteS8"
        Me.registerWriteS8.Size = New System.Drawing.Size(122, 23)
        Me.registerWriteS8.TabIndex = 6
        Me.registerWriteS8.Text = "registerWriteS8"
        Me.registerWriteS8.UseVisualStyleBackColor = True
        '
        'registerWriteS32
        '
        Me.registerWriteS32.Location = New System.Drawing.Point(6, 200)
        Me.registerWriteS32.Name = "registerWriteS32"
        Me.registerWriteS32.Size = New System.Drawing.Size(122, 23)
        Me.registerWriteS32.TabIndex = 14
        Me.registerWriteS32.Text = "registerWriteS32"
        Me.registerWriteS32.UseVisualStyleBackColor = True
        '
        'registerWriteU16
        '
        Me.registerWriteU16.Location = New System.Drawing.Point(6, 113)
        Me.registerWriteU16.Name = "registerWriteU16"
        Me.registerWriteU16.Size = New System.Drawing.Size(122, 23)
        Me.registerWriteU16.TabIndex = 8
        Me.registerWriteU16.Text = "registerWriteU16"
        Me.registerWriteU16.UseVisualStyleBackColor = True
        '
        'registerWriteU32
        '
        Me.registerWriteU32.Location = New System.Drawing.Point(6, 171)
        Me.registerWriteU32.Name = "registerWriteU32"
        Me.registerWriteU32.Size = New System.Drawing.Size(122, 23)
        Me.registerWriteU32.TabIndex = 12
        Me.registerWriteU32.Text = "registerWriteU32"
        Me.registerWriteU32.UseVisualStyleBackColor = True
        '
        'registerWriteS16
        '
        Me.registerWriteS16.Location = New System.Drawing.Point(6, 142)
        Me.registerWriteS16.Name = "registerWriteS16"
        Me.registerWriteS16.Size = New System.Drawing.Size(122, 23)
        Me.registerWriteS16.TabIndex = 10
        Me.registerWriteS16.Text = "registerWriteS16"
        Me.registerWriteS16.UseVisualStyleBackColor = True
        '
        'tabPage3
        '
        Me.tabPage3.Controls.Add(Me.registerWriteReadAsciiEOL)
        Me.tabPage3.Controls.Add(Me.registerWriteReadAscii)
        Me.tabPage3.Controls.Add(Me.registerWriteReadIndex)
        Me.tabPage3.Controls.Add(Me.label17)
        Me.tabPage3.Controls.Add(Me.registerWriteReadDevId)
        Me.tabPage3.Controls.Add(Me.label24)
        Me.tabPage3.Controls.Add(Me.label26)
        Me.tabPage3.Controls.Add(Me.registerWriteReadPortname)
        Me.tabPage3.Controls.Add(Me.registerWriteReadRegId)
        Me.tabPage3.Controls.Add(Me.label27)
        Me.tabPage3.Controls.Add(Me.label18)
        Me.tabPage3.Controls.Add(Me.registerWriteReadAsciiWrValue)
        Me.tabPage3.Controls.Add(Me.registerWriteReadF64WrValue)
        Me.tabPage3.Controls.Add(Me.registerWriteReadF32WrValue)
        Me.tabPage3.Controls.Add(Me.registerWriteReadS64WrValue)
        Me.tabPage3.Controls.Add(Me.registerWriteReadU64WrValue)
        Me.tabPage3.Controls.Add(Me.registerWriteReadS32WrValue)
        Me.tabPage3.Controls.Add(Me.registerWriteReadU32WrValue)
        Me.tabPage3.Controls.Add(Me.registerWriteReadS16WrValue)
        Me.tabPage3.Controls.Add(Me.registerWriteReadU16WrValue)
        Me.tabPage3.Controls.Add(Me.registerWriteReadS8WrValue)
        Me.tabPage3.Controls.Add(Me.registerWriteReadU8WrValue)
        Me.tabPage3.Controls.Add(Me.registerWriteReadF64)
        Me.tabPage3.Controls.Add(Me.registerWriteReadF32)
        Me.tabPage3.Controls.Add(Me.registerWriteReadS64)
        Me.tabPage3.Controls.Add(Me.registerWriteReadU64)
        Me.tabPage3.Controls.Add(Me.registerWriteReadS32)
        Me.tabPage3.Controls.Add(Me.registerWriteReadU32)
        Me.tabPage3.Controls.Add(Me.registerWriteReadS16)
        Me.tabPage3.Controls.Add(Me.registerWriteReadU16)
        Me.tabPage3.Controls.Add(Me.registerWriteReadS8)
        Me.tabPage3.Controls.Add(Me.registerWriteReadU8)
        Me.tabPage3.Location = New System.Drawing.Point(4, 22)
        Me.tabPage3.Name = "tabPage3"
        Me.tabPage3.Size = New System.Drawing.Size(772, 374)
        Me.tabPage3.TabIndex = 2
        Me.tabPage3.Text = "registerWriteRead Functions"
        Me.tabPage3.UseVisualStyleBackColor = True
        '
        'registerWriteReadAsciiEOL
        '
        Me.registerWriteReadAsciiEOL.AutoSize = True
        Me.registerWriteReadAsciiEOL.Location = New System.Drawing.Point(390, 350)
        Me.registerWriteReadAsciiEOL.Name = "registerWriteReadAsciiEOL"
        Me.registerWriteReadAsciiEOL.Size = New System.Drawing.Size(67, 17)
        Me.registerWriteReadAsciiEOL.TabIndex = 26
        Me.registerWriteReadAsciiEOL.Text = "Wr. EOL"
        Me.registerWriteReadAsciiEOL.UseVisualStyleBackColor = True
        '
        'registerWriteReadAscii
        '
        Me.registerWriteReadAscii.Location = New System.Drawing.Point(6, 346)
        Me.registerWriteReadAscii.Name = "registerWriteReadAscii"
        Me.registerWriteReadAscii.Size = New System.Drawing.Size(137, 23)
        Me.registerWriteReadAscii.TabIndex = 24
        Me.registerWriteReadAscii.Text = "registerWriteReadAscii"
        Me.registerWriteReadAscii.UseVisualStyleBackColor = True
        '
        'registerWriteReadIndex
        '
        Me.registerWriteReadIndex.Location = New System.Drawing.Point(221, 19)
        Me.registerWriteReadIndex.Maximum = New Decimal(New Integer() {255, 0, 0, 0})
        Me.registerWriteReadIndex.Minimum = New Decimal(New Integer() {1, 0, 0, -2147483648})
        Me.registerWriteReadIndex.Name = "registerWriteReadIndex"
        Me.registerWriteReadIndex.Size = New System.Drawing.Size(42, 20)
        Me.registerWriteReadIndex.TabIndex = 3
        Me.registerWriteReadIndex.TextAlign = System.Windows.Forms.HorizontalAlignment.Right
        Me.registerWriteReadIndex.Value = New Decimal(New Integer() {1, 0, 0, -2147483648})
        '
        'label17
        '
        Me.label17.AutoSize = True
        Me.label17.Location = New System.Drawing.Point(218, 3)
        Me.label17.Name = "label17"
        Me.label17.Size = New System.Drawing.Size(36, 13)
        Me.label17.TabIndex = 143
        Me.label17.Text = "Index:"
        '
        'registerWriteReadDevId
        '
        Me.registerWriteReadDevId.Location = New System.Drawing.Point(119, 19)
        Me.registerWriteReadDevId.Maximum = New Decimal(New Integer() {255, 0, 0, 0})
        Me.registerWriteReadDevId.Minimum = New Decimal(New Integer() {1, 0, 0, 0})
        Me.registerWriteReadDevId.Name = "registerWriteReadDevId"
        Me.registerWriteReadDevId.Size = New System.Drawing.Size(42, 20)
        Me.registerWriteReadDevId.TabIndex = 1
        Me.registerWriteReadDevId.TextAlign = System.Windows.Forms.HorizontalAlignment.Right
        Me.registerWriteReadDevId.Value = New Decimal(New Integer() {1, 0, 0, 0})
        '
        'label24
        '
        Me.label24.AutoSize = True
        Me.label24.Location = New System.Drawing.Point(116, 3)
        Me.label24.Name = "label24"
        Me.label24.Size = New System.Drawing.Size(45, 13)
        Me.label24.TabIndex = 141
        Me.label24.Text = "Dev. Id:"
        '
        'label26
        '
        Me.label26.AutoSize = True
        Me.label26.Location = New System.Drawing.Point(6, 3)
        Me.label26.Name = "label26"
        Me.label26.Size = New System.Drawing.Size(55, 13)
        Me.label26.TabIndex = 140
        Me.label26.Text = "Portname:"
        '
        'registerWriteReadPortname
        '
        Me.registerWriteReadPortname.Location = New System.Drawing.Point(3, 19)
        Me.registerWriteReadPortname.Name = "registerWriteReadPortname"
        Me.registerWriteReadPortname.Size = New System.Drawing.Size(102, 20)
        Me.registerWriteReadPortname.TabIndex = 0
        '
        'registerWriteReadRegId
        '
        Me.registerWriteReadRegId.Hexadecimal = True
        Me.registerWriteReadRegId.Location = New System.Drawing.Point(170, 19)
        Me.registerWriteReadRegId.Maximum = New Decimal(New Integer() {254, 0, 0, 0})
        Me.registerWriteReadRegId.Minimum = New Decimal(New Integer() {1, 0, 0, 0})
        Me.registerWriteReadRegId.Name = "registerWriteReadRegId"
        Me.registerWriteReadRegId.Size = New System.Drawing.Size(42, 20)
        Me.registerWriteReadRegId.TabIndex = 2
        Me.registerWriteReadRegId.TextAlign = System.Windows.Forms.HorizontalAlignment.Right
        Me.registerWriteReadRegId.Value = New Decimal(New Integer() {1, 0, 0, 0})
        '
        'label27
        '
        Me.label27.AutoSize = True
        Me.label27.Location = New System.Drawing.Point(167, 3)
        Me.label27.Name = "label27"
        Me.label27.Size = New System.Drawing.Size(45, 13)
        Me.label27.TabIndex = 137
        Me.label27.Text = "Reg. Id:"
        '
        'label18
        '
        Me.label18.AutoSize = True
        Me.label18.Location = New System.Drawing.Point(149, 42)
        Me.label18.Name = "label18"
        Me.label18.Size = New System.Drawing.Size(64, 13)
        Me.label18.TabIndex = 88
        Me.label18.Text = "Write value:"
        '
        'registerWriteReadAsciiWrValue
        '
        Me.registerWriteReadAsciiWrValue.Location = New System.Drawing.Point(149, 348)
        Me.registerWriteReadAsciiWrValue.Name = "registerWriteReadAsciiWrValue"
        Me.registerWriteReadAsciiWrValue.Size = New System.Drawing.Size(235, 20)
        Me.registerWriteReadAsciiWrValue.TabIndex = 25
        '
        'registerWriteReadF64WrValue
        '
        Me.registerWriteReadF64WrValue.Location = New System.Drawing.Point(149, 319)
        Me.registerWriteReadF64WrValue.Name = "registerWriteReadF64WrValue"
        Me.registerWriteReadF64WrValue.Size = New System.Drawing.Size(143, 20)
        Me.registerWriteReadF64WrValue.TabIndex = 23
        '
        'registerWriteReadF32WrValue
        '
        Me.registerWriteReadF32WrValue.Location = New System.Drawing.Point(149, 290)
        Me.registerWriteReadF32WrValue.Name = "registerWriteReadF32WrValue"
        Me.registerWriteReadF32WrValue.Size = New System.Drawing.Size(143, 20)
        Me.registerWriteReadF32WrValue.TabIndex = 21
        '
        'registerWriteReadS64WrValue
        '
        Me.registerWriteReadS64WrValue.Location = New System.Drawing.Point(149, 261)
        Me.registerWriteReadS64WrValue.Name = "registerWriteReadS64WrValue"
        Me.registerWriteReadS64WrValue.Size = New System.Drawing.Size(143, 20)
        Me.registerWriteReadS64WrValue.TabIndex = 19
        '
        'registerWriteReadU64WrValue
        '
        Me.registerWriteReadU64WrValue.Location = New System.Drawing.Point(149, 232)
        Me.registerWriteReadU64WrValue.Name = "registerWriteReadU64WrValue"
        Me.registerWriteReadU64WrValue.Size = New System.Drawing.Size(143, 20)
        Me.registerWriteReadU64WrValue.TabIndex = 17
        '
        'registerWriteReadS32WrValue
        '
        Me.registerWriteReadS32WrValue.Location = New System.Drawing.Point(149, 203)
        Me.registerWriteReadS32WrValue.Name = "registerWriteReadS32WrValue"
        Me.registerWriteReadS32WrValue.Size = New System.Drawing.Size(107, 20)
        Me.registerWriteReadS32WrValue.TabIndex = 15
        '
        'registerWriteReadU32WrValue
        '
        Me.registerWriteReadU32WrValue.Location = New System.Drawing.Point(149, 174)
        Me.registerWriteReadU32WrValue.Name = "registerWriteReadU32WrValue"
        Me.registerWriteReadU32WrValue.Size = New System.Drawing.Size(107, 20)
        Me.registerWriteReadU32WrValue.TabIndex = 13
        '
        'registerWriteReadS16WrValue
        '
        Me.registerWriteReadS16WrValue.Location = New System.Drawing.Point(149, 145)
        Me.registerWriteReadS16WrValue.Name = "registerWriteReadS16WrValue"
        Me.registerWriteReadS16WrValue.Size = New System.Drawing.Size(77, 20)
        Me.registerWriteReadS16WrValue.TabIndex = 11
        '
        'registerWriteReadU16WrValue
        '
        Me.registerWriteReadU16WrValue.Location = New System.Drawing.Point(149, 116)
        Me.registerWriteReadU16WrValue.Name = "registerWriteReadU16WrValue"
        Me.registerWriteReadU16WrValue.Size = New System.Drawing.Size(77, 20)
        Me.registerWriteReadU16WrValue.TabIndex = 9
        '
        'registerWriteReadS8WrValue
        '
        Me.registerWriteReadS8WrValue.Location = New System.Drawing.Point(149, 87)
        Me.registerWriteReadS8WrValue.Name = "registerWriteReadS8WrValue"
        Me.registerWriteReadS8WrValue.Size = New System.Drawing.Size(54, 20)
        Me.registerWriteReadS8WrValue.TabIndex = 7
        '
        'registerWriteReadU8WrValue
        '
        Me.registerWriteReadU8WrValue.Location = New System.Drawing.Point(149, 57)
        Me.registerWriteReadU8WrValue.Name = "registerWriteReadU8WrValue"
        Me.registerWriteReadU8WrValue.Size = New System.Drawing.Size(54, 20)
        Me.registerWriteReadU8WrValue.TabIndex = 5
        '
        'registerWriteReadF64
        '
        Me.registerWriteReadF64.Location = New System.Drawing.Point(6, 317)
        Me.registerWriteReadF64.Name = "registerWriteReadF64"
        Me.registerWriteReadF64.Size = New System.Drawing.Size(137, 23)
        Me.registerWriteReadF64.TabIndex = 22
        Me.registerWriteReadF64.Text = "registerWriteReadF64"
        Me.registerWriteReadF64.UseVisualStyleBackColor = True
        '
        'registerWriteReadF32
        '
        Me.registerWriteReadF32.Location = New System.Drawing.Point(6, 288)
        Me.registerWriteReadF32.Name = "registerWriteReadF32"
        Me.registerWriteReadF32.Size = New System.Drawing.Size(137, 23)
        Me.registerWriteReadF32.TabIndex = 20
        Me.registerWriteReadF32.Text = "registerWriteReadF32"
        Me.registerWriteReadF32.UseVisualStyleBackColor = True
        '
        'registerWriteReadS64
        '
        Me.registerWriteReadS64.Location = New System.Drawing.Point(6, 259)
        Me.registerWriteReadS64.Name = "registerWriteReadS64"
        Me.registerWriteReadS64.Size = New System.Drawing.Size(137, 23)
        Me.registerWriteReadS64.TabIndex = 18
        Me.registerWriteReadS64.Text = "registerWriteReadS64"
        Me.registerWriteReadS64.UseVisualStyleBackColor = True
        '
        'registerWriteReadU64
        '
        Me.registerWriteReadU64.Location = New System.Drawing.Point(6, 230)
        Me.registerWriteReadU64.Name = "registerWriteReadU64"
        Me.registerWriteReadU64.Size = New System.Drawing.Size(137, 23)
        Me.registerWriteReadU64.TabIndex = 16
        Me.registerWriteReadU64.Text = "registerWriteReadU64"
        Me.registerWriteReadU64.UseVisualStyleBackColor = True
        '
        'registerWriteReadS32
        '
        Me.registerWriteReadS32.Location = New System.Drawing.Point(6, 201)
        Me.registerWriteReadS32.Name = "registerWriteReadS32"
        Me.registerWriteReadS32.Size = New System.Drawing.Size(137, 23)
        Me.registerWriteReadS32.TabIndex = 14
        Me.registerWriteReadS32.Text = "registerWriteReadS32"
        Me.registerWriteReadS32.UseVisualStyleBackColor = True
        '
        'registerWriteReadU32
        '
        Me.registerWriteReadU32.Location = New System.Drawing.Point(6, 172)
        Me.registerWriteReadU32.Name = "registerWriteReadU32"
        Me.registerWriteReadU32.Size = New System.Drawing.Size(137, 23)
        Me.registerWriteReadU32.TabIndex = 12
        Me.registerWriteReadU32.Text = "registerWriteReadU32"
        Me.registerWriteReadU32.UseVisualStyleBackColor = True
        '
        'registerWriteReadS16
        '
        Me.registerWriteReadS16.Location = New System.Drawing.Point(6, 143)
        Me.registerWriteReadS16.Name = "registerWriteReadS16"
        Me.registerWriteReadS16.Size = New System.Drawing.Size(137, 23)
        Me.registerWriteReadS16.TabIndex = 10
        Me.registerWriteReadS16.Text = "registerWriteReadS16"
        Me.registerWriteReadS16.UseVisualStyleBackColor = True
        '
        'registerWriteReadU16
        '
        Me.registerWriteReadU16.Location = New System.Drawing.Point(6, 114)
        Me.registerWriteReadU16.Name = "registerWriteReadU16"
        Me.registerWriteReadU16.Size = New System.Drawing.Size(137, 23)
        Me.registerWriteReadU16.TabIndex = 8
        Me.registerWriteReadU16.Text = "registerWriteReadU16"
        Me.registerWriteReadU16.UseVisualStyleBackColor = True
        '
        'registerWriteReadS8
        '
        Me.registerWriteReadS8.Location = New System.Drawing.Point(6, 85)
        Me.registerWriteReadS8.Name = "registerWriteReadS8"
        Me.registerWriteReadS8.Size = New System.Drawing.Size(137, 23)
        Me.registerWriteReadS8.TabIndex = 6
        Me.registerWriteReadS8.Text = "registerWriteReadS8"
        Me.registerWriteReadS8.UseVisualStyleBackColor = True
        '
        'registerWriteReadU8
        '
        Me.registerWriteReadU8.Location = New System.Drawing.Point(6, 55)
        Me.registerWriteReadU8.Name = "registerWriteReadU8"
        Me.registerWriteReadU8.Size = New System.Drawing.Size(137, 23)
        Me.registerWriteReadU8.TabIndex = 4
        Me.registerWriteReadU8.Text = "registerWriteReadU8"
        Me.registerWriteReadU8.UseVisualStyleBackColor = True
        '
        'tabPage4
        '
        Me.tabPage4.Controls.Add(Me.deviceGetPCBSerialNumberStr)
        Me.tabPage4.Controls.Add(Me.deviceGetModuleSerialNumberStr)
        Me.tabPage4.Controls.Add(Me.deviceGetFirmwareVersionStr)
        Me.tabPage4.Controls.Add(Me.deviceGetFirmwareVersion)
        Me.tabPage4.Controls.Add(Me.deviceGetBootloaderVersionStr)
        Me.tabPage4.Controls.Add(Me.deviceGetBootloaderVersion)
        Me.tabPage4.Controls.Add(Me.deviceGetErrorCode)
        Me.tabPage4.Controls.Add(Me.deviceGetStatusBits)
        Me.tabPage4.Controls.Add(Me.deviceGetPCBVersion)
        Me.tabPage4.Controls.Add(Me.deviceGetPartnumberStr)
        Me.tabPage4.Controls.Add(Me.dedicatedDeviceDevId)
        Me.tabPage4.Controls.Add(Me.label31)
        Me.tabPage4.Controls.Add(Me.label32)
        Me.tabPage4.Controls.Add(Me.dedicatedDevicePortname)
        Me.tabPage4.Controls.Add(Me.deviceGetType)
        Me.tabPage4.Location = New System.Drawing.Point(4, 22)
        Me.tabPage4.Name = "tabPage4"
        Me.tabPage4.Size = New System.Drawing.Size(772, 374)
        Me.tabPage4.TabIndex = 4
        Me.tabPage4.Text = "Device Functions"
        Me.tabPage4.UseVisualStyleBackColor = True
        '
        'deviceGetPCBSerialNumberStr
        '
        Me.deviceGetPCBSerialNumberStr.Location = New System.Drawing.Point(6, 345)
        Me.deviceGetPCBSerialNumberStr.Name = "deviceGetPCBSerialNumberStr"
        Me.deviceGetPCBSerialNumberStr.Size = New System.Drawing.Size(184, 23)
        Me.deviceGetPCBSerialNumberStr.TabIndex = 160
        Me.deviceGetPCBSerialNumberStr.Text = "deviceGetPCBSerialNumberStr"
        Me.deviceGetPCBSerialNumberStr.UseVisualStyleBackColor = True
        '
        'deviceGetModuleSerialNumberStr
        '
        Me.deviceGetModuleSerialNumberStr.Location = New System.Drawing.Point(6, 316)
        Me.deviceGetModuleSerialNumberStr.Name = "deviceGetModuleSerialNumberStr"
        Me.deviceGetModuleSerialNumberStr.Size = New System.Drawing.Size(184, 23)
        Me.deviceGetModuleSerialNumberStr.TabIndex = 159
        Me.deviceGetModuleSerialNumberStr.Text = "deviceGetModuleSerialNumberStr"
        Me.deviceGetModuleSerialNumberStr.UseVisualStyleBackColor = True
        '
        'deviceGetFirmwareVersionStr
        '
        Me.deviceGetFirmwareVersionStr.Location = New System.Drawing.Point(6, 287)
        Me.deviceGetFirmwareVersionStr.Name = "deviceGetFirmwareVersionStr"
        Me.deviceGetFirmwareVersionStr.Size = New System.Drawing.Size(184, 23)
        Me.deviceGetFirmwareVersionStr.TabIndex = 158
        Me.deviceGetFirmwareVersionStr.Text = "deviceGetFirmwareVersionStr"
        Me.deviceGetFirmwareVersionStr.UseVisualStyleBackColor = True
        '
        'deviceGetFirmwareVersion
        '
        Me.deviceGetFirmwareVersion.Location = New System.Drawing.Point(6, 258)
        Me.deviceGetFirmwareVersion.Name = "deviceGetFirmwareVersion"
        Me.deviceGetFirmwareVersion.Size = New System.Drawing.Size(184, 23)
        Me.deviceGetFirmwareVersion.TabIndex = 157
        Me.deviceGetFirmwareVersion.Text = "deviceGetFirmwareVersion"
        Me.deviceGetFirmwareVersion.UseVisualStyleBackColor = True
        '
        'deviceGetBootloaderVersionStr
        '
        Me.deviceGetBootloaderVersionStr.Location = New System.Drawing.Point(6, 229)
        Me.deviceGetBootloaderVersionStr.Name = "deviceGetBootloaderVersionStr"
        Me.deviceGetBootloaderVersionStr.Size = New System.Drawing.Size(184, 23)
        Me.deviceGetBootloaderVersionStr.TabIndex = 156
        Me.deviceGetBootloaderVersionStr.Text = "deviceGetBootloaderVersionStr"
        Me.deviceGetBootloaderVersionStr.UseVisualStyleBackColor = True
        '
        'deviceGetBootloaderVersion
        '
        Me.deviceGetBootloaderVersion.Location = New System.Drawing.Point(6, 200)
        Me.deviceGetBootloaderVersion.Name = "deviceGetBootloaderVersion"
        Me.deviceGetBootloaderVersion.Size = New System.Drawing.Size(184, 23)
        Me.deviceGetBootloaderVersion.TabIndex = 155
        Me.deviceGetBootloaderVersion.Text = "deviceGetBootloaderVersion"
        Me.deviceGetBootloaderVersion.UseVisualStyleBackColor = True
        '
        'deviceGetErrorCode
        '
        Me.deviceGetErrorCode.Location = New System.Drawing.Point(6, 171)
        Me.deviceGetErrorCode.Name = "deviceGetErrorCode"
        Me.deviceGetErrorCode.Size = New System.Drawing.Size(184, 23)
        Me.deviceGetErrorCode.TabIndex = 154
        Me.deviceGetErrorCode.Text = "deviceGetErrorCode"
        Me.deviceGetErrorCode.UseVisualStyleBackColor = True
        '
        'deviceGetStatusBits
        '
        Me.deviceGetStatusBits.Location = New System.Drawing.Point(6, 142)
        Me.deviceGetStatusBits.Name = "deviceGetStatusBits"
        Me.deviceGetStatusBits.Size = New System.Drawing.Size(184, 23)
        Me.deviceGetStatusBits.TabIndex = 153
        Me.deviceGetStatusBits.Text = "deviceGetStatusBits"
        Me.deviceGetStatusBits.UseVisualStyleBackColor = True
        '
        'deviceGetPCBVersion
        '
        Me.deviceGetPCBVersion.Location = New System.Drawing.Point(6, 113)
        Me.deviceGetPCBVersion.Name = "deviceGetPCBVersion"
        Me.deviceGetPCBVersion.Size = New System.Drawing.Size(184, 23)
        Me.deviceGetPCBVersion.TabIndex = 152
        Me.deviceGetPCBVersion.Text = "deviceGetPCBVersion"
        Me.deviceGetPCBVersion.UseVisualStyleBackColor = True
        '
        'deviceGetPartnumberStr
        '
        Me.deviceGetPartnumberStr.Location = New System.Drawing.Point(6, 84)
        Me.deviceGetPartnumberStr.Name = "deviceGetPartnumberStr"
        Me.deviceGetPartnumberStr.Size = New System.Drawing.Size(184, 23)
        Me.deviceGetPartnumberStr.TabIndex = 151
        Me.deviceGetPartnumberStr.Text = "deviceGetPartNumberStr"
        Me.deviceGetPartnumberStr.UseVisualStyleBackColor = True
        '
        'dedicatedDeviceDevId
        '
        Me.dedicatedDeviceDevId.Location = New System.Drawing.Point(119, 19)
        Me.dedicatedDeviceDevId.Maximum = New Decimal(New Integer() {255, 0, 0, 0})
        Me.dedicatedDeviceDevId.Minimum = New Decimal(New Integer() {1, 0, 0, 0})
        Me.dedicatedDeviceDevId.Name = "dedicatedDeviceDevId"
        Me.dedicatedDeviceDevId.Size = New System.Drawing.Size(42, 20)
        Me.dedicatedDeviceDevId.TabIndex = 145
        Me.dedicatedDeviceDevId.TextAlign = System.Windows.Forms.HorizontalAlignment.Right
        Me.dedicatedDeviceDevId.Value = New Decimal(New Integer() {1, 0, 0, 0})
        '
        'label31
        '
        Me.label31.AutoSize = True
        Me.label31.Location = New System.Drawing.Point(116, 3)
        Me.label31.Name = "label31"
        Me.label31.Size = New System.Drawing.Size(45, 13)
        Me.label31.TabIndex = 150
        Me.label31.Text = "Dev. Id:"
        '
        'label32
        '
        Me.label32.AutoSize = True
        Me.label32.Location = New System.Drawing.Point(6, 3)
        Me.label32.Name = "label32"
        Me.label32.Size = New System.Drawing.Size(55, 13)
        Me.label32.TabIndex = 149
        Me.label32.Text = "Portname:"
        '
        'dedicatedDevicePortname
        '
        Me.dedicatedDevicePortname.Location = New System.Drawing.Point(3, 19)
        Me.dedicatedDevicePortname.Name = "dedicatedDevicePortname"
        Me.dedicatedDevicePortname.Size = New System.Drawing.Size(102, 20)
        Me.dedicatedDevicePortname.TabIndex = 144
        '
        'deviceGetType
        '
        Me.deviceGetType.Location = New System.Drawing.Point(6, 55)
        Me.deviceGetType.Name = "deviceGetType"
        Me.deviceGetType.Size = New System.Drawing.Size(184, 23)
        Me.deviceGetType.TabIndex = 0
        Me.deviceGetType.Text = "deviceGetType"
        Me.deviceGetType.UseVisualStyleBackColor = True
        '
        'ExitButton
        '
        Me.ExitButton.Location = New System.Drawing.Point(798, 12)
        Me.ExitButton.Name = "ExitButton"
        Me.ExitButton.Size = New System.Drawing.Size(75, 23)
        Me.ExitButton.TabIndex = 21
        Me.ExitButton.Text = "Exit"
        Me.ExitButton.UseVisualStyleBackColor = True
        '
        'StatusTextBox
        '
        Me.StatusTextBox.Location = New System.Drawing.Point(12, 418)
        Me.StatusTextBox.Multiline = True
        Me.StatusTextBox.Name = "StatusTextBox"
        Me.StatusTextBox.ScrollBars = System.Windows.Forms.ScrollBars.Vertical
        Me.StatusTextBox.Size = New System.Drawing.Size(780, 116)
        Me.StatusTextBox.TabIndex = 20
        '
        'Form1
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(881, 543)
        Me.Controls.Add(Me.tabControl1)
        Me.Controls.Add(Me.ExitButton)
        Me.Controls.Add(Me.StatusTextBox)
        Me.Name = "Form1"
        Me.Text = "Form1"
        Me.tabControl1.ResumeLayout(False)
        Me.tabPage0.ResumeLayout(False)
        Me.panel9.ResumeLayout(False)
        Me.panel8.ResumeLayout(False)
        Me.panel1.ResumeLayout(False)
        Me.panel1.PerformLayout()
        Me.panel2.ResumeLayout(False)
        Me.panel2.PerformLayout()
        Me.panel6.ResumeLayout(False)
        Me.panel6.PerformLayout()
        Me.panel3.ResumeLayout(False)
        Me.panel3.PerformLayout()
        Me.panel7.ResumeLayout(False)
        Me.panel7.PerformLayout()
        Me.tabPage1.ResumeLayout(False)
        Me.tabPage1.PerformLayout()
        CType(Me.registerReadIndex, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.registerReadDevId, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.registerReadRegId, System.ComponentModel.ISupportInitialize).EndInit()
        Me.tabPage2.ResumeLayout(False)
        Me.tabPage2.PerformLayout()
        CType(Me.registerWriteIndex, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.registerWriteDevId, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.registerWriteRegId, System.ComponentModel.ISupportInitialize).EndInit()
        Me.tabPage3.ResumeLayout(False)
        Me.tabPage3.PerformLayout()
        CType(Me.registerWriteReadIndex, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.registerWriteReadDevId, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.registerWriteReadRegId, System.ComponentModel.ISupportInitialize).EndInit()
        Me.tabPage4.ResumeLayout(False)
        Me.tabPage4.PerformLayout()
        CType(Me.dedicatedDeviceDevId, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Private WithEvents tabControl1 As System.Windows.Forms.TabControl
    Private WithEvents tabPage0 As System.Windows.Forms.TabPage
    Private WithEvents panel9 As System.Windows.Forms.Panel
    Private WithEvents GetOpenPorts As System.Windows.Forms.Button
    Private WithEvents panel8 As System.Windows.Forms.Panel
    Private WithEvents GetAllPorts As System.Windows.Forms.Button
    Private WithEvents panel1 As System.Windows.Forms.Panel
    Private WithEvents checkBoxLiveMode As System.Windows.Forms.CheckBox
    Private WithEvents OpenPorts As System.Windows.Forms.Button
    Private WithEvents checkBoxAutoMode As System.Windows.Forms.CheckBox
    Private WithEvents openPortsPortname As System.Windows.Forms.TextBox
    Private WithEvents panel2 As System.Windows.Forms.Panel
    Private WithEvents ClosePorts As System.Windows.Forms.Button
    Private WithEvents closePortsPortname As System.Windows.Forms.TextBox
    Private WithEvents panel6 As System.Windows.Forms.Panel
    Private WithEvents label10 As System.Windows.Forms.Label
    Private WithEvents P2PPortGetTimeout As System.Windows.Forms.TextBox
    Private WithEvents label11 As System.Windows.Forms.Label
    Private WithEvents P2PPortGetProtocol As System.Windows.Forms.ComboBox
    Private WithEvents label12 As System.Windows.Forms.Label
    Private WithEvents P2PPortGetClientPort As System.Windows.Forms.TextBox
    Private WithEvents label13 As System.Windows.Forms.Label
    Private WithEvents P2PPortGetHostPort As System.Windows.Forms.TextBox
    Private WithEvents label14 As System.Windows.Forms.Label
    Private WithEvents P2PPortGetClientIP As System.Windows.Forms.TextBox
    Private WithEvents label15 As System.Windows.Forms.Label
    Private WithEvents P2PPortGetHostIP As System.Windows.Forms.TextBox
    Private WithEvents label16 As System.Windows.Forms.Label
    Private WithEvents pointToPointPortGet As System.Windows.Forms.Button
    Private WithEvents P2PPortGetName As System.Windows.Forms.TextBox
    Private WithEvents panel3 As System.Windows.Forms.Panel
    Private WithEvents label7 As System.Windows.Forms.Label
    Private WithEvents P2PPortAddTimeout As System.Windows.Forms.TextBox
    Private WithEvents label6 As System.Windows.Forms.Label
    Private WithEvents P2PPortAddProtocol As System.Windows.Forms.ComboBox
    Private WithEvents label5 As System.Windows.Forms.Label
    Private WithEvents P2PPortAddClientPort As System.Windows.Forms.TextBox
    Private WithEvents label4 As System.Windows.Forms.Label
    Private WithEvents P2PPortAddHostPort As System.Windows.Forms.TextBox
    Private WithEvents label3 As System.Windows.Forms.Label
    Private WithEvents P2PPortAddClientIP As System.Windows.Forms.TextBox
    Private WithEvents label2 As System.Windows.Forms.Label
    Private WithEvents P2PPortAddHostIP As System.Windows.Forms.TextBox
    Private WithEvents label1 As System.Windows.Forms.Label
    Private WithEvents PointToPointPortAdd As System.Windows.Forms.Button
    Private WithEvents P2PPortAddName As System.Windows.Forms.TextBox
    Private WithEvents panel7 As System.Windows.Forms.Panel
    Private WithEvents label23 As System.Windows.Forms.Label
    Private WithEvents pointToPointPortDel As System.Windows.Forms.Button
    Private WithEvents P2PPortDelName As System.Windows.Forms.TextBox
    Private WithEvents tabPage1 As System.Windows.Forms.TabPage
    Private WithEvents registerReadIndex As System.Windows.Forms.NumericUpDown
    Private WithEvents label8 As System.Windows.Forms.Label
    Private WithEvents registerReadDevId As System.Windows.Forms.NumericUpDown
    Private WithEvents label19 As System.Windows.Forms.Label
    Private WithEvents label22 As System.Windows.Forms.Label
    Private WithEvents registerReadPortname As System.Windows.Forms.TextBox
    Private WithEvents registerReadRegId As System.Windows.Forms.NumericUpDown
    Private WithEvents label30 As System.Windows.Forms.Label
    Private WithEvents registerReadAscii As System.Windows.Forms.Button
    Private WithEvents registerReadF64 As System.Windows.Forms.Button
    Private WithEvents registerReadF32 As System.Windows.Forms.Button
    Private WithEvents registerReadS64 As System.Windows.Forms.Button
    Private WithEvents registerReadU8 As System.Windows.Forms.Button
    Private WithEvents registerReadU64 As System.Windows.Forms.Button
    Private WithEvents registerReadS8 As System.Windows.Forms.Button
    Private WithEvents registerReadS32 As System.Windows.Forms.Button
    Private WithEvents registerReadU16 As System.Windows.Forms.Button
    Private WithEvents registerReadU32 As System.Windows.Forms.Button
    Private WithEvents registerReadS16 As System.Windows.Forms.Button
    Private WithEvents tabPage2 As System.Windows.Forms.TabPage
    Private WithEvents registerWriteAsciiEOL As System.Windows.Forms.CheckBox
    Private WithEvents registerWriteIndex As System.Windows.Forms.NumericUpDown
    Private WithEvents label20 As System.Windows.Forms.Label
    Private WithEvents registerWriteDevId As System.Windows.Forms.NumericUpDown
    Private WithEvents label25 As System.Windows.Forms.Label
    Private WithEvents label28 As System.Windows.Forms.Label
    Private WithEvents registerWritePortname As System.Windows.Forms.TextBox
    Private WithEvents registerWriteRegId As System.Windows.Forms.NumericUpDown
    Private WithEvents label29 As System.Windows.Forms.Label
    Private WithEvents label9 As System.Windows.Forms.Label
    Private WithEvents registerWriteAsciiValue As System.Windows.Forms.TextBox
    Private WithEvents registerWriteF64Value As System.Windows.Forms.TextBox
    Private WithEvents registerWriteF32Value As System.Windows.Forms.TextBox
    Private WithEvents registerWriteS64Value As System.Windows.Forms.TextBox
    Private WithEvents registerWriteU64Value As System.Windows.Forms.TextBox
    Private WithEvents registerWriteS32Value As System.Windows.Forms.TextBox
    Private WithEvents registerWriteU32Value As System.Windows.Forms.TextBox
    Private WithEvents registerWriteS16Value As System.Windows.Forms.TextBox
    Private WithEvents registerWriteU16Value As System.Windows.Forms.TextBox
    Private WithEvents registerWriteS8Value As System.Windows.Forms.TextBox
    Private WithEvents registerWriteU8Value As System.Windows.Forms.TextBox
    Private WithEvents registerWriteAscii As System.Windows.Forms.Button
    Private WithEvents registerWriteF64 As System.Windows.Forms.Button
    Private WithEvents registerWriteF32 As System.Windows.Forms.Button
    Private WithEvents registerWriteS64 As System.Windows.Forms.Button
    Private WithEvents registerWriteU8 As System.Windows.Forms.Button
    Private WithEvents registerWriteU64 As System.Windows.Forms.Button
    Private WithEvents registerWriteS8 As System.Windows.Forms.Button
    Private WithEvents registerWriteS32 As System.Windows.Forms.Button
    Private WithEvents registerWriteU16 As System.Windows.Forms.Button
    Private WithEvents registerWriteU32 As System.Windows.Forms.Button
    Private WithEvents registerWriteS16 As System.Windows.Forms.Button
    Private WithEvents tabPage3 As System.Windows.Forms.TabPage
    Private WithEvents registerWriteReadAsciiEOL As System.Windows.Forms.CheckBox
    Private WithEvents registerWriteReadAscii As System.Windows.Forms.Button
    Private WithEvents registerWriteReadIndex As System.Windows.Forms.NumericUpDown
    Private WithEvents label17 As System.Windows.Forms.Label
    Private WithEvents registerWriteReadDevId As System.Windows.Forms.NumericUpDown
    Private WithEvents label24 As System.Windows.Forms.Label
    Private WithEvents label26 As System.Windows.Forms.Label
    Private WithEvents registerWriteReadPortname As System.Windows.Forms.TextBox
    Private WithEvents registerWriteReadRegId As System.Windows.Forms.NumericUpDown
    Private WithEvents label27 As System.Windows.Forms.Label
    Private WithEvents label18 As System.Windows.Forms.Label
    Private WithEvents registerWriteReadAsciiWrValue As System.Windows.Forms.TextBox
    Private WithEvents registerWriteReadF64WrValue As System.Windows.Forms.TextBox
    Private WithEvents registerWriteReadF32WrValue As System.Windows.Forms.TextBox
    Private WithEvents registerWriteReadS64WrValue As System.Windows.Forms.TextBox
    Private WithEvents registerWriteReadU64WrValue As System.Windows.Forms.TextBox
    Private WithEvents registerWriteReadS32WrValue As System.Windows.Forms.TextBox
    Private WithEvents registerWriteReadU32WrValue As System.Windows.Forms.TextBox
    Private WithEvents registerWriteReadS16WrValue As System.Windows.Forms.TextBox
    Private WithEvents registerWriteReadU16WrValue As System.Windows.Forms.TextBox
    Private WithEvents registerWriteReadS8WrValue As System.Windows.Forms.TextBox
    Private WithEvents registerWriteReadU8WrValue As System.Windows.Forms.TextBox
    Private WithEvents registerWriteReadF64 As System.Windows.Forms.Button
    Private WithEvents registerWriteReadF32 As System.Windows.Forms.Button
    Private WithEvents registerWriteReadS64 As System.Windows.Forms.Button
    Private WithEvents registerWriteReadU64 As System.Windows.Forms.Button
    Private WithEvents registerWriteReadS32 As System.Windows.Forms.Button
    Private WithEvents registerWriteReadU32 As System.Windows.Forms.Button
    Private WithEvents registerWriteReadS16 As System.Windows.Forms.Button
    Private WithEvents registerWriteReadU16 As System.Windows.Forms.Button
    Private WithEvents registerWriteReadS8 As System.Windows.Forms.Button
    Private WithEvents registerWriteReadU8 As System.Windows.Forms.Button
    Private WithEvents tabPage4 As System.Windows.Forms.TabPage
    Private WithEvents deviceGetPCBSerialNumberStr As System.Windows.Forms.Button
    Private WithEvents deviceGetModuleSerialNumberStr As System.Windows.Forms.Button
    Private WithEvents deviceGetFirmwareVersionStr As System.Windows.Forms.Button
    Private WithEvents deviceGetFirmwareVersion As System.Windows.Forms.Button
    Private WithEvents deviceGetBootloaderVersionStr As System.Windows.Forms.Button
    Private WithEvents deviceGetBootloaderVersion As System.Windows.Forms.Button
    Private WithEvents deviceGetErrorCode As System.Windows.Forms.Button
    Private WithEvents deviceGetStatusBits As System.Windows.Forms.Button
    Private WithEvents deviceGetPCBVersion As System.Windows.Forms.Button
    Private WithEvents deviceGetPartnumberStr As System.Windows.Forms.Button
    Private WithEvents dedicatedDeviceDevId As System.Windows.Forms.NumericUpDown
    Private WithEvents label31 As System.Windows.Forms.Label
    Private WithEvents label32 As System.Windows.Forms.Label
    Private WithEvents dedicatedDevicePortname As System.Windows.Forms.TextBox
    Private WithEvents deviceGetType As System.Windows.Forms.Button
    Private WithEvents ExitButton As System.Windows.Forms.Button
    Private WithEvents StatusTextBox As System.Windows.Forms.TextBox

End Class
