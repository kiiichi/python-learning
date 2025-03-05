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
        Me.panel3 = New System.Windows.Forms.Panel()
        Me.setCallbackPtrPortInfo = New System.Windows.Forms.CheckBox()
        Me.closePortsPortname = New System.Windows.Forms.TextBox()
        Me.openPorts = New System.Windows.Forms.Button()
        Me.openPortsPortname = New System.Windows.Forms.TextBox()
        Me.closePorts = New System.Windows.Forms.Button()
        Me.label5 = New System.Windows.Forms.Label()
        Me.CheckBoxAutoMode = New System.Windows.Forms.CheckBox()
        Me.CheckBoxLiveMode = New System.Windows.Forms.CheckBox()
        Me.panel2 = New System.Windows.Forms.Panel()
        Me.setCallbackPtrRegisterInfo = New System.Windows.Forms.CheckBox()
        Me.label29 = New System.Windows.Forms.Label()
        Me.registerCreateRegId = New System.Windows.Forms.NumericUpDown()
        Me.label1 = New System.Windows.Forms.Label()
        Me.registerCreateDevId = New System.Windows.Forms.NumericUpDown()
        Me.label4 = New System.Windows.Forms.Label()
        Me.registerCreate = New System.Windows.Forms.Button()
        Me.registerCreatePortname = New System.Windows.Forms.TextBox()
        Me.registerCreatePriority = New System.Windows.Forms.ComboBox()
        Me.label3 = New System.Windows.Forms.Label()
        Me.label2 = New System.Windows.Forms.Label()
        Me.registerCreateDataType = New System.Windows.Forms.ComboBox()
        Me.panel1 = New System.Windows.Forms.Panel()
        Me.setCallbackPtrDeviceInfo = New System.Windows.Forms.CheckBox()
        Me.deviceCreate = New System.Windows.Forms.Button()
        Me.label25 = New System.Windows.Forms.Label()
        Me.deviceCreateDevId = New System.Windows.Forms.NumericUpDown()
        Me.deviceCreateWaitReady = New System.Windows.Forms.CheckBox()
        Me.deviceCreatePortname = New System.Windows.Forms.TextBox()
        Me.label28 = New System.Windows.Forms.Label()
        Me.getOpenPorts = New System.Windows.Forms.Button()
        Me.StatusTextBox = New System.Windows.Forms.TextBox()
        Me.getAllPorts = New System.Windows.Forms.Button()
        Me.comboBoxPortname = New System.Windows.Forms.ComboBox()
        Me.panel3.SuspendLayout()
        Me.panel2.SuspendLayout()
        CType(Me.registerCreateRegId, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.registerCreateDevId, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.panel1.SuspendLayout()
        CType(Me.deviceCreateDevId, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.SuspendLayout()
        '
        'panel3
        '
        Me.panel3.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.panel3.Controls.Add(Me.setCallbackPtrPortInfo)
        Me.panel3.Controls.Add(Me.closePortsPortname)
        Me.panel3.Controls.Add(Me.openPorts)
        Me.panel3.Controls.Add(Me.openPortsPortname)
        Me.panel3.Controls.Add(Me.closePorts)
        Me.panel3.Controls.Add(Me.label5)
        Me.panel3.Controls.Add(Me.CheckBoxAutoMode)
        Me.panel3.Controls.Add(Me.CheckBoxLiveMode)
        Me.panel3.Location = New System.Drawing.Point(12, 41)
        Me.panel3.Name = "panel3"
        Me.panel3.Size = New System.Drawing.Size(500, 99)
        Me.panel3.TabIndex = 168
        '
        'setCallbackPtrPortInfo
        '
        Me.setCallbackPtrPortInfo.AutoSize = True
        Me.setCallbackPtrPortInfo.Location = New System.Drawing.Point(3, 3)
        Me.setCallbackPtrPortInfo.Name = "setCallbackPtrPortInfo"
        Me.setCallbackPtrPortInfo.Size = New System.Drawing.Size(112, 17)
        Me.setCallbackPtrPortInfo.TabIndex = 153
        Me.setCallbackPtrPortInfo.Text = "PortInfo Callbacks"
        Me.setCallbackPtrPortInfo.UseVisualStyleBackColor = True
        '
        'closePortsPortname
        '
        Me.closePortsPortname.Location = New System.Drawing.Point(95, 68)
        Me.closePortsPortname.Name = "closePortsPortname"
        Me.closePortsPortname.Size = New System.Drawing.Size(102, 20)
        Me.closePortsPortname.TabIndex = 160
        '
        'openPorts
        '
        Me.openPorts.Location = New System.Drawing.Point(3, 37)
        Me.openPorts.Name = "openPorts"
        Me.openPorts.Size = New System.Drawing.Size(86, 23)
        Me.openPorts.TabIndex = 2
        Me.openPorts.Text = "openPorts"
        Me.openPorts.UseVisualStyleBackColor = True
        '
        'openPortsPortname
        '
        Me.openPortsPortname.Location = New System.Drawing.Point(95, 39)
        Me.openPortsPortname.Name = "openPortsPortname"
        Me.openPortsPortname.Size = New System.Drawing.Size(102, 20)
        Me.openPortsPortname.TabIndex = 159
        '
        'closePorts
        '
        Me.closePorts.Location = New System.Drawing.Point(3, 66)
        Me.closePorts.Name = "closePorts"
        Me.closePorts.Size = New System.Drawing.Size(86, 23)
        Me.closePorts.TabIndex = 3
        Me.closePorts.Text = "closePorts"
        Me.closePorts.UseVisualStyleBackColor = True
        '
        'label5
        '
        Me.label5.AutoSize = True
        Me.label5.Location = New System.Drawing.Point(92, 23)
        Me.label5.Name = "label5"
        Me.label5.Size = New System.Drawing.Size(55, 13)
        Me.label5.TabIndex = 158
        Me.label5.Text = "Portname:"
        '
        'CheckBoxAutoMode
        '
        Me.CheckBoxAutoMode.AutoSize = True
        Me.CheckBoxAutoMode.Location = New System.Drawing.Point(203, 41)
        Me.CheckBoxAutoMode.Name = "CheckBoxAutoMode"
        Me.CheckBoxAutoMode.Size = New System.Drawing.Size(74, 17)
        Me.CheckBoxAutoMode.TabIndex = 6
        Me.CheckBoxAutoMode.Text = "autoMode"
        Me.CheckBoxAutoMode.UseVisualStyleBackColor = True
        '
        'CheckBoxLiveMode
        '
        Me.CheckBoxLiveMode.AutoSize = True
        Me.CheckBoxLiveMode.Location = New System.Drawing.Point(283, 41)
        Me.CheckBoxLiveMode.Name = "CheckBoxLiveMode"
        Me.CheckBoxLiveMode.Size = New System.Drawing.Size(69, 17)
        Me.CheckBoxLiveMode.TabIndex = 7
        Me.CheckBoxLiveMode.Text = "liveMode"
        Me.CheckBoxLiveMode.UseVisualStyleBackColor = True
        '
        'panel2
        '
        Me.panel2.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.panel2.Controls.Add(Me.setCallbackPtrRegisterInfo)
        Me.panel2.Controls.Add(Me.label29)
        Me.panel2.Controls.Add(Me.registerCreateRegId)
        Me.panel2.Controls.Add(Me.label1)
        Me.panel2.Controls.Add(Me.registerCreateDevId)
        Me.panel2.Controls.Add(Me.label4)
        Me.panel2.Controls.Add(Me.registerCreate)
        Me.panel2.Controls.Add(Me.registerCreatePortname)
        Me.panel2.Controls.Add(Me.registerCreatePriority)
        Me.panel2.Controls.Add(Me.label3)
        Me.panel2.Controls.Add(Me.label2)
        Me.panel2.Controls.Add(Me.registerCreateDataType)
        Me.panel2.Location = New System.Drawing.Point(12, 222)
        Me.panel2.Name = "panel2"
        Me.panel2.Size = New System.Drawing.Size(500, 71)
        Me.panel2.TabIndex = 167
        '
        'setCallbackPtrRegisterInfo
        '
        Me.setCallbackPtrRegisterInfo.AutoSize = True
        Me.setCallbackPtrRegisterInfo.Location = New System.Drawing.Point(3, 3)
        Me.setCallbackPtrRegisterInfo.Name = "setCallbackPtrRegisterInfo"
        Me.setCallbackPtrRegisterInfo.Size = New System.Drawing.Size(132, 17)
        Me.setCallbackPtrRegisterInfo.TabIndex = 158
        Me.setCallbackPtrRegisterInfo.Text = "RegisterInfo Callbacks"
        Me.setCallbackPtrRegisterInfo.UseVisualStyleBackColor = True
        '
        'label29
        '
        Me.label29.AutoSize = True
        Me.label29.Location = New System.Drawing.Point(248, 24)
        Me.label29.Name = "label29"
        Me.label29.Size = New System.Drawing.Size(45, 13)
        Me.label29.TabIndex = 139
        Me.label29.Text = "Reg. Id:"
        '
        'registerCreateRegId
        '
        Me.registerCreateRegId.Hexadecimal = True
        Me.registerCreateRegId.Location = New System.Drawing.Point(251, 40)
        Me.registerCreateRegId.Maximum = New Decimal(New Integer() {254, 0, 0, 0})
        Me.registerCreateRegId.Name = "registerCreateRegId"
        Me.registerCreateRegId.Size = New System.Drawing.Size(42, 20)
        Me.registerCreateRegId.TabIndex = 137
        Me.registerCreateRegId.TextAlign = System.Windows.Forms.HorizontalAlignment.Right
        Me.registerCreateRegId.Value = New Decimal(New Integer() {1, 0, 0, 0})
        '
        'label1
        '
        Me.label1.AutoSize = True
        Me.label1.Location = New System.Drawing.Point(200, 24)
        Me.label1.Name = "label1"
        Me.label1.Size = New System.Drawing.Size(45, 13)
        Me.label1.TabIndex = 142
        Me.label1.Text = "Dev. Id:"
        '
        'registerCreateDevId
        '
        Me.registerCreateDevId.Location = New System.Drawing.Point(203, 40)
        Me.registerCreateDevId.Maximum = New Decimal(New Integer() {255, 0, 0, 0})
        Me.registerCreateDevId.Minimum = New Decimal(New Integer() {1, 0, 0, 0})
        Me.registerCreateDevId.Name = "registerCreateDevId"
        Me.registerCreateDevId.Size = New System.Drawing.Size(42, 20)
        Me.registerCreateDevId.TabIndex = 141
        Me.registerCreateDevId.TextAlign = System.Windows.Forms.HorizontalAlignment.Right
        Me.registerCreateDevId.Value = New Decimal(New Integer() {1, 0, 0, 0})
        '
        'label4
        '
        Me.label4.AutoSize = True
        Me.label4.Location = New System.Drawing.Point(92, 23)
        Me.label4.Name = "label4"
        Me.label4.Size = New System.Drawing.Size(55, 13)
        Me.label4.TabIndex = 152
        Me.label4.Text = "Portname:"
        '
        'registerCreate
        '
        Me.registerCreate.Location = New System.Drawing.Point(3, 37)
        Me.registerCreate.Name = "registerCreate"
        Me.registerCreate.Size = New System.Drawing.Size(86, 23)
        Me.registerCreate.TabIndex = 143
        Me.registerCreate.Text = "registerCreate"
        Me.registerCreate.UseVisualStyleBackColor = True
        '
        'registerCreatePortname
        '
        Me.registerCreatePortname.Location = New System.Drawing.Point(95, 39)
        Me.registerCreatePortname.Name = "registerCreatePortname"
        Me.registerCreatePortname.Size = New System.Drawing.Size(102, 20)
        Me.registerCreatePortname.TabIndex = 151
        '
        'registerCreatePriority
        '
        Me.registerCreatePriority.FormattingEnabled = True
        Me.registerCreatePriority.Items.AddRange(New Object() {"Low", "High"})
        Me.registerCreatePriority.Location = New System.Drawing.Point(299, 40)
        Me.registerCreatePriority.Name = "registerCreatePriority"
        Me.registerCreatePriority.Size = New System.Drawing.Size(92, 21)
        Me.registerCreatePriority.TabIndex = 145
        '
        'label3
        '
        Me.label3.AutoSize = True
        Me.label3.Location = New System.Drawing.Point(394, 24)
        Me.label3.Name = "label3"
        Me.label3.Size = New System.Drawing.Size(53, 13)
        Me.label3.TabIndex = 148
        Me.label3.Text = "Datatype:"
        '
        'label2
        '
        Me.label2.AutoSize = True
        Me.label2.Location = New System.Drawing.Point(299, 24)
        Me.label2.Name = "label2"
        Me.label2.Size = New System.Drawing.Size(41, 13)
        Me.label2.TabIndex = 146
        Me.label2.Text = "Priority:"
        '
        'registerCreateDataType
        '
        Me.registerCreateDataType.FormattingEnabled = True
        Me.registerCreateDataType.Items.AddRange(New Object() {"Unknown = 0", "Array = 1", "U8 = 2", "S8 = 3", "U16 = 4", "S16 = 5", "U32 = 6", "S32 = 7", "F32 = 8", "U64 = 9", "S64 = 10", "F64 = 11", "Ascii = 12", "Paramset = 13", "B8 = 14", "H8 = 15", "B16 = 16", "H16 = 17", "B32 = 18", "H32 = 19", "B64 = 20", "H64 = 21", "DateTime = 22"})
        Me.registerCreateDataType.Location = New System.Drawing.Point(397, 39)
        Me.registerCreateDataType.Name = "registerCreateDataType"
        Me.registerCreateDataType.Size = New System.Drawing.Size(92, 21)
        Me.registerCreateDataType.TabIndex = 147
        '
        'panel1
        '
        Me.panel1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.panel1.Controls.Add(Me.setCallbackPtrDeviceInfo)
        Me.panel1.Controls.Add(Me.deviceCreate)
        Me.panel1.Controls.Add(Me.label25)
        Me.panel1.Controls.Add(Me.deviceCreateDevId)
        Me.panel1.Controls.Add(Me.deviceCreateWaitReady)
        Me.panel1.Controls.Add(Me.deviceCreatePortname)
        Me.panel1.Controls.Add(Me.label28)
        Me.panel1.Location = New System.Drawing.Point(12, 146)
        Me.panel1.Name = "panel1"
        Me.panel1.Size = New System.Drawing.Size(500, 70)
        Me.panel1.TabIndex = 166
        '
        'setCallbackPtrDeviceInfo
        '
        Me.setCallbackPtrDeviceInfo.AutoSize = True
        Me.setCallbackPtrDeviceInfo.Location = New System.Drawing.Point(3, 3)
        Me.setCallbackPtrDeviceInfo.Name = "setCallbackPtrDeviceInfo"
        Me.setCallbackPtrDeviceInfo.Size = New System.Drawing.Size(127, 17)
        Me.setCallbackPtrDeviceInfo.TabIndex = 155
        Me.setCallbackPtrDeviceInfo.Text = "DeviceInfo Callbacks"
        Me.setCallbackPtrDeviceInfo.UseVisualStyleBackColor = True
        '
        'deviceCreate
        '
        Me.deviceCreate.Location = New System.Drawing.Point(3, 37)
        Me.deviceCreate.Name = "deviceCreate"
        Me.deviceCreate.Size = New System.Drawing.Size(86, 23)
        Me.deviceCreate.TabIndex = 8
        Me.deviceCreate.Text = "deviceCreate"
        Me.deviceCreate.UseVisualStyleBackColor = True
        '
        'label25
        '
        Me.label25.AutoSize = True
        Me.label25.Location = New System.Drawing.Point(200, 24)
        Me.label25.Name = "label25"
        Me.label25.Size = New System.Drawing.Size(45, 13)
        Me.label25.TabIndex = 140
        Me.label25.Text = "Dev. Id:"
        '
        'deviceCreateDevId
        '
        Me.deviceCreateDevId.Location = New System.Drawing.Point(203, 40)
        Me.deviceCreateDevId.Maximum = New Decimal(New Integer() {255, 0, 0, 0})
        Me.deviceCreateDevId.Minimum = New Decimal(New Integer() {1, 0, 0, 0})
        Me.deviceCreateDevId.Name = "deviceCreateDevId"
        Me.deviceCreateDevId.Size = New System.Drawing.Size(42, 20)
        Me.deviceCreateDevId.TabIndex = 136
        Me.deviceCreateDevId.TextAlign = System.Windows.Forms.HorizontalAlignment.Right
        Me.deviceCreateDevId.Value = New Decimal(New Integer() {1, 0, 0, 0})
        '
        'deviceCreateWaitReady
        '
        Me.deviceCreateWaitReady.AutoSize = True
        Me.deviceCreateWaitReady.Location = New System.Drawing.Point(251, 41)
        Me.deviceCreateWaitReady.Name = "deviceCreateWaitReady"
        Me.deviceCreateWaitReady.Size = New System.Drawing.Size(76, 17)
        Me.deviceCreateWaitReady.TabIndex = 144
        Me.deviceCreateWaitReady.Text = "waitReady"
        Me.deviceCreateWaitReady.UseVisualStyleBackColor = True
        '
        'deviceCreatePortname
        '
        Me.deviceCreatePortname.Location = New System.Drawing.Point(95, 39)
        Me.deviceCreatePortname.Name = "deviceCreatePortname"
        Me.deviceCreatePortname.Size = New System.Drawing.Size(102, 20)
        Me.deviceCreatePortname.TabIndex = 149
        '
        'label28
        '
        Me.label28.AutoSize = True
        Me.label28.Location = New System.Drawing.Point(92, 23)
        Me.label28.Name = "label28"
        Me.label28.Size = New System.Drawing.Size(55, 13)
        Me.label28.TabIndex = 150
        Me.label28.Text = "Portname:"
        '
        'getOpenPorts
        '
        Me.getOpenPorts.Location = New System.Drawing.Point(12, 12)
        Me.getOpenPorts.Name = "getOpenPorts"
        Me.getOpenPorts.Size = New System.Drawing.Size(86, 23)
        Me.getOpenPorts.TabIndex = 165
        Me.getOpenPorts.Text = "getOpenPorts"
        Me.getOpenPorts.UseVisualStyleBackColor = True
        '
        'StatusTextBox
        '
        Me.StatusTextBox.Location = New System.Drawing.Point(12, 299)
        Me.StatusTextBox.Multiline = True
        Me.StatusTextBox.Name = "StatusTextBox"
        Me.StatusTextBox.ScrollBars = System.Windows.Forms.ScrollBars.Vertical
        Me.StatusTextBox.Size = New System.Drawing.Size(500, 187)
        Me.StatusTextBox.TabIndex = 164
        '
        'getAllPorts
        '
        Me.getAllPorts.Location = New System.Drawing.Point(104, 12)
        Me.getAllPorts.Name = "getAllPorts"
        Me.getAllPorts.Size = New System.Drawing.Size(75, 23)
        Me.getAllPorts.TabIndex = 163
        Me.getAllPorts.Text = "getAllPorts"
        Me.getAllPorts.UseVisualStyleBackColor = True
        '
        'comboBoxPortname
        '
        Me.comboBoxPortname.FormattingEnabled = True
        Me.comboBoxPortname.Location = New System.Drawing.Point(185, 14)
        Me.comboBoxPortname.Name = "comboBoxPortname"
        Me.comboBoxPortname.Size = New System.Drawing.Size(121, 21)
        Me.comboBoxPortname.TabIndex = 162
        '
        'Form1
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(589, 510)
        Me.Controls.Add(Me.panel3)
        Me.Controls.Add(Me.panel2)
        Me.Controls.Add(Me.panel1)
        Me.Controls.Add(Me.getOpenPorts)
        Me.Controls.Add(Me.StatusTextBox)
        Me.Controls.Add(Me.getAllPorts)
        Me.Controls.Add(Me.comboBoxPortname)
        Me.Name = "Form1"
        Me.Text = "Form1"
        Me.panel3.ResumeLayout(False)
        Me.panel3.PerformLayout()
        Me.panel2.ResumeLayout(False)
        Me.panel2.PerformLayout()
        CType(Me.registerCreateRegId, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.registerCreateDevId, System.ComponentModel.ISupportInitialize).EndInit()
        Me.panel1.ResumeLayout(False)
        Me.panel1.PerformLayout()
        CType(Me.deviceCreateDevId, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Private WithEvents panel3 As System.Windows.Forms.Panel
    Private WithEvents setCallbackPtrPortInfo As System.Windows.Forms.CheckBox
    Private WithEvents closePortsPortname As System.Windows.Forms.TextBox
    Private WithEvents openPorts As System.Windows.Forms.Button
    Private WithEvents openPortsPortname As System.Windows.Forms.TextBox
    Private WithEvents closePorts As System.Windows.Forms.Button
    Private WithEvents label5 As System.Windows.Forms.Label
    Private WithEvents CheckBoxAutoMode As System.Windows.Forms.CheckBox
    Private WithEvents CheckBoxLiveMode As System.Windows.Forms.CheckBox
    Private WithEvents panel2 As System.Windows.Forms.Panel
    Private WithEvents setCallbackPtrRegisterInfo As System.Windows.Forms.CheckBox
    Private WithEvents label29 As System.Windows.Forms.Label
    Private WithEvents registerCreateRegId As System.Windows.Forms.NumericUpDown
    Private WithEvents label1 As System.Windows.Forms.Label
    Private WithEvents registerCreateDevId As System.Windows.Forms.NumericUpDown
    Private WithEvents label4 As System.Windows.Forms.Label
    Private WithEvents registerCreate As System.Windows.Forms.Button
    Private WithEvents registerCreatePortname As System.Windows.Forms.TextBox
    Private WithEvents registerCreatePriority As System.Windows.Forms.ComboBox
    Private WithEvents label3 As System.Windows.Forms.Label
    Private WithEvents label2 As System.Windows.Forms.Label
    Private WithEvents registerCreateDataType As System.Windows.Forms.ComboBox
    Private WithEvents panel1 As System.Windows.Forms.Panel
    Private WithEvents setCallbackPtrDeviceInfo As System.Windows.Forms.CheckBox
    Private WithEvents deviceCreate As System.Windows.Forms.Button
    Private WithEvents label25 As System.Windows.Forms.Label
    Private WithEvents deviceCreateDevId As System.Windows.Forms.NumericUpDown
    Private WithEvents deviceCreateWaitReady As System.Windows.Forms.CheckBox
    Private WithEvents deviceCreatePortname As System.Windows.Forms.TextBox
    Private WithEvents label28 As System.Windows.Forms.Label
    Private WithEvents getOpenPorts As System.Windows.Forms.Button
    Private WithEvents StatusTextBox As System.Windows.Forms.TextBox
    Private WithEvents getAllPorts As System.Windows.Forms.Button
    Private WithEvents comboBoxPortname As System.Windows.Forms.ComboBox

End Class
