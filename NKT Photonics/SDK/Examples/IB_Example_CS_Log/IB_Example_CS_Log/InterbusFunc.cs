using System;
using System.Collections.Generic;
using System.Text;
using System.Timers;

using System.IO.Ports;
using System.Threading;

namespace IB_Example_CS_Log
{
    static class InterbusFunc
    {
        public enum ibMsgType
        {
            ibNack = 0x00,
            ibCRC = 0x01,
            ibBusy = 0x02,
            ibAck = 0x03,
            ibRdCmd = 0x04,
            ibWrCmd = 0x05,
            ibWrSet = 0x06,
            ibWrClr = 0x07,
            ibDatagram = 0x08,
            ibWrTgl = 0x09,
            ibNONE = 0xFF
        };


        public static byte masterId = 66;
        public static int timeout_mS = 200;

        public static bool readInterbus_Byte(SerialPort wrkPort, byte deviceId, byte registerId, ref ibMsgType respType, ref byte data)
        {
            byte[] tempData = new byte[240];
            respType = ibMsgType.ibNONE;

            if (wrkPort.IsOpen)
            {
                flushReceiver(wrkPort);     // Flush old/garbage data from receiver
                sendInterbusMessage(wrkPort, deviceId, registerId, ibMsgType.ibRdCmd, null);
                if (ReceiveMessage(wrkPort, deviceId, registerId, ref respType, ref tempData) == RxStates.MessageReady)
                {
                    if (respType == ibMsgType.ibDatagram && tempData.Length == 1)
                    {
                        // Datagram received (0x08) with 1 byte
                        data = tempData[0];
                        return true;
                    }
                }
            }
            return false;
        }

        public static bool writeInterbus_Byte(SerialPort wrkPort, byte deviceId, byte registerId, ref ibMsgType respType, byte data)
        {
            byte[] tempData = new byte[240];
            respType = ibMsgType.ibNONE;

            if (wrkPort.IsOpen)
            {
                flushReceiver(wrkPort);     // Flush old/garbage data from receiver
                sendInterbusMessage(wrkPort, deviceId, registerId, ibMsgType.ibWrCmd, new byte[] { data });
                if (ReceiveMessage(wrkPort, deviceId, registerId, ref respType, ref tempData) == RxStates.MessageReady)
                {
                    return (respType == ibMsgType.ibAck);  // Acknowledge received (0x03)
                }
            }
            return false;
        }

        public static bool readInterbus_UInt16(SerialPort wrkPort, byte deviceId, byte registerId, ref ibMsgType respType, ref UInt16 data)
        {
            byte[] tempData = new byte[240];
            respType = ibMsgType.ibNONE;

            if (wrkPort.IsOpen)
            {
                flushReceiver(wrkPort);     // Flush old/garbage data from receiver
                sendInterbusMessage(wrkPort, deviceId, registerId, ibMsgType.ibRdCmd, null);
                if (ReceiveMessage(wrkPort, deviceId, registerId, ref respType, ref tempData) == RxStates.MessageReady)
                {
                    if (respType == ibMsgType.ibDatagram && tempData.Length == 2)
                    {
                        // Datagram received (0x08) with 2 bytes
                        data = BitConverter.ToUInt16(tempData, 0);
                        return true;
                    }
                }
            }
            return false;
        }

        public static bool writeInterbus_UInt16(SerialPort wrkPort, byte deviceId, byte registerId, ref ibMsgType respType, UInt16 data)
        {
            byte[] tempData = new byte[240];
            respType = ibMsgType.ibNONE;

            if (wrkPort.IsOpen)
            {
                flushReceiver(wrkPort);     // Flush old/garbage data from receiver
                sendInterbusMessage(wrkPort, deviceId, registerId, ibMsgType.ibWrCmd, BitConverter.GetBytes(data));
                if (ReceiveMessage(wrkPort, deviceId, registerId, ref respType, ref tempData) == RxStates.MessageReady)
                {
                    return (respType == ibMsgType.ibAck);  // Acknowledge received (0x03)
                }
            }
            return false;
        }

