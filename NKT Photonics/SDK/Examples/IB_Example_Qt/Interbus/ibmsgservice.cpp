#include "ibmsgservice.h"

IBMsgService::IBMsgService(QSerialPort *comport, QObject *parent) :
    QObject(parent)
{
    wrkPort = comport;
    rxState = RxStStopped;

    connect(wrkPort, SIGNAL(readyRead()), this, SLOT(slotRxBytesReceived()));
    connect(wrkPort, SIGNAL(bytesWritten(qint64)), this, SLOT(slotTxBytesSend(qint64)));

    connect(&rxTimeoutTimer, SIGNAL(timeout()), this, SLOT(slotRxMessageTimeout()));


    txMasterId = 66;    // Our id (address)
    rxMsgTimeout = 50;  // 50mS message timeout



}

//**************************************************************************
//* Interbus Message Helpers
//**************************************************************************

void IBMsgService::slotRxMessageTimeout()
{
    bool wasRunning = rxTimeoutTimer.isActive();
    rxTimeoutTimer.stop();
    if (wasRunning)
    {
        rxState = RxStTimeout_Error;
        emit sigReceiverStatus(rxDeviceId, rxRegisterId, txMsgType, msgIntError, QByteArray());
    }
    else
        qDebug() << "rxMessageTimeout - Timer was not running, when entering timeout routine!!!!!" ;
}

void IBMsgService::slotTxBytesSend(qint64 byteCount)
{
    Q_UNUSED(byteCount)

    if (rxTimeoutTimer.remainingTime() > 0)
        rxTimeoutTimer.start();
    rxState = RxStHunting_SOT;
}

ushort IBMsgService::calcCRC16(unsigned char data, ushort OldCRC)
{
    OldCRC = (ushort)((OldCRC >> 8) | (OldCRC << 8));
    OldCRC ^= data;
    OldCRC ^= (unsigned char)((OldCRC & 0xff) >> 4);
    OldCRC ^= (ushort)((OldCRC << 8) << 4);
    OldCRC ^= (ushort)(((OldCRC & 0xff) << 4) << 1);
    return OldCRC;
}

void IBMsgService::txMsgAppend(QByteArray *data, bool escParse, bool updCRC)
{
    if (data)
    {
        for (int n = 0; n < data->size(); n++)
            txMsgAppend(data->data()[n], escParse, updCRC);
    }
}

void IBMsgService::txMsgAppend(unsigned char data, bool escParse, bool updCRC)
{
    unsigned char tempData = data;

    if (updCRC)
        txCalcCRC = calcCRC16(data, txCalcCRC);
    if (escParse)
    {
        if (tempData == 0x0D || tempData == 0x0A || tempData == 0x5E)
        {
            txBuffer.append(0x5E);
            tempData += 0x40;
        }
    }
    txBuffer.append(tempData);
}

void IBMsgService::slotSendMessage(quint8 devId, quint8 regId, MsgTypes msgType, QByteArray msgData)
{
    // Save tx message - to allow for retransmission
    txDeviceId = devId;
    txRegisterId = regId;
    txMsgType = msgType;
    txMsgData = msgData;

    // Send the message
    slotResendMessage();
}


void IBMsgService::slotResendMessage()
{
    txCalcCRC = 0;
    txBuffer.clear();

    // Build the message
    txMsgAppend(0x0D, false, false);            // Start of telegram
    txMsgAppend(txDeviceId, true, true);        // Destination device
    txMsgAppend(txMasterId, true, true);        // Our id (masterId)
    txMsgAppend(txMsgType, true, true);         // Message type
    txMsgAppend(txRegisterId, true, true);      // Register id
    if (txMsgData.size() > 0)
        txMsgAppend(&txMsgData, true, true);    // The content/payload
    txMsgAppend(txCalcCRC >> 8, true, false);   // CRC
    txMsgAppend(txCalcCRC, true, false);        //
    txMsgAppend(0x0A, false, false);            // End of telegram

    // Prepare the receiver
    wrkPort->clear();
    rxState = RxStStopped;
    rxDeviceId = txDeviceId;
    rxRegisterId = txRegisterId;

    //    showMessage("TX:", &txBuffer);

    // Send the message
    wrkPort->write(txBuffer.data(), txBuffer.size());

    // Start the message timeout timer
    rxTimeoutTimer.start(rxMsgTimeout);
}


