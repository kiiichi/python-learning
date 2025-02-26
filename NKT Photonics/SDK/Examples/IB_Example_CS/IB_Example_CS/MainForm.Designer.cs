namespace IB_Exampls_CS
{
    partial class MainForm
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
            this.cbbDevices = new System.Windows.Forms.ComboBox();
            this.label1 = new System.Windows.Forms.Label();
            this.btConnect = new System.Windows.Forms.Button();
            this.btRefresh = new System.Windows.Forms.Button();
            this.label2 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.lbVerInt = new System.Windows.Forms.Label();
            this.lbVerStr = new System.Windows.Forms.Label();
            this.btReadVersion = new System.Windows.Forms.Button();
            this.nudDeviceId = new System.Windows.Forms.NumericUpDown();
            this.label5 = new System.Windows.Forms.Label();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.groupBox3 = new System.Windows.Forms.GroupBox();
            this.btWriteOnOff = new System.Windows.Forms.Button();
            this.nudPwrOnOff = new System.Windows.Forms.NumericUpDown();
            this.btReadOnOff = new System.Windows.Forms.Button();
            this.lbPwrOnOffStatus = new System.Windows.Forms.Label();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.btSetPowerlevel = new System.Windows.Forms.Button();
            this.btReadPowerlevel = new System.Windows.Forms.Button();
            this.lbPowerlevelStatus = new System.Windows.Forms.Label();
            this.lbPowerlevelSetting = new System.Windows.Forms.Label();
            this.trkbarPowerlevel = new System.Windows.Forms.TrackBar();
            this.probarPowerlevel = new System.Windows.Forms.ProgressBar();
            ((System.ComponentModel.ISupportInitialize)(this.nudDeviceId)).BeginInit();
            this.groupBox1.SuspendLayout();
            this.groupBox3.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.nudPwrOnOff)).BeginInit();
            this.groupBox2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.trkbarPowerlevel)).BeginInit();
            this.SuspendLayout();
            // 
            // cbbDevices
            // 
            this.cbbDevices.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cbbDevices.FormattingEnabled = true;
            this.cbbDevices.Location = new System.Drawing.Point(96, 6);
            this.cbbDevices.Name = "cbbDevices";
            this.cbbDevices.Size = new System.Drawing.Size(121, 21);
            this.cbbDevices.TabIndex = 19;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(12, 9);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(49, 13);
            this.label1.TabIndex = 18;
            this.label1.Text = "Comport:";
            // 
            // btConnect
            // 
            this.btConnect.Location = new System.Drawing.Point(223, 4);
            this.btConnect.Name = "btConnect";
            this.btConnect.Size = new System.Drawing.Size(75, 23);
            this.btConnect.TabIndex = 17;
            this.btConnect.Text = "Connect";
            this.btConnect.UseVisualStyleBackColor = true;
            this.btConnect.Click += new System.EventHandler(this.btConnect_Click);
            // 
            // btRefresh
            // 
            this.btRefresh.BackgroundImage = IB_Example_CS.Properties.Resources.modem_search_16;
            this.btRefresh.Location = new System.Drawing.Point(67, 4);
            this.btRefresh.Name = "btRefresh";
            this.btRefresh.Size = new System.Drawing.Size(23, 23);
            this.btRefresh.TabIndex = 16;
            this.btRefresh.UseVisualStyleBackColor = true;
            this.btRefresh.Click += new System.EventHandler(this.btRefresh_Click);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(152, 11);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(45, 13);
            this.label2.TabIndex = 21;
            this.label2.Text = "Version:";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(203, 11);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(73, 13);
            this.label3.TabIndex = 22;
            this.label3.Text = "Version string:";
            // 
            // lbVerInt
            // 
            this.lbVerInt.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.lbVerInt.Location = new System.Drawing.Point(152, 24);
            this.lbVerInt.Name = "lbVerInt";
            this.lbVerInt.Size = new System.Drawing.Size(45, 15);
            this.lbVerInt.TabIndex = 23;
            this.lbVerInt.Text = "0";
            this.lbVerInt.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // lbVerStr
            // 
            this.lbVerStr.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.lbVerStr.Location = new System.Drawing.Point(206, 24);
            this.lbVerStr.Name = "lbVerStr";
            this.lbVerStr.Size = new System.Drawing.Size(225, 15);
            this.lbVerStr.TabIndex = 24;
            this.lbVerStr.Text = "Unknown";
            this.lbVerStr.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // btReadVersion
            // 
            this.btReadVersion.AutoSize = true;
            this.btReadVersion.Location = new System.Drawing.Point(437, 16);
            this.btReadVersion.Name = "btReadVersion";
            this.btReadVersion.Size = new System.Drawing.Size(106, 23);
            this.btReadVersion.TabIndex = 25;
            this.btReadVersion.Text = "Read register 0x64";
            this.btReadVersion.UseVisualStyleBackColor = true;
            this.btReadVersion.Click += new System.EventHandler(this.btReadVersion_Click);
            // 
            // nudDeviceId
            // 
            this.nudDeviceId.Location = new System.Drawing.Point(66, 19);
            this.nudDeviceId.Maximum = new decimal(new int[] {
            40,
            0,
            0,
            0});
            this.nudDeviceId.Minimum = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.nudDeviceId.Name = "nudDeviceId";
            this.nudDeviceId.Size = new System.Drawing.Size(38, 20);
            this.nudDeviceId.TabIndex = 26;
            this.nudDeviceId.Value = new decimal(new int[] {
            15,
            0,
            0,
            0});
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(12, 24);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(48, 13);
            this.label5.TabIndex = 27;
            this.label5.Text = "Address:";
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.groupBox3);
            this.groupBox1.Controls.Add(this.groupBox2);
            this.groupBox1.Controls.Add(this.label5);
            this.groupBox1.Controls.Add(this.btReadVersion);
            this.groupBox1.Controls.Add(this.nudDeviceId);
            this.groupBox1.Controls.Add(this.lbVerStr);
            this.groupBox1.Controls.Add(this.label2);
            this.groupBox1.Controls.Add(this.lbVerInt);
            this.groupBox1.Controls.Add(this.label3);
            this.groupBox1.Location = new System.Drawing.Point(12, 33);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(570, 254);
            this.groupBox1.TabIndex = 28;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Device data:";
            // 
            // groupBox3
            // 
            this.groupBox3.Controls.Add(this.btWriteOnOff);
            this.groupBox3.Controls.Add(this.nudPwrOnOff);
            this.groupBox3.Controls.Add(this.btReadOnOff);
            this.groupBox3.Controls.Add(this.lbPwrOnOffStatus);
            this.groupBox3.Location = new System.Drawing.Point(6, 59);
            this.groupBox3.Name = "groupBox3";
            this.groupBox3.Size = new System.Drawing.Size(164, 78);
            this.groupBox3.TabIndex = 33;
            this.groupBox3.TabStop = false;
            this.groupBox3.Text = "On/Off:";
            // 
            // btWriteOnOff
            // 
            this.btWriteOnOff.AutoSize = true;
            this.btWriteOnOff.Location = new System.Drawing.Point(47, 47);
            this.btWriteOnOff.Name = "btWriteOnOff";
            this.btWriteOnOff.Size = new System.Drawing.Size(106, 23);
            this.btWriteOnOff.TabIndex = 39;
            this.btWriteOnOff.Text = "Write register 0x30";
            this.btWriteOnOff.UseVisualStyleBackColor = true;
            this.btWriteOnOff.Click += new System.EventHandler(this.btWriteOnOff_Click);
            // 
            // nudPwrOnOff
            // 
            this.nudPwrOnOff.Location = new System.Drawing.Point(6, 50);
            this.nudPwrOnOff.Maximum = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.nudPwrOnOff.Name = "nudPwrOnOff";
            this.nudPwrOnOff.Size = new System.Drawing.Size(35, 20);
            this.nudPwrOnOff.TabIndex = 38;
            // 
            // btReadOnOff
            // 
            this.btReadOnOff.AutoSize = true;
            this.btReadOnOff.Location = new System.Drawing.Point(47, 12);
            this.btReadOnOff.Name = "btReadOnOff";
            this.btReadOnOff.Size = new System.Drawing.Size(106, 23);
            this.btReadOnOff.TabIndex = 37;
            this.btReadOnOff.Text = "Read register 0x30";
            this.btReadOnOff.UseVisualStyleBackColor = true;
            this.btReadOnOff.Click += new System.EventHandler(this.btReadOnOffStatus_Click);
            // 
            // lbPwrOnOffStatus
            // 
            this.lbPwrOnOffStatus.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.lbPwrOnOffStatus.Location = new System.Drawing.Point(6, 16);
            this.lbPwrOnOffStatus.Name = "lbPwrOnOffStatus";
            this.lbPwrOnOffStatus.Size = new System.Drawing.Size(35, 15);
            this.lbPwrOnOffStatus.TabIndex = 36;
            this.lbPwrOnOffStatus.Text = "0";
            this.lbPwrOnOffStatus.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.btSetPowerlevel);
            this.groupBox2.Controls.Add(this.btReadPowerlevel);
            this.groupBox2.Controls.Add(this.lbPowerlevelStatus);
            this.groupBox2.Controls.Add(this.lbPowerlevelSetting);
            this.groupBox2.Controls.Add(this.trkbarPowerlevel);
            this.groupBox2.Controls.Add(this.probarPowerlevel);
            this.groupBox2.Location = new System.Drawing.Point(6, 143);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(541, 103);
            this.groupBox2.TabIndex = 31;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "Power level:";
            // 
            // btSetPowerlevel
            // 
            this.btSetPowerlevel.AutoSize = true;
            this.btSetPowerlevel.Location = new System.Drawing.Point(428, 29);
            this.btSetPowerlevel.Name = "btSetPowerlevel";
            this.btSetPowerlevel.Size = new System.Drawing.Size(106, 23);
            this.btSetPowerlevel.TabIndex = 35;
            this.btSetPowerlevel.Text = "Write register 0x37";
            this.btSetPowerlevel.UseVisualStyleBackColor = true;
            this.btSetPowerlevel.Click += new System.EventHandler(this.btSetPowerlevel_Click);
            // 
            // btReadPowerlevel
            // 
            this.btReadPowerlevel.AutoSize = true;
            this.btReadPowerlevel.Location = new System.Drawing.Point(428, 70);
            this.btReadPowerlevel.Name = "btReadPowerlevel";
            this.btReadPowerlevel.Size = new System.Drawing.Size(106, 23);
            this.btReadPowerlevel.TabIndex = 34;
            this.btReadPowerlevel.Text = "Read register 0x37";
            this.btReadPowerlevel.UseVisualStyleBackColor = true;
            this.btReadPowerlevel.Click += new System.EventHandler(this.btReadPowerlevel_Click);
            // 
            // lbPowerlevelStatus
            // 
            this.lbPowerlevelStatus.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.lbPowerlevelStatus.Location = new System.Drawing.Point(377, 78);
            this.lbPowerlevelStatus.Name = "lbPowerlevelStatus";
            this.lbPowerlevelStatus.Size = new System.Drawing.Size(45, 15);
            this.lbPowerlevelStatus.TabIndex = 33;
            this.lbPowerlevelStatus.Text = "0";
            this.lbPowerlevelStatus.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // lbPowerlevelSetting
            // 
            this.lbPowerlevelSetting.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.lbPowerlevelSetting.Location = new System.Drawing.Point(377, 37);
            this.lbPowerlevelSetting.Name = "lbPowerlevelSetting";
            this.lbPowerlevelSetting.Size = new System.Drawing.Size(45, 15);
            this.lbPowerlevelSetting.TabIndex = 32;
            this.lbPowerlevelSetting.Text = "0";
            this.lbPowerlevelSetting.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // trkbarPowerlevel
            // 
            this.trkbarPowerlevel.Location = new System.Drawing.Point(6, 19);
            this.trkbarPowerlevel.Maximum = 1000;
            this.trkbarPowerlevel.Name = "trkbarPowerlevel";
            this.trkbarPowerlevel.Size = new System.Drawing.Size(365, 45);
            this.trkbarPowerlevel.TabIndex = 28;
            this.trkbarPowerlevel.ValueChanged += new System.EventHandler(this.trkbarPowerlevel_ValueChanged);
            // 
            // probarPowerlevel
            // 
            this.probarPowerlevel.Location = new System.Drawing.Point(6, 70);
            this.probarPowerlevel.Maximum = 1000;
            this.probarPowerlevel.Name = "probarPowerlevel";
            this.probarPowerlevel.Size = new System.Drawing.Size(365, 23);
            this.probarPowerlevel.TabIndex = 29;
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(595, 299);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.cbbDevices);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.btConnect);
            this.Controls.Add(this.btRefresh);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Name = "MainForm";
            this.Text = "C# Interbus sample";
            ((System.ComponentModel.ISupportInitialize)(this.nudDeviceId)).EndInit();
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.groupBox3.ResumeLayout(false);
            this.groupBox3.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.nudPwrOnOff)).EndInit();
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.trkbarPowerlevel)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.ComboBox cbbDevices;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Button btConnect;
        private System.Windows.Forms.Button btRefresh;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label lbVerInt;
        private System.Windows.Forms.Label lbVerStr;
        private System.Windows.Forms.Button btReadVersion;
        private System.Windows.Forms.NumericUpDown nudDeviceId;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.TrackBar trkbarPowerlevel;
        private System.Windows.Forms.ProgressBar probarPowerlevel;
        private System.Windows.Forms.Button btSetPowerlevel;
        private System.Windows.Forms.Button btReadPowerlevel;
        private System.Windows.Forms.Label lbPowerlevelStatus;
        private System.Windows.Forms.Label lbPowerlevelSetting;
        private System.Windows.Forms.GroupBox groupBox3;
        private System.Windows.Forms.Button btWriteOnOff;
        private System.Windows.Forms.NumericUpDown nudPwrOnOff;
        private System.Windows.Forms.Button btReadOnOff;
        private System.Windows.Forms.Label lbPwrOnOffStatus;
    }
}