        public static bool readInterbus_UInt32(SerialPort wrkPort, byte deviceId, byte registerId, ref ibMsgType respType, ref UInt32 data)
        {
            byte[] tempData = new byte[240];
            respType = ibMsgType.ibNONE;

            if (wrkPort.IsOpen)
            {
                flushReceiver(wrkPort);     // Flush old/garbage data from receiver
                sendInterbusMessage(wrkPort, deviceId, registerId, ibMsgType.ibRdCmd, null);
                if (ReceiveMessage(wrkPort, deviceId, registerId, ref respType, ref tempData) == RxStates.MessageReady)
                {
                    if (respType == ibMsgType.ibDatagram && tempData.Length == 4)
                    {
                        // Datagram received (0x08) with 4 bytes
                        data = BitConverter.ToUInt32(tempData, 0);
                        return true;
                    }
                }
            }
            return false;
        }

        public static bool writeInterbus_UInt32(SerialPort wrkPort, byte deviceId, byte registerId, ref ibMsgType respType, UInt32 data)
        {
            byte[] tempData = new byte[240];
            respType = ibMsgType.ibNONE;

            if (wrkPort.IsOpen)
            {
                flushReceiver(wrkPort);     // Flush old/garbage data from receiver
                sendInterbusMessage(wrkPort, deviceId, registerId, ibMsgType.ibWrCmd, BitConverter.GetBytes(data));
                if (ReceiveMessage(wrkPort, deviceId, registerId, ref respType, ref tempData) == RxStates.MessageReady)
                {
                    return (respType == ibMsgType.ibAck);  // Acknowledge received (0x03)
                }
            }
            return false;
        }

        public static bool readInterbus_Float32(SerialPort wrkPort, byte deviceId, byte registerId, ref ibMsgType respType, ref Single data)
        {
            byte[] tempData = new byte[240];
            respType = ibMsgType.ibNONE;

            if (wrkPort.IsOpen)
            {
                flushReceiver(wrkPort);     // Flush old/garbage data from receiver
                sendInterbusMessage(wrkPort, deviceId, registerId, ibMsgType.ibRdCmd, null);
                if (ReceiveMessage(wrkPort, deviceId, registerId, ref respType, ref tempData) == RxStates.MessageReady)
                {
                    if (respType == ibMsgType.ibDatagram && tempData.Length == 4)
                    {
                        // Datagram received (0x08) with 4 bytes
                        data = BitConverter.ToSingle(tempData, 0);
                        return true;
                    }
                }
            }
            return false;
        }

        public static bool writeInterbus_Float32(SerialPort wrkPort, byte deviceId, byte registerId, ref ibMsgType respType, Single data)
        {
            byte[] tempData = new byte[240];
            respType = ibMsgType.ibNONE;

            if (wrkPort.IsOpen)
            {
                flushReceiver(wrkPort);     // Flush old/garbage data from receiver
                sendInterbusMessage(wrkPort, deviceId, registerId, ibMsgType.ibWrCmd, BitConverter.GetBytes(data));
                if (ReceiveMessage(wrkPort, deviceId, registerId, ref respType, ref tempData) == RxStates.MessageReady)
                {
                    return (respType == ibMsgType.ibAck);  // Acknowledge received (0x03)
                }
            }
            return false;
        }

        public static bool readInterbus_Stream(SerialPort wrkPort, byte deviceId, byte registerId, ref ibMsgType respType, ref byte[] data)
        {
            byte[] tempData = new byte[240];
            respType = ibMsgType.ibNONE;

            if (wrkPort.IsOpen)
            {
                flushReceiver(wrkPort);     // Flush old/garbage data from receiver
                sendInterbusMessage(wrkPort, deviceId, registerId, ibMsgType.ibRdCmd, null);
                if (ReceiveMessage(wrkPort, deviceId, registerId, ref respType, ref data) == RxStates.MessageReady)
                {
                    return (respType == ibMsgType.ibDatagram);  // Datagram received (0x08)
                }
            }
            return false;
        }

