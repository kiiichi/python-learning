#include "StdAfx.h"
#include "InterbusFunc.h"


InterbusFunc::InterbusFunc(void)
{

}

unsigned char InterbusFunc::readInterbus_Byte(SerialPort^ wrkPort, unsigned char deviceId, unsigned char registerId)
{
	array<unsigned char>^ tempData = gcnew array<unsigned char>(1);
	if (wrkPort->IsOpen)
	{
		flushReceiver(wrkPort);     // Flush old/garbage data from receiver
		sendInterbusMessage(wrkPort, deviceId, registerId, 0x04, nullptr);
		if (ReceiveMessage(wrkPort, deviceId, registerId, 0x08, tempData) == RxStates::MessageReady)
		{
			return tempData[0];
		}
	}
	return 0;
}

bool InterbusFunc::writeInterbus_Byte(SerialPort^ wrkPort, unsigned char deviceId, unsigned char registerId, unsigned char data)
{
	array<unsigned char>^ tempData = gcnew array<unsigned char>(1);
	if (wrkPort->IsOpen)
	{
		tempData[0] = data;
		flushReceiver(wrkPort);     // Flush old/garbage data from receiver
		sendInterbusMessage(wrkPort, deviceId, registerId, 0x05, tempData);
		if (ReceiveMessage(wrkPort, deviceId, registerId, 0x03, tempData) == RxStates::MessageReady)
		{
			return true;  // Acknowledge received (0x03)
		}
	}
	return false;
}

unsigned short InterbusFunc::readInterbus_UInt16(SerialPort^ wrkPort, unsigned char deviceId, unsigned char registerId)
{
	array<unsigned char>^ tempData = gcnew array<unsigned char>(2);
	if (wrkPort->IsOpen)
	{
		flushReceiver(wrkPort);     // Flush old/garbage data from receiver
		sendInterbusMessage(wrkPort, deviceId, registerId, 0x04, nullptr);
		if (ReceiveMessage(wrkPort, deviceId, registerId, 0x08, tempData) == RxStates::MessageReady)
		{
			if (tempData->Length == 2)
				return BitConverter::ToUInt16(tempData, 0);
		}
	}
	return 0;
}

bool InterbusFunc::writeInterbus_UInt16(SerialPort^ wrkPort, unsigned char deviceId, unsigned char registerId, unsigned short data)
{
	array<unsigned char>^ tempData = gcnew array<unsigned char>(1);
	if (wrkPort->IsOpen)
	{
		flushReceiver(wrkPort);     // Flush old/garbage data from receiver
		sendInterbusMessage(wrkPort, deviceId, registerId, 0x05, BitConverter::GetBytes(data));
		if (ReceiveMessage(wrkPort, deviceId, registerId, 0x03, tempData) == RxStates::MessageReady)
		{
			return true;  // Acknowledge received (0x03)
		}
	}
	return false;
}


unsigned long InterbusFunc::readInterbus_UInt32(SerialPort^ wrkPort, unsigned char deviceId, unsigned char registerId)
{
	array<unsigned char>^ tempData = gcnew array<unsigned char>(4);
	if (wrkPort->IsOpen)
	{
		flushReceiver(wrkPort);     // Flush old/garbage data from receiver
		sendInterbusMessage(wrkPort, deviceId, registerId, 0x04, nullptr);
		if (ReceiveMessage(wrkPort, deviceId, registerId, 0x08, tempData) == RxStates::MessageReady)
		{
			if (tempData->Length == 4)
				return BitConverter::ToUInt32(tempData, 0);
		}
	}
	return 0;
}

bool InterbusFunc::writeInterbus_UInt32(SerialPort^ wrkPort, unsigned char deviceId, unsigned char registerId, unsigned long data)
{
	array<unsigned char>^ tempData = gcnew array<unsigned char>(1);
	if (wrkPort->IsOpen)
	{
		flushReceiver(wrkPort);     // Flush old/garbage data from receiver
		sendInterbusMessage(wrkPort, deviceId, registerId, 0x05, BitConverter::GetBytes((UInt32)data));
		if (ReceiveMessage(wrkPort, deviceId, registerId, 0x03, tempData) == RxStates::MessageReady)
		{
			return true;  // Acknowledge received (0x03)
		}
	}
	return false;
}

