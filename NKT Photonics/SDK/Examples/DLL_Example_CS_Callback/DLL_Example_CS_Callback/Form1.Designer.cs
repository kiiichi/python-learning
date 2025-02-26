namespace DLL_Example_CS_Callback
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.comboBoxPortname = new System.Windows.Forms.ComboBox();
            this.getAllPorts = new System.Windows.Forms.Button();
            this.openPorts = new System.Windows.Forms.Button();
            this.closePorts = new System.Windows.Forms.Button();
            this.StatusTextBox = new System.Windows.Forms.TextBox();
            this.getOpenPorts = new System.Windows.Forms.Button();
            this.CheckBoxAutoMode = new System.Windows.Forms.CheckBox();
            this.CheckBoxLiveMode = new System.Windows.Forms.CheckBox();
            this.deviceCreate = new System.Windows.Forms.Button();
            this.deviceCreateDevId = new System.Windows.Forms.NumericUpDown();
            this.label25 = new System.Windows.Forms.Label();
            this.registerCreateRegId = new System.Windows.Forms.NumericUpDown();
            this.label29 = new System.Windows.Forms.Label();
            this.registerCreateDevId = new System.Windows.Forms.NumericUpDown();
            this.label1 = new System.Windows.Forms.Label();
            this.registerCreate = new System.Windows.Forms.Button();
            this.deviceCreateWaitReady = new System.Windows.Forms.CheckBox();
            this.registerCreatePriority = new System.Windows.Forms.ComboBox();
            this.label2 = new System.Windows.Forms.Label();
            this.registerCreateDataType = new System.Windows.Forms.ComboBox();
            this.label3 = new System.Windows.Forms.Label();
            this.label28 = new System.Windows.Forms.Label();
            this.deviceCreatePortname = new System.Windows.Forms.TextBox();
            this.label4 = new System.Windows.Forms.Label();
            this.registerCreatePortname = new System.Windows.Forms.TextBox();
            this.setCallbackPtrPortInfo = new System.Windows.Forms.CheckBox();
            this.setCallbackPtrDeviceInfo = new System.Windows.Forms.CheckBox();
            this.panel1 = new System.Windows.Forms.Panel();
            this.panel2 = new System.Windows.Forms.Panel();
            this.setCallbackPtrRegisterInfo = new System.Windows.Forms.CheckBox();
            this.label5 = new System.Windows.Forms.Label();
            this.openPortsPortname = new System.Windows.Forms.TextBox();
            this.closePortsPortname = new System.Windows.Forms.TextBox();
            this.panel3 = new System.Windows.Forms.Panel();
            ((System.ComponentModel.ISupportInitialize)(this.deviceCreateDevId)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.registerCreateRegId)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.registerCreateDevId)).BeginInit();
            this.panel1.SuspendLayout();
            this.panel2.SuspendLayout();
            this.panel3.SuspendLayout();
            this.SuspendLayout();
            // 
            // comboBoxPortname
            // 
            this.comboBoxPortname.FormattingEnabled = true;
            this.comboBoxPortname.Location = new System.Drawing.Point(185, 14);
            this.comboBoxPortname.Name = "comboBoxPortname";
            this.comboBoxPortname.Size = new System.Drawing.Size(121, 21);
            this.comboBoxPortname.TabIndex = 0;
            this.comboBoxPortname.SelectedIndexChanged += new System.EventHandler(this.comboBoxPortname_SelectedIndexChanged);
            // 
            // getAllPorts
            // 
            this.getAllPorts.Location = new System.Drawing.Point(104, 12);
            this.getAllPorts.Name = "getAllPorts";
            this.getAllPorts.Size = new System.Drawing.Size(75, 23);
            this.getAllPorts.TabIndex = 1;
            this.getAllPorts.Text = "getAllPorts";
            this.getAllPorts.UseVisualStyleBackColor = true;
            this.getAllPorts.Click += new System.EventHandler(this.getAllPorts_Click);
            // 
            // openPorts
            // 
            this.openPorts.Location = new System.Drawing.Point(3, 37);
            this.openPorts.Name = "openPorts";
            this.openPorts.Size = new System.Drawing.Size(86, 23);
            this.openPorts.TabIndex = 2;
            this.openPorts.Text = "openPorts";
            this.openPorts.UseVisualStyleBackColor = true;
            this.openPorts.Click += new System.EventHandler(this.openPorts_Click);
            // 
            // closePorts
            // 
            this.closePorts.Location = new System.Drawing.Point(3, 66);
            this.closePorts.Name = "closePorts";
            this.closePorts.Size = new System.Drawing.Size(86, 23);
            this.closePorts.TabIndex = 3;
            this.closePorts.Text = "closePorts";
            this.closePorts.UseVisualStyleBackColor = true;
            this.closePorts.Click += new System.EventHandler(this.closePorts_Click);
            // 
            // StatusTextBox
            // 
            this.StatusTextBox.Location = new System.Drawing.Point(12, 299);
            this.StatusTextBox.Multiline = true;
            this.StatusTextBox.Name = "StatusTextBox";
            this.StatusTextBox.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.StatusTextBox.Size = new System.Drawing.Size(500, 187);
            this.StatusTextBox.TabIndex = 4;
            // 
            // getOpenPorts
            // 
            this.getOpenPorts.Location = new System.Drawing.Point(12, 12);
            this.getOpenPorts.Name = "getOpenPorts";
            this.getOpenPorts.Size = new System.Drawing.Size(86, 23);
            this.getOpenPorts.TabIndex = 5;
            this.getOpenPorts.Text = "getOpenPorts";
            this.getOpenPorts.UseVisualStyleBackColor = true;
            this.getOpenPorts.Click += new System.EventHandler(this.getOpenPorts_Click);
            // 
            // CheckBoxAutoMode
            // 
            this.CheckBoxAutoMode.AutoSize = true;
            this.CheckBoxAutoMode.Location = new System.Drawing.Point(203, 41);
            this.CheckBoxAutoMode.Name = "CheckBoxAutoMode";
            this.CheckBoxAutoMode.Size = new System.Drawing.Size(74, 17);
            this.CheckBoxAutoMode.TabIndex = 6;
            this.CheckBoxAutoMode.Text = "autoMode";
            this.CheckBoxAutoMode.UseVisualStyleBackColor = true;
            // 
            // CheckBoxLiveMode
            // 
            this.CheckBoxLiveMode.AutoSize = true;
            this.CheckBoxLiveMode.Location = new System.Drawing.Point(283, 41);
            this.CheckBoxLiveMode.Name = "CheckBoxLiveMode";
            this.CheckBoxLiveMode.Size = new System.Drawing.Size(69, 17);
            this.CheckBoxLiveMode.TabIndex = 7;
            this.CheckBoxLiveMode.Text = "liveMode";
            this.CheckBoxLiveMode.UseVisualStyleBackColor = true;
            // 
            // deviceCreate
            // 
            this.deviceCreate.Location = new System.Drawing.Point(3, 37);
            this.deviceCreate.Name = "deviceCreate";
            this.deviceCreate.Size = new System.Drawing.Size(86, 23);
            this.deviceCreate.TabIndex = 8;
            this.deviceCreate.Text = "deviceCreate";
            this.deviceCreate.UseVisualStyleBackColor = true;
            this.deviceCreate.Click += new System.EventHandler(this.deviceCreate_Click);
            // 
            // deviceCreateDevId
            // 
            this.deviceCreateDevId.Location = new System.Drawing.Point(203, 40);
            this.deviceCreateDevId.Maximum = new decimal(new int[] {
            255,
            0,
            0,
            0});
            this.deviceCreateDevId.Minimum = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.deviceCreateDevId.Name = "deviceCreateDevId";
            this.deviceCreateDevId.Size = new System.Drawing.Size(42, 20);
            this.deviceCreateDevId.TabIndex = 136;
            this.deviceCreateDevId.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            this.deviceCreateDevId.Value = new decimal(new int[] {
            1,
            0,
            0,
            0});
            // 
            // label25
            // 
            this.label25.AutoSize = true;
            this.label25.Location = new System.Drawing.Point(200, 24);
            this.label25.Name = "label25";
            this.label25.Size = new System.Drawing.Size(45, 13);
            this.label25.TabIndex = 140;
            this.label25.Text = "Dev. Id:";
            // 
            // registerCreateRegId
            // 
            this.registerCreateRegId.Hexadecimal = true;
            this.registerCreateRegId.Location = new System.Drawing.Point(251, 40);
            this.registerCreateRegId.Maximum = new decimal(new int[] {
            254,
            0,
            0,
            0});
            this.registerCreateRegId.Name = "registerCreateRegId";
            this.registerCreateRegId.Size = new System.Drawing.Size(42, 20);
            this.registerCreateRegId.TabIndex = 137;
            this.registerCreateRegId.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            this.registerCreateRegId.Value = new decimal(new int[] {
            1,
            0,
            0,
            0});
            // 
            // label29
            // 
            this.label29.AutoSize = true;
            this.label29.Location = new System.Drawing.Point(248, 24);
            this.label29.Name = "label29";
            this.label29.Size = new System.Drawing.Size(45, 13);
            this.label29.TabIndex = 139;
            this.label29.Text = "Reg. Id:";
            // 
            // registerCreateDevId
            // 
            this.registerCreateDevId.Location = new System.Drawing.Point(203, 40);
            this.registerCreateDevId.Maximum = new decimal(new int[] {
            255,
            0,
            0,
            0});
            this.registerCreateDevId.Minimum = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.registerCreateDevId.Name = "registerCreateDevId";
            this.registerCreateDevId.Size = new System.Drawing.Size(42, 20);
            this.registerCreateDevId.TabIndex = 141;
            this.registerCreateDevId.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            this.registerCreateDevId.Value = new decimal(new int[] {
            1,
            0,
            0,
            0});
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(200, 24);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(45, 13);
            this.label1.TabIndex = 142;
            this.label1.Text = "Dev. Id:";
            // 
            // registerCreate
            // 
            this.registerCreate.Location = new System.Drawing.Point(3, 37);
            this.registerCreate.Name = "registerCreate";
            this.registerCreate.Size = new System.Drawing.Size(86, 23);
            this.registerCreate.TabIndex = 143;
            this.registerCreate.Text = "registerCreate";
            this.registerCreate.UseVisualStyleBackColor = true;
            this.registerCreate.Click += new System.EventHandler(this.registerCreate_Click);
            // 
            // deviceCreateWaitReady
            // 
            this.deviceCreateWaitReady.AutoSize = true;
            this.deviceCreateWaitReady.Location = new System.Drawing.Point(251, 41);
            this.deviceCreateWaitReady.Name = "deviceCreateWaitReady";
            this.deviceCreateWaitReady.Size = new System.Drawing.Size(76, 17);
            this.deviceCreateWaitReady.TabIndex = 144;
            this.deviceCreateWaitReady.Text = "waitReady";
            this.deviceCreateWaitReady.UseVisualStyleBackColor = true;
            // 
            // registerCreatePriority
            // 
            this.registerCreatePriority.FormattingEnabled = true;
            this.registerCreatePriority.Items.AddRange(new object[] {
            "Low",
            "High"});
            this.registerCreatePriority.Location = new System.Drawing.Point(299, 40);
            this.registerCreatePriority.Name = "registerCreatePriority";
            this.registerCreatePriority.Size = new System.Drawing.Size(92, 21);
            this.registerCreatePriority.TabIndex = 145;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(299, 24);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(41, 13);
            this.label2.TabIndex = 146;
            this.label2.Text = "Priority:";
            // 
            // registerCreateDataType
            // 
            this.registerCreateDataType.FormattingEnabled = true;
            this.registerCreateDataType.Items.AddRange(new object[] {
            "Unknown = 0",
            "Array = 1",
            "U8 = 2",
            "S8 = 3",
            "U16 = 4",
            "S16 = 5",
            "U32 = 6",
            "S32 = 7",
            "F32 = 8",
            "U64 = 9",
            "S64 = 10",
            "F64 = 11",
            "Ascii = 12",
            "Paramset = 13",
            "B8 = 14",
            "H8 = 15",
            "B16 = 16",
            "H16 = 17",
            "B32 = 18",
            "H32 = 19",
            "B64 = 20",
            "H64 = 21",
            "DateTime = 22"});
            this.registerCreateDataType.Location = new System.Drawing.Point(397, 39);
            this.registerCreateDataType.Name = "registerCreateDataType";
            this.registerCreateDataType.Size = new System.Drawing.Size(92, 21);
            this.registerCreateDataType.TabIndex = 147;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(394, 24);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(53, 13);
            this.label3.TabIndex = 148;
            this.label3.Text = "Datatype:";
            // 
            // label28
            // 
            this.label28.AutoSize = true;
            this.label28.Location = new System.Drawing.Point(92, 23);
            this.label28.Name = "label28";
            this.label28.Size = new System.Drawing.Size(55, 13);
            this.label28.TabIndex = 150;
            this.label28.Text = "Portname:";
            // 
            // deviceCreatePortname
            // 
            this.deviceCreatePortname.Location = new System.Drawing.Point(95, 39);
            this.deviceCreatePortname.Name = "deviceCreatePortname";
            this.deviceCreatePortname.Size = new System.Drawing.Size(102, 20);
            this.deviceCreatePortname.TabIndex = 149;
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(92, 23);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(55, 13);
            this.label4.TabIndex = 152;
            this.label4.Text = "Portname:";
            // 
            // registerCreatePortname
            // 
            this.registerCreatePortname.Location = new System.Drawing.Point(95, 39);
            this.registerCreatePortname.Name = "registerCreatePortname";
            this.registerCreatePortname.Size = new System.Drawing.Size(102, 20);
            this.registerCreatePortname.TabIndex = 151;
            // 
            // setCallbackPtrPortInfo
            // 
            this.setCallbackPtrPortInfo.AutoSize = true;
            this.setCallbackPtrPortInfo.Location = new System.Drawing.Point(3, 3);
            this.setCallbackPtrPortInfo.Name = "setCallbackPtrPortInfo";
            this.setCallbackPtrPortInfo.Size = new System.Drawing.Size(112, 17);
            this.setCallbackPtrPortInfo.TabIndex = 153;
            this.setCallbackPtrPortInfo.Text = "PortInfo Callbacks";
            this.setCallbackPtrPortInfo.UseVisualStyleBackColor = true;
            this.setCallbackPtrPortInfo.CheckedChanged += new System.EventHandler(this.setCallbackPtrPortInfo_CheckedChanged);
            // 
            // setCallbackPtrDeviceInfo
            // 
            this.setCallbackPtrDeviceInfo.AutoSize = true;
            this.setCallbackPtrDeviceInfo.Location = new System.Drawing.Point(3, 3);
            this.setCallbackPtrDeviceInfo.Name = "setCallbackPtrDeviceInfo";
            this.setCallbackPtrDeviceInfo.Size = new System.Drawing.Size(127, 17);
            this.setCallbackPtrDeviceInfo.TabIndex = 155;
            this.setCallbackPtrDeviceInfo.Text = "DeviceInfo Callbacks";
            this.setCallbackPtrDeviceInfo.UseVisualStyleBackColor = true;
            this.setCallbackPtrDeviceInfo.CheckedChanged += new System.EventHandler(this.setCallbackPtrDeviceInfo_CheckedChanged);
            // 
            // panel1
            // 
            this.panel1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.panel1.Controls.Add(this.setCallbackPtrDeviceInfo);
            this.panel1.Controls.Add(this.deviceCreate);
            this.panel1.Controls.Add(this.label25);
            this.panel1.Controls.Add(this.deviceCreateDevId);
            this.panel1.Controls.Add(this.deviceCreateWaitReady);
            this.panel1.Controls.Add(this.deviceCreatePortname);
            this.panel1.Controls.Add(this.label28);
            this.panel1.Location = new System.Drawing.Point(12, 146);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(500, 70);
            this.panel1.TabIndex = 156;
            // 
            // panel2
            // 
            this.panel2.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.panel2.Controls.Add(this.setCallbackPtrRegisterInfo);
            this.panel2.Controls.Add(this.label29);
            this.panel2.Controls.Add(this.registerCreateRegId);
            this.panel2.Controls.Add(this.label1);
            this.panel2.Controls.Add(this.registerCreateDevId);
            this.panel2.Controls.Add(this.label4);
            this.panel2.Controls.Add(this.registerCreate);
            this.panel2.Controls.Add(this.registerCreatePortname);
            this.panel2.Controls.Add(this.registerCreatePriority);
            this.panel2.Controls.Add(this.label3);
            this.panel2.Controls.Add(this.label2);
            this.panel2.Controls.Add(this.registerCreateDataType);
            this.panel2.Location = new System.Drawing.Point(12, 222);
            this.panel2.Name = "panel2";
            this.panel2.Size = new System.Drawing.Size(500, 71);
            this.panel2.TabIndex = 157;
            // 
            // setCallbackPtrRegisterInfo
            // 
            this.setCallbackPtrRegisterInfo.AutoSize = true;
            this.setCallbackPtrRegisterInfo.Location = new System.Drawing.Point(3, 3);
            this.setCallbackPtrRegisterInfo.Name = "setCallbackPtrRegisterInfo";
            this.setCallbackPtrRegisterInfo.Size = new System.Drawing.Size(132, 17);
            this.setCallbackPtrRegisterInfo.TabIndex = 158;
            this.setCallbackPtrRegisterInfo.Text = "RegisterInfo Callbacks";
            this.setCallbackPtrRegisterInfo.UseVisualStyleBackColor = true;
            this.setCallbackPtrRegisterInfo.CheckedChanged += new System.EventHandler(this.setCallbackPtrRegisterInfo_CheckedChanged);
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(92, 23);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(55, 13);
            this.label5.TabIndex = 158;
            this.label5.Text = "Portname:";
            // 
            // openPortsPortname
            // 
            this.openPortsPortname.Location = new System.Drawing.Point(95, 39);
            this.openPortsPortname.Name = "openPortsPortname";
            this.openPortsPortname.Size = new System.Drawing.Size(102, 20);
            this.openPortsPortname.TabIndex = 159;
            // 
            // closePortsPortname
            // 
            this.closePortsPortname.Location = new System.Drawing.Point(95, 68);
            this.closePortsPortname.Name = "closePortsPortname";
            this.closePortsPortname.Size = new System.Drawing.Size(102, 20);
            this.closePortsPortname.TabIndex = 160;
            // 
            // panel3
            // 
            this.panel3.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.panel3.Controls.Add(this.setCallbackPtrPortInfo);
            this.panel3.Controls.Add(this.closePortsPortname);
            this.panel3.Controls.Add(this.openPorts);
            this.panel3.Controls.Add(this.openPortsPortname);
            this.panel3.Controls.Add(this.closePorts);
            this.panel3.Controls.Add(this.label5);
            this.panel3.Controls.Add(this.CheckBoxAutoMode);
            this.panel3.Controls.Add(this.CheckBoxLiveMode);
            this.panel3.Location = new System.Drawing.Point(12, 41);
            this.panel3.Name = "panel3";
            this.panel3.Size = new System.Drawing.Size(500, 99);
            this.panel3.TabIndex = 161;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(836, 520);
            this.Controls.Add(this.panel3);
            this.Controls.Add(this.panel2);
            this.Controls.Add(this.panel1);
            this.Controls.Add(this.getOpenPorts);
            this.Controls.Add(this.StatusTextBox);
            this.Controls.Add(this.getAllPorts);
            this.Controls.Add(this.comboBoxPortname);
            this.Name = "Form1";
            this.Text = "Form1";
            ((System.ComponentModel.ISupportInitialize)(this.deviceCreateDevId)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.registerCreateRegId)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.registerCreateDevId)).EndInit();
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            this.panel2.ResumeLayout(false);
            this.panel2.PerformLayout();
            this.panel3.ResumeLayout(false);
            this.panel3.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.ComboBox comboBoxPortname;
        private System.Windows.Forms.Button getAllPorts;
        private System.Windows.Forms.Button openPorts;
        private System.Windows.Forms.Button closePorts;
        private System.Windows.Forms.TextBox StatusTextBox;
        private System.Windows.Forms.Button getOpenPorts;
        private System.Windows.Forms.CheckBox CheckBoxAutoMode;
        private System.Windows.Forms.CheckBox CheckBoxLiveMode;
        private System.Windows.Forms.Button deviceCreate;
        private System.Windows.Forms.NumericUpDown deviceCreateDevId;
        private System.Windows.Forms.Label label25;
        private System.Windows.Forms.NumericUpDown registerCreateRegId;
        private System.Windows.Forms.Label label29;
        private System.Windows.Forms.NumericUpDown registerCreateDevId;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Button registerCreate;
        private System.Windows.Forms.CheckBox deviceCreateWaitReady;
        private System.Windows.Forms.ComboBox registerCreatePriority;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.ComboBox registerCreateDataType;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label28;
        private System.Windows.Forms.TextBox deviceCreatePortname;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.TextBox registerCreatePortname;
        private System.Windows.Forms.CheckBox setCallbackPtrPortInfo;
        private System.Windows.Forms.CheckBox setCallbackPtrDeviceInfo;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Panel panel2;
        private System.Windows.Forms.CheckBox setCallbackPtrRegisterInfo;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.TextBox openPortsPortname;
        private System.Windows.Forms.TextBox closePortsPortname;
        private System.Windows.Forms.Panel panel3;
    }
}