        public static bool writeInterbus_Stream(SerialPort wrkPort, byte deviceId, byte registerId, ref ibMsgType respType, byte[] data)
        {
            byte[] tempData = new byte[240];
            respType = ibMsgType.ibNONE;

            if (wrkPort.IsOpen)
            {
                flushReceiver(wrkPort);     // Flush old/garbage data from receiver
                sendInterbusMessage(wrkPort, deviceId, registerId, ibMsgType.ibWrCmd, data);
                if (ReceiveMessage(wrkPort, deviceId, registerId, ref respType, ref tempData) == RxStates.MessageReady)
                {
                    return (respType == ibMsgType.ibAck);  // Acknowledge received (0x03)
                }
            }
            return false;
        }


        //-----------------------------------------------------------------------------------------------------------
        // Message helpers
        //-----------------------------------------------------------------------------------------------------------

        enum RxStates
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
        }

        static RxStates rxState;

        static int txBufferSize;
        static byte[] txBuffer = new byte[240];
        static ushort txCRC;

        static ushort calcCRC16(byte data, ushort OldCRC)
        {
            OldCRC = (ushort)((OldCRC >> 8) | (OldCRC << 8));
            OldCRC ^= data;
            OldCRC ^= (byte)((OldCRC & 0xff) >> 4);
            OldCRC ^= (ushort)((OldCRC << 8) << 4);
            OldCRC ^= (ushort)(((OldCRC & 0xff) << 4) << 1);
            return OldCRC;
        }

        static void addToTxMsgData(byte[] data, int idx, int cnt, bool escParse, bool updCRC)
        {
            for (int n = 0; n < cnt; n++)
            {
                addToTxMsgData(data[n + idx], escParse, updCRC);
            }
        }

        static void addToTxMsgData(byte data, bool escParse, bool updCRC)
        {
            if (updCRC)
                txCRC = calcCRC16(data, txCRC);
            if (escParse)
            {
                if (data == 0x0D || data == 0x0A || data == 0x5E)
                {
                    txBuffer[txBufferSize] = 0x5E;
                    if (txBufferSize < txBuffer.Length)
                        txBufferSize++;
                    data += 0x40;
                }
            }
            txBuffer[txBufferSize] = data;
            if (txBufferSize < txBuffer.Length) // Assure 
                txBufferSize++;                 // we are not overloading the txBuffer
        }

        static void flushReceiver(SerialPort wrkPort)
        {
            wrkPort.DiscardInBuffer();
        }

        static void sendInterbusMessage(SerialPort wrkPort, byte deviceId, byte registerId, ibMsgType msgType, byte[] data)
        {
            txCRC = 0;
            txBufferSize = 0;
            addToTxMsgData(0x0D, false, false);                     // Start of Telegram
            addToTxMsgData(deviceId, true, true);
            addToTxMsgData(masterId, true, true);
            addToTxMsgData((byte)msgType, true, true);
            addToTxMsgData(registerId, true, true);
            if (msgType == ibMsgType.ibWrCmd || msgType == ibMsgType.ibWrClr || msgType == ibMsgType.ibWrSet || msgType == ibMsgType.ibWrTgl)
                addToTxMsgData(data, 0, data.Length, true, true);   // Add write data to message
            addToTxMsgData((byte)(txCRC >> 8), true, false);
            addToTxMsgData((byte)txCRC, true, false);
            addToTxMsgData(0x0A, false, false);                     // End of Telegram
            try
            {
                wrkPort.Write(txBuffer, 0, txBufferSize);
            }
            catch (Exception)
            {

            }
        }