float InterbusFunc::readInterbus_Float32(SerialPort^ wrkPort, unsigned char deviceId, unsigned char registerId)
{
	array<unsigned char>^ tempData = gcnew array<unsigned char>(4);
	if (wrkPort->IsOpen)
	{
		flushReceiver(wrkPort);     // Flush old/garbage data from receiver
		sendInterbusMessage(wrkPort, deviceId, registerId, 0x04, nullptr);
		if (ReceiveMessage(wrkPort, deviceId, registerId, 0x08, tempData) == RxStates::MessageReady)
		{
			if (tempData->Length == 4)
				return BitConverter::ToSingle(tempData, 0);
		}
	}
	return 0;
}

bool InterbusFunc::writeInterbus_Float32(SerialPort^ wrkPort, unsigned char deviceId, unsigned char registerId, float data)
{
	array<unsigned char>^ tempData = gcnew array<unsigned char>(1);
	if (wrkPort->IsOpen)
	{
		flushReceiver(wrkPort);     // Flush old/garbage data from receiver
		sendInterbusMessage(wrkPort, deviceId, registerId, 0x05, BitConverter::GetBytes(data));
		if (ReceiveMessage(wrkPort, deviceId, registerId, 0x03, tempData) == RxStates::MessageReady)
		{
			return true;  // Acknowledge received (0x03)
		}
	}
	return false;
}

array<unsigned char>^ InterbusFunc::readInterbus_Stream(SerialPort^ wrkPort, unsigned char deviceId, unsigned char registerId)
{
	array<unsigned char>^ tempData = gcnew array<unsigned char>(240);
	if (wrkPort->IsOpen)
	{
		flushReceiver(wrkPort);     // Flush old/garbage data from receiver
		sendInterbusMessage(wrkPort, deviceId, registerId, 0x04, nullptr);
		if (ReceiveMessage(wrkPort, deviceId, registerId, 0x08, tempData) == RxStates::MessageReady)
		{
			return tempData;
		}
	}
	return gcnew array<unsigned char>(0);
}

bool InterbusFunc::writeInterbus_Stream(SerialPort^ wrkPort, unsigned char deviceId, unsigned char registerId, array<unsigned char>^ data)
{
	array<unsigned char>^ tempData = gcnew array<unsigned char>(1);
	if (wrkPort->IsOpen)
	{
		flushReceiver(wrkPort);     // Flush old/garbage data from receiver
		sendInterbusMessage(wrkPort, deviceId, registerId, 0x05, data);
		if (ReceiveMessage(wrkPort, deviceId, registerId, 0x03, tempData) == RxStates::MessageReady)
		{
			return true;  // Acknowledge received (0x03)
		}
	}
	return false;
}


//-----------------------------------------------------------------------------------------------------------
// Message helpers
//-----------------------------------------------------------------------------------------------------------


unsigned short InterbusFunc::calcCRC16(unsigned char data, unsigned short OldCRC)
{
	OldCRC = (unsigned short)((OldCRC >> 8) | (OldCRC << 8));
	OldCRC ^= data;
	OldCRC ^= (unsigned char)((OldCRC & 0xff) >> 4);
	OldCRC ^= (unsigned short)((OldCRC << 8) << 4);
	OldCRC ^= (unsigned short)(((OldCRC & 0xff) << 4) << 1);
	return OldCRC;
}

void InterbusFunc::addToTxMsgData(array<unsigned char>^ data, int idx, int cnt, bool escParse, bool updCRC)
{
	for (int n = 0; n < cnt; n++)
	{
		addToTxMsgData(data[n + idx], escParse, updCRC);
	}
}

void InterbusFunc::addToTxMsgData(unsigned char data, bool escParse, bool updCRC)
{
	if (updCRC)
		txCRC = calcCRC16(data, txCRC);
	if (escParse)
	{
		if (data == 0x0D || data == 0x0A || data == 0x5E)
		{
			txBuffer[txBufferSize] = 0x5E;
			if (txBufferSize < txBuffer->Length)
				txBufferSize++;
			data += 0x40;
		}
	}
	txBuffer[txBufferSize] = data;
	if (txBufferSize < txBuffer->Length) // Assure we are not overloading the txBuffer
		txBufferSize++;
}

void InterbusFunc::flushReceiver(SerialPort^ wrkPort)
{
	wrkPort->DiscardInBuffer();
}

