#pragma once

namespace IBSamplecpp {

	using namespace System;
	using namespace System::ComponentModel;
	using namespace System::Collections;
	using namespace System::Windows::Forms;
	using namespace System::Data;
	using namespace System::Drawing;

	using namespace System::Text;
	using namespace System::IO::Ports;
	using namespace System::Configuration;

	/// <summary>
	/// Summary for Form1
	/// </summary>
	public ref class Form1 : public System::Windows::Forms::Form
	{
	private: SerialPort^ comport;

	public:
		Form1(void)
		{
			InitializeComponent();

			//InterbusFunc::masterId = 66;
			//InterbusFunc::timeout_mS = 50;
			comport = gcnew SerialPort();

			this->trkbarPowerlevel->Minimum = 0;
			this->trkbarPowerlevel->Maximum = 1000;

			RescanPorts();

		}

	protected:
		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		~Form1()
		{
			if (components)
			{
				delete components;
			}
			if (comport)
				delete comport;
		}
	private: System::Windows::Forms::GroupBox^  groupBox1;
	protected: 
	private: System::Windows::Forms::GroupBox^  groupBox3;
	private: System::Windows::Forms::Button^  btWriteOnOff;
	private: System::Windows::Forms::NumericUpDown^  nudPwrOnOff;
	private: System::Windows::Forms::Button^  btReadOnOff;
	private: System::Windows::Forms::Label^  lbPwrOnOffStatus;
	private: System::Windows::Forms::GroupBox^  groupBox2;
	private: System::Windows::Forms::Button^  btSetPowerlevel;
	private: System::Windows::Forms::Button^  btReadPowerlevel;
	private: System::Windows::Forms::Label^  lbPowerlevelStatus;
	private: System::Windows::Forms::Label^  lbPowerlevelSetting;
	private: System::Windows::Forms::TrackBar^  trkbarPowerlevel;
	private: System::Windows::Forms::ProgressBar^  probarPowerlevel;
	private: System::Windows::Forms::Label^  label5;
	private: System::Windows::Forms::Button^  btReadVersion;
	private: System::Windows::Forms::NumericUpDown^  nudDeviceId;
	private: System::Windows::Forms::Label^  lbVerStr;
	private: System::Windows::Forms::Label^  label2;
	private: System::Windows::Forms::Label^  lbVerInt;
	private: System::Windows::Forms::Label^  label3;
	private: System::Windows::Forms::ComboBox^  cbbDevices;
	private: System::Windows::Forms::Label^  label1;
	private: System::Windows::Forms::Button^  btConnect;
	private: System::Windows::Forms::Button^  btRefresh;

	private:
		/// <summary>
		/// Required designer variable.
		/// </summary>
		System::ComponentModel::Container ^components;

#pragma region Windows Form Designer generated code
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		void InitializeComponent(void)
		{
			System::ComponentModel::ComponentResourceManager^  resources = (gcnew System::ComponentModel::ComponentResourceManager(Form1::typeid));
			this->groupBox1 = (gcnew System::Windows::Forms::GroupBox());
			this->groupBox3 = (gcnew System::Windows::Forms::GroupBox());
			this->btWriteOnOff = (gcnew System::Windows::Forms::Button());
			this->nudPwrOnOff = (gcnew System::Windows::Forms::NumericUpDown());
			this->btReadOnOff = (gcnew System::Windows::Forms::Button());
			this->lbPwrOnOffStatus = (gcnew System::Windows::Forms::Label());
			this->groupBox2 = (gcnew System::Windows::Forms::GroupBox());
			this->btSetPowerlevel = (gcnew System::Windows::Forms::Button());
			this->btReadPowerlevel = (gcnew System::Windows::Forms::Button());
			this->lbPowerlevelStatus = (gcnew System::Windows::Forms::Label());
			this->lbPowerlevelSetting = (gcnew System::Windows::Forms::Label());
			this->trkbarPowerlevel = (gcnew System::Windows::Forms::TrackBar());
			this->probarPowerlevel = (gcnew System::Windows::Forms::ProgressBar());
			this->label5 = (gcnew System::Windows::Forms::Label());
			this->btReadVersion = (gcnew System::Windows::Forms::Button());
			this->nudDeviceId = (gcnew System::Windows::Forms::NumericUpDown());
			this->lbVerStr = (gcnew System::Windows::Forms::Label());
			this->label2 = (gcnew System::Windows::Forms::Label());
			this->lbVerInt = (gcnew System::Windows::Forms::Label());
			this->label3 = (gcnew System::Windows::Forms::Label());
			this->cbbDevices = (gcnew System::Windows::Forms::ComboBox());
			this->label1 = (gcnew System::Windows::Forms::Label());
			this->btConnect = (gcnew System::Windows::Forms::Button());
			this->btRefresh = (gcnew System::Windows::Forms::Button());
			this->groupBox1->SuspendLayout();
			this->groupBox3->SuspendLayout();
			(cli::safe_cast<System::ComponentModel::ISupportInitialize^>(this->nudPwrOnOff))->BeginInit();
			this->groupBox2->SuspendLayout();
			(cli::safe_cast<System::ComponentModel::ISupportInitialize^>(this->trkbarPowerlevel))->BeginInit();
			(cli::safe_cast<System::ComponentModel::ISupportInitialize^>(this->nudDeviceId))->BeginInit();
			this->SuspendLayout();
			// 
			// groupBox1
			// 
			this->groupBox1->Controls->Add(this->groupBox3);
			this->groupBox1->Controls->Add(this->groupBox2);
			this->groupBox1->Controls->Add(this->label5);
			this->groupBox1->Controls->Add(this->btReadVersion);
			this->groupBox1->Controls->Add(this->nudDeviceId);
			this->groupBox1->Controls->Add(this->lbVerStr);
			this->groupBox1->Controls->Add(this->label2);
			this->groupBox1->Controls->Add(this->lbVerInt);
			this->groupBox1->Controls->Add(this->label3);
			this->groupBox1->Location = System::Drawing::Point(12, 33);
			this->groupBox1->Name = L"groupBox1";
			this->groupBox1->Size = System::Drawing::Size(570, 254);
			this->groupBox1->TabIndex = 33;
			this->groupBox1->TabStop = false;
			this->groupBox1->Text = L"Device data:";
			// 
			// groupBox3
			// 
			this->groupBox3->Controls->Add(this->btWriteOnOff);
			this->groupBox3->Controls->Add(this->nudPwrOnOff);
			this->groupBox3->Controls->Add(this->btReadOnOff);
			this->groupBox3->Controls->Add(this->lbPwrOnOffStatus);
			this->groupBox3->Location = System::Drawing::Point(6, 59);
			this->groupBox3->Name = L"groupBox3";
			this->groupBox3->Size = System::Drawing::Size(164, 78);
			this->groupBox3->TabIndex = 33;
			this->groupBox3->TabStop = false;
			this->groupBox3->Text = L"On/Off:";
			// 
			// btWriteOnOff
			// 
			this->btWriteOnOff->AutoSize = true;
			this->btWriteOnOff->Location = System::Drawing::Point(47, 47);
			this->btWriteOnOff->Name = L"btWriteOnOff";
			this->btWriteOnOff->Size = System::Drawing::Size(106, 23);
			this->btWriteOnOff->TabIndex = 39;
			this->btWriteOnOff->Text = L"Write register 0x30";
			this->btWriteOnOff->UseVisualStyleBackColor = true;
			this->btWriteOnOff->Click += gcnew System::EventHandler(this, &Form1::btWriteOnOff_Click);
			// 
			// nudPwrOnOff
			// 
			this->nudPwrOnOff->Location = System::Drawing::Point(6, 50);
			this->nudPwrOnOff->Maximum = System::Decimal(gcnew cli::array< System::Int32 >(4) { 3, 0, 0, 0 });
			this->nudPwrOnOff->Name = L"nudPwrOnOff";
			this->nudPwrOnOff->Size = System::Drawing::Size(35, 20);
			this->nudPwrOnOff->TabIndex = 38;
			// 
			// btReadOnOff
			// 
			this->btReadOnOff->AutoSize = true;
			this->btReadOnOff->Location = System::Drawing::Point(47, 12);
			this->btReadOnOff->Name = L"btReadOnOff";
			this->btReadOnOff->Size = System::Drawing::Size(106, 23);
			this->btReadOnOff->TabIndex = 37;
			this->btReadOnOff->Text = L"Read register 0x30";
			this->btReadOnOff->UseVisualStyleBackColor = true;
			this->btReadOnOff->Click += gcnew System::EventHandler(this, &Form1::btReadOnOff_Click);
			// 
			// lbPwrOnOffStatus
			// 
			this->lbPwrOnOffStatus->BorderStyle = System::Windows::Forms::BorderStyle::FixedSingle;
			this->lbPwrOnOffStatus->Location = System::Drawing::Point(6, 16);
			this->lbPwrOnOffStatus->Name = L"lbPwrOnOffStatus";
			this->lbPwrOnOffStatus->Size = System::Drawing::Size(35, 15);
			this->lbPwrOnOffStatus->TabIndex = 36;
			this->lbPwrOnOffStatus->Text = L"0";
			this->lbPwrOnOffStatus->TextAlign = System::Drawing::ContentAlignment::MiddleCenter;
			// 
			// groupBox2
			// 
			this->groupBox2->Controls->Add(this->btSetPowerlevel);
			this->groupBox2->Controls->Add(this->btReadPowerlevel);
			this->groupBox2->Controls->Add(this->lbPowerlevelStatus);
			this->groupBox2->Controls->Add(this->lbPowerlevelSetting);
			this->groupBox2->Controls->Add(this->trkbarPowerlevel);
			this->groupBox2->Controls->Add(this->probarPowerlevel);
			this->groupBox2->Location = System::Drawing::Point(6, 143);
			this->groupBox2->Name = L"groupBox2";
			this->groupBox2->Size = System::Drawing::Size(541, 103);
			this->groupBox2->TabIndex = 31;
			this->groupBox2->TabStop = false;
			this->groupBox2->Text = L"Power level:";
			// 
			// btSetPowerlevel
			// 
			this->btSetPowerlevel->AutoSize = true;
			this->btSetPowerlevel->Location = System::Drawing::Point(428, 29);
			this->btSetPowerlevel->Name = L"btSetPowerlevel";
			this->btSetPowerlevel->Size = System::Drawing::Size(106, 23);
			this->btSetPowerlevel->TabIndex = 35;
			this->btSetPowerlevel->Text = L"Write register 0x37";
			this->btSetPowerlevel->UseVisualStyleBackColor = true;
			this->btSetPowerlevel->Click += gcnew System::EventHandler(this, &Form1::btSetPowerlevel_Click);
			// 
			// btReadPowerlevel
			// 
			this->btReadPowerlevel->AutoSize = true;
			this->btReadPowerlevel->Location = System::Drawing::Point(428, 70);
			this->btReadPowerlevel->Name = L"btReadPowerlevel";
			this->btReadPowerlevel->Size = System::Drawing::Size(106, 23);
			this->btReadPowerlevel->TabIndex = 34;
			this->btReadPowerlevel->Text = L"Read register 0x37";
			this->btReadPowerlevel->UseVisualStyleBackColor = true;
			this->btReadPowerlevel->Click += gcnew System::EventHandler(this, &Form1::btReadPowerlevel_Click);
			// 
			// lbPowerlevelStatus
			// 
			this->lbPowerlevelStatus->BorderStyle = System::Windows::Forms::BorderStyle::FixedSingle;
			this->lbPowerlevelStatus->Location = System::Drawing::Point(377, 78);
			this->lbPowerlevelStatus->Name = L"lbPowerlevelStatus";
			this->lbPowerlevelStatus->Size = System::Drawing::Size(45, 15);
			this->lbPowerlevelStatus->TabIndex = 33;
			this->lbPowerlevelStatus->Text = L"0";
			this->lbPowerlevelStatus->TextAlign = System::Drawing::ContentAlignment::MiddleRight;
			// 
			// lbPowerlevelSetting
			// 
			this->lbPowerlevelSetting->BorderStyle = System::Windows::Forms::BorderStyle::FixedSingle;
			this->lbPowerlevelSetting->Location = System::Drawing::Point(377, 37);
			this->lbPowerlevelSetting->Name = L"lbPowerlevelSetting";
			this->lbPowerlevelSetting->Size = System::Drawing::Size(45, 15);
			this->lbPowerlevelSetting->TabIndex = 32;
			this->lbPowerlevelSetting->Text = L"0";
			this->lbPowerlevelSetting->TextAlign = System::Drawing::ContentAlignment::MiddleRight;
			// 
			// trkbarPowerlevel
			// 
			this->trkbarPowerlevel->Location = System::Drawing::Point(6, 19);
			this->trkbarPowerlevel->Maximum = 1000;
			this->trkbarPowerlevel->Name = L"trkbarPowerlevel";
			this->trkbarPowerlevel->Size = System::Drawing::Size(365, 45);
			this->trkbarPowerlevel->TabIndex = 28;
			this->trkbarPowerlevel->ValueChanged += gcnew System::EventHandler(this, &Form1::trkbarPowerlevel_ValueChanged);
			// 
			// probarPowerlevel
			// 
			this->probarPowerlevel->Location = System::Drawing::Point(6, 70);
			this->probarPowerlevel->Maximum = 1000;
			this->probarPowerlevel->Name = L"probarPowerlevel";
			this->probarPowerlevel->Size = System::Drawing::Size(365, 23);
			this->probarPowerlevel->TabIndex = 29;
			// 
			// label5
			// 
			this->label5->AutoSize = true;
			this->label5->Location = System::Drawing::Point(12, 24);
			this->label5->Name = L"label5";
			this->label5->Size = System::Drawing::Size(48, 13);
			this->label5->TabIndex = 27;
			this->label5->Text = L"Address:";
			// 
			// btReadVersion
			// 
			this->btReadVersion->AutoSize = true;
			this->btReadVersion->Location = System::Drawing::Point(437, 16);
			this->btReadVersion->Name = L"btReadVersion";
			this->btReadVersion->Size = System::Drawing::Size(106, 23);
			this->btReadVersion->TabIndex = 25;
			this->btReadVersion->Text = L"Read register 0x64";
			this->btReadVersion->UseVisualStyleBackColor = true;
			this->btReadVersion->Click += gcnew System::EventHandler(this, &Form1::btReadVersion_Click);
			// 
			// nudDeviceId
			// 
			this->nudDeviceId->Location = System::Drawing::Point(66, 19);
			this->nudDeviceId->Maximum = System::Decimal(gcnew cli::array< System::Int32 >(4) { 40, 0, 0, 0 });
			this->nudDeviceId->Minimum = System::Decimal(gcnew cli::array< System::Int32 >(4) { 1, 0, 0, 0 });
			this->nudDeviceId->Name = L"nudDeviceId";
			this->nudDeviceId->Size = System::Drawing::Size(38, 20);
			this->nudDeviceId->TabIndex = 26;
			this->nudDeviceId->Value = System::Decimal(gcnew cli::array< System::Int32 >(4) { 15, 0, 0, 0 });
			// 
			// lbVerStr
			// 
			this->lbVerStr->BorderStyle = System::Windows::Forms::BorderStyle::FixedSingle;
			this->lbVerStr->Location = System::Drawing::Point(206, 24);
			this->lbVerStr->Name = L"lbVerStr";
			this->lbVerStr->Size = System::Drawing::Size(225, 15);
			this->lbVerStr->TabIndex = 24;
			this->lbVerStr->Text = L"Unknown";
			this->lbVerStr->TextAlign = System::Drawing::ContentAlignment::MiddleLeft;
			// 
			// label2
			// 
			this->label2->AutoSize = true;
			this->label2->Location = System::Drawing::Point(152, 11);
			this->label2->Name = L"label2";
			this->label2->Size = System::Drawing::Size(45, 13);
			this->label2->TabIndex = 21;
			this->label2->Text = L"Version:";
			// 
			// lbVerInt
			// 
			this->lbVerInt->BorderStyle = System::Windows::Forms::BorderStyle::FixedSingle;
			this->lbVerInt->Location = System::Drawing::Point(152, 24);
			this->lbVerInt->Name = L"lbVerInt";
			this->lbVerInt->Size = System::Drawing::Size(45, 15);
			this->lbVerInt->TabIndex = 23;
			this->lbVerInt->Text = L"0";
			this->lbVerInt->TextAlign = System::Drawing::ContentAlignment::MiddleRight;
			// 
			// label3
			// 
			this->label3->AutoSize = true;
			this->label3->Location = System::Drawing::Point(203, 11);
			this->label3->Name = L"label3";
			this->label3->Size = System::Drawing::Size(73, 13);
			this->label3->TabIndex = 22;
			this->label3->Text = L"Version string:";
			// 
			// cbbDevices
			// 
			this->cbbDevices->DropDownStyle = System::Windows::Forms::ComboBoxStyle::DropDownList;
			this->cbbDevices->FormattingEnabled = true;
			this->cbbDevices->Location = System::Drawing::Point(96, 6);
			this->cbbDevices->Name = L"cbbDevices";
			this->cbbDevices->Size = System::Drawing::Size(121, 21);
			this->cbbDevices->TabIndex = 32;
			// 
			// label1
			// 
			this->label1->AutoSize = true;
			this->label1->Location = System::Drawing::Point(12, 9);
			this->label1->Name = L"label1";
			this->label1->Size = System::Drawing::Size(49, 13);
			this->label1->TabIndex = 31;
			this->label1->Text = L"Comport:";
			// 
			// btConnect
			// 
			this->btConnect->Location = System::Drawing::Point(223, 4);
			this->btConnect->Name = L"btConnect";
			this->btConnect->Size = System::Drawing::Size(75, 23);
			this->btConnect->TabIndex = 30;
			this->btConnect->Text = L"Connect";
			this->btConnect->UseVisualStyleBackColor = true;
			this->btConnect->Click += gcnew System::EventHandler(this, &Form1::btConnect_Click);
			// 
			// btRefresh
			// 
			this->btRefresh->BackgroundImage = (cli::safe_cast<System::Drawing::Image^>(resources->GetObject(L"btRefresh.BackgroundImage")));
			this->btRefresh->Location = System::Drawing::Point(67, 4);
			this->btRefresh->Name = L"btRefresh";
			this->btRefresh->Size = System::Drawing::Size(23, 23);
			this->btRefresh->TabIndex = 29;
			this->btRefresh->UseVisualStyleBackColor = true;
			this->btRefresh->Click += gcnew System::EventHandler(this, &Form1::btRefresh_Click);
			// 
			// Form1
			// 
			this->AutoScaleDimensions = System::Drawing::SizeF(6, 13);
			this->AutoScaleMode = System::Windows::Forms::AutoScaleMode::Font;
			this->ClientSize = System::Drawing::Size(596, 297);
			this->Controls->Add(this->groupBox1);
			this->Controls->Add(this->cbbDevices);
			this->Controls->Add(this->label1);
			this->Controls->Add(this->btConnect);
			this->Controls->Add(this->btRefresh);
			this->Name = L"Form1";
			this->Text = L"C++ Interbus sample";
			this->groupBox1->ResumeLayout(false);
			this->groupBox1->PerformLayout();
			this->groupBox3->ResumeLayout(false);
			this->groupBox3->PerformLayout();
			(cli::safe_cast<System::ComponentModel::ISupportInitialize^>(this->nudPwrOnOff))->EndInit();
			this->groupBox2->ResumeLayout(false);
			this->groupBox2->PerformLayout();
			(cli::safe_cast<System::ComponentModel::ISupportInitialize^>(this->trkbarPowerlevel))->EndInit();
			(cli::safe_cast<System::ComponentModel::ISupportInitialize^>(this->nudDeviceId))->EndInit();
			this->ResumeLayout(false);
			this->PerformLayout();

		}
#pragma endregion


	private: System::Void RescanPorts()
        {
            this->cbbDevices->Items->Clear();
            this->cbbDevices->Items->AddRange(SerialPort::GetPortNames());
            if (cbbDevices->Items->Count > 0)
                this->cbbDevices->SelectedIndex = 0;
        }

	private: System::Void btRefresh_Click(System::Object^  sender, System::EventArgs^  e)
		{
			RescanPorts();
		}

	private: System::Void btConnect_Click(System::Object^  sender, System::EventArgs^  e)
		 {
            if (comport->IsOpen)
            {
				comport->Handshake = Handshake::None;
                comport->Close();
                this->btRefresh->Enabled = true;
                this->cbbDevices->Enabled = true;
                this->btConnect->BackColor = SystemColors::Control;
                this->btConnect->Text = "Connect";

            }
            else
            {
                try
                {
                    comport->PortName = this->cbbDevices->Items[this->cbbDevices->SelectedIndex]->ToString();
                    comport->BaudRate = 115200;
                    comport->Parity = Parity::None;
                    comport->StopBits = StopBits::Two;

                    comport->Handshake = Handshake::None;
					comport->DtrEnable = true;
					comport->RtsEnable = true;
                    comport->Open();
                }
                catch (...)
                {
                    //throw;
                }

                if (comport->IsOpen)
                {
                    this->btRefresh->Enabled = false;
                    this->cbbDevices->Enabled = false;
                    this->btConnect->BackColor = Color::ForestGreen;
                    this->btConnect->Text = "DisConnect";
                }
                else
                {
                    MessageBox::Show("Error opening port: " + this->cbbDevices->Items[this->cbbDevices->SelectedIndex]->ToString(), "Error", MessageBoxButtons::OK);
                }

            }


		 }


	private: System::Void btReadVersion_Click(System::Object^  sender, System::EventArgs^  e)
		{
			array<unsigned char>^ tempData; // = gcnew array<unsigned char>(1);
            //byte[] tempData;

            // Read register 0x64 - Version (Int16 + Ascii string)
            if (comport->IsOpen)
            {
                tempData = InterbusFunc::readInterbus_Stream(comport, (unsigned char)this->nudDeviceId->Value, 0x64);

                if (tempData->Length > 1)
                {
                    this->lbVerInt->ForeColor = SystemColors::ControlText;
                    this->lbVerInt->Text = (BitConverter::ToUInt16(tempData, 0) / 100.0).ToString("#0.00");
                }
                else
                {
                    this->lbVerInt->ForeColor = Color::Red;
                    this->lbVerInt->Text = "*";
                }

                if (tempData->Length > 2)
                {
                    this->lbVerStr->ForeColor = SystemColors::ControlText;
                    this->lbVerStr->Text = Encoding::UTF8->GetString(tempData, 2, tempData->Length - 2);
                }
                else
                {
                    this->lbVerStr->ForeColor = Color::Red;
                    this->lbVerStr->Text = "*";
                }

            }


		}

	private: System::Void btReadOnOff_Click(System::Object^  sender, System::EventArgs^  e)
		{

            int tempData;

            // Read register 0x30 - On/Off (byte)
            if (comport->IsOpen)
            {
                tempData = InterbusFunc::readInterbus_Byte(comport, (Byte)this->nudDeviceId->Value, 0x30);

                this->lbPwrOnOffStatus->Text = tempData.ToString();

            }

		}

	private: System::Void btWriteOnOff_Click(System::Object^  sender, System::EventArgs^  e)
		{
            // Write register 0x30 - On/Off (byte)
            if (comport->IsOpen)
            {
                if (InterbusFunc::writeInterbus_Byte(comport, (unsigned char)this->nudDeviceId->Value, 0x30, (unsigned char)this->nudPwrOnOff->Value))
                {
                    this->nudPwrOnOff->ForeColor = SystemColors::ControlText;   // Write successfull
                }
                else
                {
                    this->nudPwrOnOff->ForeColor = Color::Red;  // Write failed!
                }
            }

		}

	private: System::Void trkbarPowerlevel_ValueChanged(System::Object^  sender, System::EventArgs^  e)
		{
			this->lbPowerlevelSetting->Text = this->trkbarPowerlevel->Value.ToString();
		}

	private: System::Void btSetPowerlevel_Click(System::Object^  sender, System::EventArgs^  e)
		{
			// Write register 0x37 - Power level (UInt16)
			if (comport->IsOpen)
			{
				if (InterbusFunc::writeInterbus_UInt16(comport, (unsigned char)this->nudDeviceId->Value, 0x37, (unsigned short)this->trkbarPowerlevel->Value))
				{
					this->lbPowerlevelSetting->ForeColor = SystemColors::ControlText;   // Write successfull
				}
				else
				{
					this->lbPowerlevelSetting->ForeColor = Color::Red;  // Write failed!
				}
			}

		}

	private: System::Void btReadPowerlevel_Click(System::Object^  sender, System::EventArgs^  e)
		{
			UInt16 tempData;

			// Read register 0x37 - Power level status (UInt16)
			if (comport->IsOpen)
			{
				tempData = InterbusFunc::readInterbus_UInt16(comport, (unsigned char)this->nudDeviceId->Value, 0x37);

				this->lbPowerlevelStatus->Text = tempData.ToString();
				this->probarPowerlevel->Value = tempData;

			}

		}

};
}