        static RxStates ReceiveMessage(SerialPort wrkPort, byte deviceId, byte registerId, ref ibMsgType msgType, ref byte[] payload)
        {
            byte rxCh;
            bool rxEscape = false;
            int rxBufferSize = 0;
            byte[] rxBuffer = new byte[256];
            ushort rxCRC = 0;

            byte[] dataBuffer = new byte[256];
            int dataSize = 0;
            int dataPtr = 0;

            rxState = RxStates.Hunting_SOT;
            msgType = ibMsgType.ibNONE;
            
            // Setup a timeout time
            DateTime timeoutTime = DateTime.Now.AddMilliseconds(timeout_mS);

            while (rxState == RxStates.Hunting_SOT || rxState == RxStates.Hunting_EOT)
            {
                if (dataSize == 0)
                {
                    // Check for data received or timeout

                    try
                    {
                        dataSize = wrkPort.BytesToRead;
                        if (dataSize > 0)
                        {
                            if (dataSize > dataBuffer.Length)
                                dataSize = dataBuffer.Length;

                            wrkPort.Read(dataBuffer, 0, dataSize);
                            dataPtr = 0;
                        }
                        else
                        {
                            if (timeoutTime.CompareTo(DateTime.Now) < 0)
                                rxState = RxStates.Timeout_Error;
                        }
                    }
                    catch (Exception)
                    {
                        rxState = RxStates.Port_Lost;
                    }

                }

                if (dataSize > 0)
                {
                    // We have RX data ready

                    rxCh = dataBuffer[dataPtr];
                    dataPtr++;
                    dataSize--;

                    if (rxState == RxStates.Hunting_SOT)        // Hunting Start Of Telegram
                    {
                        if (rxCh == 0x0D)
                        {
                            // Got start of telegram
                            rxBufferSize = 0;
                            Array.Clear(rxBuffer, 0, rxBuffer.Length);
                            rxEscape = false;
                            rxCRC = 0;
                            rxState = RxStates.Hunting_EOT;
                        }
                    }
                    else if (rxState == RxStates.Hunting_EOT)   // Hunting End Of Telegram while collecting telegram
                    {
                        if (rxCh == 0x0A)
                        {
                            // Got end of telegram
                            if (rxBufferSize >= 5)     // Dest + Src + Type + msbCRC + lsbCRC - Minimum telegram length
                            {
                                if (rxCRC == 0)
                                {
                                    // We have collected a message with valid CRC - Check the contents
                                    if (rxBuffer[0] == masterId && rxBuffer[1] == deviceId && rxBuffer[3] == registerId)
                                    {
                                        // Hurra - We have a complete telegram - Copy the payload to destination array
                                        rxBufferSize--;                     // Remove CRC
                                        rxBuffer[rxBufferSize] = 0;
                                        rxBufferSize--;
                                        rxBuffer[rxBufferSize] = 0;
                                        Array.Copy(rxBuffer, 4, payload, 0, payload.Length);
                                        if (rxBufferSize-4 < payload.Length)
                                            Array.Resize<byte>(ref payload, rxBufferSize-4);
                                        // Return the actual response type, since it might not be the expected response, but it might be a NACK or BUSY response.
                                        msgType = (ibMsgType)rxBuffer[2];
                                        rxState = RxStates.MessageReady;
                                    }
                                    else
                                        rxState = RxStates.Content_Error;
                                }
                                else
                                    rxState = RxStates.CRC_Error;
                            }
                            else
                                rxState = RxStates.Garbage_Error;
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
                                    rxBuffer[rxBufferSize] = (byte)(rxCh - 0x40);
                                    rxEscape = false;
                                }
                                else
                                {
                                    rxBuffer[rxBufferSize] = rxCh;
                                }

                                rxCRC = calcCRC16(rxBuffer[rxBufferSize], rxCRC);   // Update crc

                                if (rxBufferSize < rxBuffer.Length)
                                    rxBufferSize++;
                                else
                                    rxState = RxStates.Overrun_Error;
                            }
                        }
                    }
                }
            }

            return rxState;
        }
    }
}