void InterbusFunc::sendInterbusMessage(SerialPort^ wrkPort, unsigned char deviceId, unsigned char registerId, unsigned char msgType, array<unsigned char>^ data)
{
	txCRC = 0;
	txBufferSize = 0;
	addToTxMsgData(0x0D, false, false);                     // Start of Telegram
	addToTxMsgData(deviceId, true, true);
	addToTxMsgData(masterId, true, true);
	addToTxMsgData(msgType, true, true);
	addToTxMsgData(registerId, true, true);
	if (msgType == 0x05 && data != nullptr)                 // 0x05 = Write messsage - 0x04 = Read message
		addToTxMsgData(data, 0, data->Length, true, true);  // Add write data to message
	addToTxMsgData((unsigned char)(txCRC >> 8), true, false);
	addToTxMsgData((unsigned char)txCRC, true, false);
	addToTxMsgData(0x0A, false, false);                     // End of Telegram
	try
    {
		wrkPort->Write(txBuffer, 0, txBufferSize);
	}
	catch (...)
	{
		//txCRC = 0;
	}
}

InterbusFunc::RxStates InterbusFunc::ReceiveMessage(SerialPort^ wrkPort, unsigned char deviceId, unsigned char registerId, unsigned char msgType, array<unsigned char>^ payload)
{
	int rxIntData;
	unsigned char rxCh;
	rxState = RxStates::Hunting_SOT;
	rxTimeout = timeout_mS;

	while (rxState == RxStates::Hunting_SOT || rxState == RxStates::Hunting_EOT)
	{
		try
		{
			if (wrkPort->BytesToRead > 0)
				rxIntData = wrkPort->ReadByte();
			else
				rxIntData = -1;
		}
		catch (...)
		{
			rxState = RxStates::Port_Lost;
			rxIntData = -1;
		}

		if (rxIntData == -1)
		{
			// No RX data ready - Go and wait for 1mS
			if (rxTimeout > 0)
			{
				rxTimeout--;
				Thread::Sleep(1);
			}
            else
				rxState = RxStates::Timeout_Error;
		}
        else
		{
			// We have RX data ready

			rxCh = (unsigned char)rxIntData;     // Cast the integer read from serialport to an byte. See. SerialPort->ReadByte() for info,

			if (rxState == RxStates::Hunting_SOT)        // Hunting Start Of Telegram
			{
				if (rxCh == 0x0D)
				{
					// Got start of telegram
					rxBufferSize = 0;
					Array::Clear(rxBuffer, 0, rxBuffer->Length);

					rxEscape = false;
					rxCRC = 0;
					rxState = RxStates::Hunting_EOT;
				}
			}
			else if (rxState == RxStates::Hunting_EOT)   // Hunting End Of Telegram while collecting telegram
			{
				if (rxCh == 0x0A)
				{
					// Got end of telegram
					if (rxBufferSize >= 5)     // Dest + Src + Type + msbCRC + lsbCRC - Minimum telegram length
					{
						if (rxCRC == 0)
						{
							// We have collected a message with valid CRC - Check the contents
							if (rxBuffer[0] == masterId && rxBuffer[1] == deviceId && rxBuffer[2] == msgType && rxBuffer[3] == registerId)
							{
								// Hurra - We have a complete telegram - Copy the payload to destination array
								rxBufferSize--;                     // Remove CRC
								rxBuffer[rxBufferSize] = 0;
								rxBufferSize--;
								rxBuffer[rxBufferSize] = 0;
								Array::Copy(rxBuffer, 4, payload, 0, payload->Length);
								if (rxBufferSize-4 < payload->Length)
									Array::Resize<unsigned char>(payload, rxBufferSize-4);
								rxState = RxStates::MessageReady;
							}
							else
								rxState = RxStates::Content_Error;
						}
						else
							rxState = RxStates::CRC_Error;
					}
					else
						rxState = RxStates::Garbage_Error;
				}
				else
				{
					// Collecting telegram
					if (rxCh == 0x5E)
					{
						rxEscape = true;    // Got escape sequence
					}
					else
					{
						// Got normal telegram contents
						if (rxEscape)
						{
							rxBuffer[rxBufferSize] = (unsigned char)(rxCh - 0x40);
							rxEscape = false;
						}
						else
						{
							rxBuffer[rxBufferSize] = rxCh;
						}

						rxCRC = calcCRC16(rxBuffer[rxBufferSize], rxCRC);   // Update crc

						if (rxBufferSize < rxBuffer->Length)
							rxBufferSize++;
						else
							rxState = RxStates::Overrun_Error;
					}
				}
			}


		}

	}
	return rxState;
}

