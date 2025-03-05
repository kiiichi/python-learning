namespace IB_Example_CS_Log
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
            this.btConnect = new System.Windows.Forms.Button();
            this.btRefresh = new System.Windows.Forms.Button();
            this.groupBoxDevData = new System.Windows.Forms.GroupBox();
            this.lbTypeHex = new System.Windows.Forms.Label();
            this.label10 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.btReadVersion = new System.Windows.Forms.Button();
            this.nudDeviceId = new System.Windows.Forms.NumericUpDown();
            this.lbVerStr = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.lbVerInt = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.groupBoxBinLog = new System.Windows.Forms.GroupBox();
            this.btAbortBinaryLog = new System.Windows.Forms.Button();
            this.btGetBinaryLog = new System.Windows.Forms.Button();
            this.nudBusyCount = new System.Windows.Forms.NumericUpDown();
            this.label8 = new System.Windows.Forms.Label();
            this.nudCurrentIndex = new System.Windows.Forms.NumericUpDown();
            this.nudTotalEntries = new System.Windows.Forms.NumericUpDown();
            this.label7 = new System.Windows.Forms.Label();
            this.label6 = new System.Windows.Forms.Label();
            this.btReadLogStatus = new System.Windows.Forms.Button();
            this.nudStartIndex = new System.Windows.Forms.NumericUpDown();
            this.label4 = new System.Windows.Forms.Label();
            this.btReadType = new System.Windows.Forms.Button();
            this.groupBoxComport = new System.Windows.Forms.GroupBox();
            this.groupBoxDevData.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.nudDeviceId)).BeginInit();
            this.groupBoxBinLog.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.nudBusyCount)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.nudCurrentIndex)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.nudTotalEntries)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.nudStartIndex)).BeginInit();
            this.groupBoxComport.SuspendLayout();
            this.SuspendLayout();
            // 
            // cbbDevices
            // 
            this.cbbDevices.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cbbDevices.FormattingEnabled = true;
            this.cbbDevices.Location = new System.Drawing.Point(38, 21);
            this.cbbDevices.Name = "cbbDevices";
            this.cbbDevices.Size = new System.Drawing.Size(121, 21);
            this.cbbDevices.TabIndex = 23;
            // 
            // btConnect
            // 
            this.btConnect.Location = new System.Drawing.Point(165, 19);
            this.btConnect.Name = "btConnect";
            this.btConnect.Size = new System.Drawing.Size(75, 23);
            this.btConnect.TabIndex = 21;
            this.btConnect.Text = "Connect";
            this.btConnect.UseVisualStyleBackColor = true;
            this.btConnect.Click += new System.EventHandler(this.btConnect_Click);
            // 
            // btRefresh
            // 
            this.btRefresh.BackgroundImage = global::IB_Example_CS_Log.Properties.Resources.modem_search_161;
            this.btRefresh.Location = new System.Drawing.Point(9, 19);
            this.btRefresh.Name = "btRefresh";
            this.btRefresh.Size = new System.Drawing.Size(23, 23);
            this.btRefresh.TabIndex = 20;
            this.btRefresh.UseVisualStyleBackColor = true;
            this.btRefresh.Click += new System.EventHandler(this.btRefresh_Click);
            // 
            // groupBoxDevData
            // 
            this.groupBoxDevData.Controls.Add(this.btReadType);
            this.groupBoxDevData.Controls.Add(this.lbTypeHex);
            this.groupBoxDevData.Controls.Add(this.label10);
            this.groupBoxDevData.Controls.Add(this.label5);
            this.groupBoxDevData.Controls.Add(this.btReadVersion);
            this.groupBoxDevData.Controls.Add(this.nudDeviceId);
            this.groupBoxDevData.Controls.Add(this.lbVerStr);
            this.groupBoxDevData.Controls.Add(this.label2);
            this.groupBoxDevData.Controls.Add(this.lbVerInt);
            this.groupBoxDevData.Controls.Add(this.label3);
            this.groupBoxDevData.Location = new System.Drawing.Point(12, 75);
            this.groupBoxDevData.Name = "groupBoxDevData";
            this.groupBoxDevData.Size = new System.Drawing.Size(555, 95);
            this.groupBoxDevData.TabIndex = 29;
            this.groupBoxDevData.TabStop = false;
            this.groupBoxDevData.Text = "Device data:";
            // 
            // lbTypeHex
            // 
            this.lbTypeHex.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.lbTypeHex.Location = new System.Drawing.Point(145, 29);
            this.lbTypeHex.Name = "lbTypeHex";
            this.lbTypeHex.Size = new System.Drawing.Size(57, 15);
            this.lbTypeHex.TabIndex = 29;
            this.lbTypeHex.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // label10
            // 
            this.label10.AutoSize = true;
            this.label10.Location = new System.Drawing.Point(148, 16);
            this.label10.Name = "label10";
            this.label10.Size = new System.Drawing.Size(72, 13);
            this.label10.TabIndex = 28;
            this.label10.Text = "Module Type:";
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
            // btReadVersion
            // 
            this.btReadVersion.AutoSize = true;
            this.btReadVersion.Location = new System.Drawing.Point(442, 63);
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
            // lbVerStr
            // 
            this.lbVerStr.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.lbVerStr.Location = new System.Drawing.Point(211, 67);
            this.lbVerStr.Name = "lbVerStr";
            this.lbVerStr.Size = new System.Drawing.Size(225, 15);
            this.lbVerStr.TabIndex = 24;
            this.lbVerStr.Text = "Unknown";
            this.lbVerStr.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(148, 54);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(54, 13);
            this.label2.TabIndex = 21;
            this.label2.Text = "FW Vers.:";
            // 
            // lbVerInt
            // 
            this.lbVerInt.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.lbVerInt.Location = new System.Drawing.Point(145, 67);
            this.lbVerInt.Name = "lbVerInt";
            this.lbVerInt.Size = new System.Drawing.Size(57, 15);
            this.lbVerInt.TabIndex = 23;
            this.lbVerInt.Text = "0";
            this.lbVerInt.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(208, 54);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(117, 13);
            this.label3.TabIndex = 22;
            this.label3.Text = "Firmware version string:";
            // 
            // groupBoxBinLog
            // 
            this.groupBoxBinLog.Controls.Add(this.btAbortBinaryLog);
            this.groupBoxBinLog.Controls.Add(this.btGetBinaryLog);
            this.groupBoxBinLog.Controls.Add(this.nudBusyCount);
            this.groupBoxBinLog.Controls.Add(this.label8);
            this.groupBoxBinLog.Controls.Add(this.nudCurrentIndex);
            this.groupBoxBinLog.Controls.Add(this.nudTotalEntries);
            this.groupBoxBinLog.Controls.Add(this.label7);
            this.groupBoxBinLog.Controls.Add(this.label6);
            this.groupBoxBinLog.Controls.Add(this.btReadLogStatus);
            this.groupBoxBinLog.Controls.Add(this.nudStartIndex);
            this.groupBoxBinLog.Controls.Add(this.label4);
            this.groupBoxBinLog.Location = new System.Drawing.Point(12, 176);
            this.groupBoxBinLog.Name = "groupBoxBinLog";
            this.groupBoxBinLog.Size = new System.Drawing.Size(555, 117);
            this.groupBoxBinLog.TabIndex = 30;
            this.groupBoxBinLog.TabStop = false;
            this.groupBoxBinLog.Text = "Binary Log";
            // 
            // btAbortBinaryLog
            // 
            this.btAbortBinaryLog.Enabled = false;
            this.btAbortBinaryLog.Location = new System.Drawing.Point(437, 85);
            this.btAbortBinaryLog.Name = "btAbortBinaryLog";
            this.btAbortBinaryLog.Size = new System.Drawing.Size(112, 23);
            this.btAbortBinaryLog.TabIndex = 10;
            this.btAbortBinaryLog.Text = "Abort";
            this.btAbortBinaryLog.UseVisualStyleBackColor = true;
            this.btAbortBinaryLog.Click += new System.EventHandler(this.btAbortBinaryLog_Click);
            // 
            // btGetBinaryLog
            // 
            this.btGetBinaryLog.Enabled = false;
            this.btGetBinaryLog.Location = new System.Drawing.Point(437, 55);
            this.btGetBinaryLog.Name = "btGetBinaryLog";
            this.btGetBinaryLog.Size = new System.Drawing.Size(112, 23);
            this.btGetBinaryLog.TabIndex = 9;
            this.btGetBinaryLog.Text = "Download Log";
            this.btGetBinaryLog.UseVisualStyleBackColor = true;
            this.btGetBinaryLog.Click += new System.EventHandler(this.btGetBinaryLog_Click);
            // 
            // nudBusyCount
            // 
            this.nudBusyCount.Location = new System.Drawing.Point(285, 58);
            this.nudBusyCount.Maximum = new decimal(new int[] {
            -1,
            0,
            0,
            0});
            this.nudBusyCount.Name = "nudBusyCount";
            this.nudBusyCount.ReadOnly = true;
            this.nudBusyCount.Size = new System.Drawing.Size(120, 20);
            this.nudBusyCount.TabIndex = 8;
            // 
            // label8
            // 
            this.label8.AutoSize = true;
            this.label8.Location = new System.Drawing.Point(214, 60);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(63, 13);
            this.label8.TabIndex = 7;
            this.label8.Text = "Busy count:";
            // 
            // nudCurrentIndex
            // 
            this.nudCurrentIndex.Location = new System.Drawing.Point(85, 58);
            this.nudCurrentIndex.Maximum = new decimal(new int[] {
            -1,
            0,
            0,
            0});
            this.nudCurrentIndex.Name = "nudCurrentIndex";
            this.nudCurrentIndex.ReadOnly = true;
            this.nudCurrentIndex.Size = new System.Drawing.Size(120, 20);
            this.nudCurrentIndex.TabIndex = 6;
            // 
            // nudTotalEntries
            // 
            this.nudTotalEntries.Location = new System.Drawing.Point(285, 22);
            this.nudTotalEntries.Maximum = new decimal(new int[] {
            -1,
            0,
            0,
            0});
            this.nudTotalEntries.Name = "nudTotalEntries";
            this.nudTotalEntries.ReadOnly = true;
            this.nudTotalEntries.Size = new System.Drawing.Size(120, 20);
            this.nudTotalEntries.TabIndex = 5;
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(6, 60);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(72, 13);
            this.label7.TabIndex = 4;
            this.label7.Text = "Current index:";
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(211, 24);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(68, 13);
            this.label6.TabIndex = 3;
            this.label6.Text = "Total entries:";
            // 
            // btReadLogStatus
            // 
            this.btReadLogStatus.Location = new System.Drawing.Point(437, 19);
            this.btReadLogStatus.Name = "btReadLogStatus";
            this.btReadLogStatus.Size = new System.Drawing.Size(112, 23);
            this.btReadLogStatus.TabIndex = 2;
            this.btReadLogStatus.Text = "Read Log Status";
            this.btReadLogStatus.UseVisualStyleBackColor = true;
            this.btReadLogStatus.Click += new System.EventHandler(this.btReadLogStatus_Click);
            // 
            // nudStartIndex
            // 
            this.nudStartIndex.Location = new System.Drawing.Point(85, 22);
            this.nudStartIndex.Maximum = new decimal(new int[] {
            -1,
            0,
            0,
            0});
            this.nudStartIndex.Name = "nudStartIndex";
            this.nudStartIndex.Size = new System.Drawing.Size(120, 20);
            this.nudStartIndex.TabIndex = 1;
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(6, 24);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(61, 13);
            this.label4.TabIndex = 0;
            this.label4.Text = "Start Index:";
            // 
            // btReadType
            // 
            this.btReadType.AutoSize = true;
            this.btReadType.Location = new System.Drawing.Point(442, 24);
            this.btReadType.Name = "btReadType";
            this.btReadType.Size = new System.Drawing.Size(106, 23);
            this.btReadType.TabIndex = 30;
            this.btReadType.Text = "Read register 0x61";
            this.btReadType.UseVisualStyleBackColor = true;
            this.btReadType.Click += new System.EventHandler(this.btReadType_Click);
            // 
            // groupBoxComport
            // 
            this.groupBoxComport.Controls.Add(this.cbbDevices);
            this.groupBoxComport.Controls.Add(this.btRefresh);
            this.groupBoxComport.Controls.Add(this.btConnect);
            this.groupBoxComport.Location = new System.Drawing.Point(12, 12);
            this.groupBoxComport.Name = "groupBoxComport";
            this.groupBoxComport.Size = new System.Drawing.Size(555, 57);
            this.groupBoxComport.TabIndex = 31;
            this.groupBoxComport.TabStop = false;
            this.groupBoxComport.Text = "Communications port";
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(579, 343);
            this.Controls.Add(this.groupBoxComport);
            this.Controls.Add(this.groupBoxBinLog);
            this.Controls.Add(this.groupBoxDevData);
            this.Name = "MainForm";
            this.Text = "C# Interbus sample - Log download";
            this.groupBoxDevData.ResumeLayout(false);
            this.groupBoxDevData.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.nudDeviceId)).EndInit();
            this.groupBoxBinLog.ResumeLayout(false);
            this.groupBoxBinLog.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.nudBusyCount)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.nudCurrentIndex)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.nudTotalEntries)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.nudStartIndex)).EndInit();
            this.groupBoxComport.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.ComboBox cbbDevices;
        private System.Windows.Forms.Button btConnect;
        private System.Windows.Forms.Button btRefresh;
        private System.Windows.Forms.GroupBox groupBoxDevData;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Button btReadVersion;
        private System.Windows.Forms.NumericUpDown nudDeviceId;
        private System.Windows.Forms.Label lbVerStr;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label lbVerInt;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.GroupBox groupBoxBinLog;
        private System.Windows.Forms.NumericUpDown nudStartIndex;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.NumericUpDown nudTotalEntries;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.Button btReadLogStatus;
        private System.Windows.Forms.Button btGetBinaryLog;
        private System.Windows.Forms.NumericUpDown nudBusyCount;
        private System.Windows.Forms.Label label8;
        private System.Windows.Forms.NumericUpDown nudCurrentIndex;
        private System.Windows.Forms.Label lbTypeHex;
        private System.Windows.Forms.Label label10;
        private System.Windows.Forms.Button btAbortBinaryLog;
        private System.Windows.Forms.Button btReadType;
        private System.Windows.Forms.GroupBox groupBoxComport;
    }
}

