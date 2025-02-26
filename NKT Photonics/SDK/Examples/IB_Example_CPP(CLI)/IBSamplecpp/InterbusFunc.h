#pragma once

using namespace System;

using namespace Threading;
using namespace System::IO::Ports;

ref class InterbusFunc
{
	

public:
	InterbusFunc(void);

	static unsigned char readInterbus_Byte(SerialPort^ wrkPort, unsigned char deviceId, unsigned char registerId);
	static bool writeInterbus_Byte(SerialPort^ wrkPort, unsigned char deviceId, unsigned char registerId, unsigned char data);

	static unsigned short readInterbus_UInt16(SerialPort^ wrkPort, unsigned char deviceId, unsigned char registerId);
	static bool writeInterbus_UInt16(SerialPort^ wrkPort, unsigned char deviceId, unsigned char registerId, unsigned short data);

	static unsigned long readInterbus_UInt32(SerialPort^ wrkPort, unsigned char deviceId, unsigned char registerId);
	static bool writeInterbus_UInt32(SerialPort^ wrkPort, unsigned char deviceId, unsigned char registerId, unsigned long data);

	static float readInterbus_Float32(SerialPort^ wrkPort, unsigned char deviceId, unsigned char registerId);
	static bool writeInterbus_Float32(SerialPort^ wrkPort, unsigned char deviceId, unsigned char registerId, float data);

	static array<unsigned char>^ readInterbus_Stream(SerialPort^ wrkPort, unsigned char deviceId, unsigned char registerId);
	static bool writeInterbus_Stream(SerialPort^ wrkPort, unsigned char deviceId, unsigned char registerId, array<unsigned char>^ data);

	static unsigned char masterId = 66;
	static int timeout_mS = 50;

private:

	enum class RxStates
    {
		Hunting_SOT,
        Hunting_EOT,
        MessageReady,
        Timeout_Error,
        CRC_Error,
        Garbage_Error,
        Overrun_Error,
        Content_Error,
        Port_Lost
	};

	static unsigned short calcCRC16(unsigned char data, unsigned short OldCRC);
	static void addToTxMsgData(array<unsigned char>^ data, int idx, int cnt, bool escParse, bool updCRC);
	static void addToTxMsgData(unsigned char data, bool escParse, bool updCRC);
	static void flushReceiver(SerialPort^ wrkPort);
	static void sendInterbusMessage(SerialPort^ wrkPort, unsigned char deviceId, unsigned char registerId, unsigned char msgType, array<unsigned char>^ data);
	static RxStates ReceiveMessage(SerialPort^ wrkPort, unsigned char deviceId, unsigned char registerId, unsigned char msgType, array<unsigned char>^ payload);
	
	static RxStates rxState;
	static int rxTimeout;
	static bool rxEscape;

	static int rxBufferSize;
	static array<unsigned char>^ rxBuffer = gcnew array<unsigned char>(260);
	static unsigned short rxCRC;

	static int txBufferSize;
	static array<unsigned char>^ txBuffer = gcnew array<unsigned char>(240);
	static unsigned short txCRC;


};