void IBMsgService::slotRxBytesReceived()
{
    unsigned char rxCh;

    QByteArray rxData = wrkPort->readAll();
    //showMessage("RX:", &rxData);
    for (int n = 0; n < rxData.size(); n++)
    {
        rxCh = rxData.at(n);

        switch (rxState)
        {
        case RxStHunting_SOT:   // Hunting/Waiting for SOT (Start Of Telegram)
            if (rxCh == 0x0D)
            {
                // Got SOT
                rxState = RxStHunting_EOT;
                rxMsg.clear();
                rxEscape = false;
                rxCalcCRC = 0;
            }
            break;

        case RxStHunting_EOT:   // Hunting EOT while collecting telegram
            if (rxCh == 0x0A)
            {
                // Got EOT (End Of Telegram)

                rxTimeoutTimer.stop();

                if (rxMsg.size() >= 5)   // Dest + Src + Type + msbCRC + lsbCRC = Minimum telegram length.
                {
                    if (rxCalcCRC == 0)
                    {
                        if (((quint8)rxMsg.data()[0]) == txMasterId && ((quint8)rxMsg.data()[1]) == txDeviceId)
                        {
                            //showMessage("RX:", rxMsg);
                            rxState = RxStMessageReady;
                            emit sigReceiverStatus(rxDeviceId, rxRegisterId, txMsgType, (MsgTypes)rxMsg.data()[2], QByteArray(rxMsg.mid(4, rxMsg.size()-6)));
                        }
                        else
                        {
                            //showMessage("RX:", rxMsg);
                            //qDebug() << "SYNC" << (quint8)rxMsg.data()[0] << txMasterId << (quint8)rxMsg.data()[1] << txDeviceId;

                            rxState = RxStSync_Error;
                            emit sigReceiverStatus(rxDeviceId, rxRegisterId, txMsgType, msgIntError, QByteArray());
                        }
                    }
                    else
                    {
                        //showMessage("RX:", rxMsg);
                        rxState = RxStCRC_Error;
                        emit sigReceiverStatus(rxDeviceId, rxRegisterId, txMsgType, msgIntError, QByteArray());
                    }
                }
                else
                {
                    //showMessage("RX:", rxMsg);
                    rxState = RxStGarbage_Error;
                    emit sigReceiverStatus(rxDeviceId, rxRegisterId, txMsgType, msgIntError, QByteArray());
                }
            }
            else
            {
                // Collecting telegram
                if (rxCh == 0x5E)
                {
                    // Escape sequence initiated
                    rxEscape = true;
                }
                else
                {
                    // Got normal telegram content
                    if (rxEscape)
                    {
                        rxMsg.append(rxCh - 0x40);
                        rxEscape = false;
                    }
                    else
                    {
                        rxMsg.append(rxCh);
                    }

                    rxCalcCRC = calcCRC16(rxMsg.data()[rxMsg.size()-1], rxCalcCRC);
                }

                if (rxMsg.size() > 255)
                {
                    //showMessage("RX:", rxMsg);
                    rxTimeoutTimer.stop();
                    rxState = RxStOverrun_Error;
                    emit sigReceiverStatus(rxDeviceId, rxRegisterId, txMsgType, msgIntError, QByteArray());
                }

            }
            break;

        case RxStStopped:       // RxStStopped - Discard incomming data
        case RxStMessageReady:
        case RxStTimeout_Error:
        case RxStCRC_Error:
        case RxStGarbage_Error:
        case RxStOverrun_Error:
        case RxStSync_Error:
            break;
        }

    }
}


void IBMsgService::showMessage(QString header, QByteArray *msg)
{
    QString msgStr;
    quint8 tempVal;

    for (int n = 0; n < msg->size(); n++)
    {
        tempVal = msg->data()[n];
        msgStr.append(QString::number(tempVal,16).rightJustified(2,'0').toUpper());
        msgStr.append("h ");
    }
    qDebug() << header << msgStr;
}

