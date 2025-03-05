#include "ibhandler.h"

#include <QEventLoop>
#include <QTimer>


IBHandler::IBHandler(QObject *parent) : QObject(parent)
{
    // Register misc. enum types, so we can use them in signals
    if (QMetaType::type("RegSetStatusTypes") == QMetaType::UnknownType)
        qRegisterMetaType<RegSetStatusTypes>( "RegSetStatusTypes" );
    if (QMetaType::type("RegGetStatusTypes") == QMetaType::UnknownType)
        qRegisterMetaType<RegGetStatusTypes>( "RegGetStatusTypes" );
    if (QMetaType::type("MsgTypes") == QMetaType::UnknownType)
        qRegisterMetaType<MsgTypes>( "MsgTypes" );
    if (QMetaType::type("RxStates") == QMetaType::UnknownType)
        qRegisterMetaType<RxStates>( "RxStates" );

    m_serialport = new QSerialPort(this);
    m_msgService = new IBMsgService(m_serialport, this);

    connect(m_msgService, SIGNAL(sigReceiverStatus(quint8,quint8,MsgTypes,MsgTypes,QByteArray)), this, SLOT(slotReceiverStatus(quint8,quint8,MsgTypes,MsgTypes,QByteArray)));

}

IBHandler::~IBHandler()
{

}

bool IBHandler::openComport(QString comport)
{
    m_serialport->close();

    if (getAvailableComports().contains(comport, Qt::CaseInsensitive))
    {
        // Serialport exists
        m_serialport->setPortName(comport);

        // Try opening
        if (m_serialport->open(QIODevice::ReadWrite))
        {
            // Configure the serialport
            m_serialport->setBaudRate(QSerialPort::Baud115200);
            m_serialport->setParity(QSerialPort::NoParity);
            m_serialport->setDataBits(QSerialPort::Data8);
            m_serialport->setStopBits(QSerialPort::OneStop);
            m_serialport->setFlowControl(QSerialPort::NoFlowControl);
            m_serialport->setDataTerminalReady(true);
            m_serialport->setRequestToSend(true);
            m_serialport->clear();

            emit comportOpened(m_serialport->portName(), m_serialport->isOpen());
            return true;
        }
    }
    return false;
}


void IBHandler::closeComport()
{
    m_serialport->close();
    emit comportOpened(m_serialport->portName(), m_serialport->isOpen());
}


bool IBHandler::isComportOpen()
{
    return m_serialport->isOpen();
}


RegSetStatusTypes IBHandler::writeRegister(const quint8 devId, const quint8 regId, const QByteArray &writeData)
{
    QEventLoop eLoop;
    QTimer toTimer;

    if (m_serialport->isOpen())
    {
        // Hookup the local eventloop
        connect(this, SIGNAL(communicationFinished()), &eLoop, SLOT(quit()));
        connect(&toTimer, SIGNAL(timeout()), &eLoop, SLOT(quit()));

        // Send the message
        m_txMsgRetries = 3;   // Max 3 message retries
        m_txCRCRetries = 3;
        m_txBUSYRetries = 3;
        m_msgService->slotSendMessage(devId, regId, msgWrite, writeData);

        toTimer.setSingleShot(true);
        toTimer.start(500);     // Emergency timeout 500mS
        eLoop.exec();           // Start the local eventloop - Waiting for the communication to complete

        return m_txStatus;
    }
    return SetPortClosed;
}


RegGetStatusTypes IBHandler::readRegister(const quint8 devId, const quint8 regId, QByteArray &readData)
{
    QEventLoop eLoop;
    QTimer toTimer;

    if (m_serialport->isOpen())
    {
        // Hookup the local eventloop
        connect(this, SIGNAL(communicationFinished()), &eLoop, SLOT(quit()));
        connect(&toTimer, SIGNAL(timeout()), &eLoop, SLOT(quit()));

        // Send the message
        m_txMsgRetries = 3;   // Max 3 message retries
        m_txCRCRetries = 3;
        m_txBUSYRetries = 3;
        m_msgService->slotSendMessage(devId, regId, msgRead, QByteArray());

        toTimer.setSingleShot(true);
        toTimer.start(500);     // Emergency timeout 500mS
        eLoop.exec();           // Start the local eventloop - Waiting for the communication to complete

        readData.clear();
        readData.append(m_rxMsgData);
        return m_rxStatus;
    }
    return GetPortClosed;
}


//************************************************************************
//* Helper Functions
//************************************************************************


quint8 IBHandler::GetInt8(const QByteArray &data, int byteIndex)
{
    IBValue ibValue;
    ibValue.All.B0 = (byteIndex+0 < data.size()) ? data.at(byteIndex+0) : 0;
    return ibValue.Int8;
}


void IBHandler::SetInt8(QByteArray &data, quint8 val, int byteIndex)
{
    IBValue ibValue;
    ibValue.Int8 = val;
    adjustSize(data, '\0', sizeof(val), byteIndex);
    data.replace(byteIndex+0, 1, (char*)&ibValue.All.B0, 1);
}


quint16 IBHandler::GetInt16(const QByteArray &data, int byteIndex)
{
    IBValue ibValue;
    ibValue.All.B0 = (byteIndex+0 < data.size()) ? data.at(byteIndex+0) : 0;
    ibValue.All.B1 = (byteIndex+1 < data.size()) ? data.at(byteIndex+1) : 0;
    return ibValue.Int16;
}


void IBHandler::SetInt16(QByteArray &data, quint16 val, int byteIndex)
{
    IBValue ibValue;
    ibValue.Int16 = val;
    adjustSize(data, '\0', sizeof(val), byteIndex);
    data.replace(byteIndex+0, 1, (char*)&ibValue.All.B0, 1);
    data.replace(byteIndex+1, 1, (char*)&ibValue.All.B1, 1);
}


quint32 IBHandler::GetInt32(const QByteArray &data, int byteIndex)
{
    tIBValue ibValue;
    ibValue.All.B0 = (byteIndex+0 < data.size()) ? data.at(byteIndex+0) : 0;
    ibValue.All.B1 = (byteIndex+1 < data.size()) ? data.at(byteIndex+1) : 0;
    ibValue.All.B2 = (byteIndex+2 < data.size()) ? data.at(byteIndex+2) : 0;
    ibValue.All.B3 = (byteIndex+3 < data.size()) ? data.at(byteIndex+3) : 0;
    return ibValue.Int32;
}


void IBHandler::SetInt32(QByteArray &data, quint32 val, int byteIndex)
{
    tIBValue ibValue;
    ibValue.Int32 = val;
    adjustSize(data, '\0', sizeof(val), byteIndex);
    data.replace(byteIndex+0, 1, (char*)&ibValue.All.B0, 1);
    data.replace(byteIndex+1, 1, (char*)&ibValue.All.B1, 1);
    data.replace(byteIndex+2, 1, (char*)&ibValue.All.B2, 1);
    data.replace(byteIndex+3, 1, (char*)&ibValue.All.B3, 1);
}


quint64 IBHandler::GetInt64(const QByteArray &data, int byteIndex)
{
    tIBValue ibValue;
    ibValue.All.B0 = (byteIndex+0 < data.size()) ? data.at(byteIndex+0) : 0;
    ibValue.All.B1 = (byteIndex+1 < data.size()) ? data.at(byteIndex+1) : 0;
    ibValue.All.B2 = (byteIndex+2 < data.size()) ? data.at(byteIndex+2) : 0;
    ibValue.All.B3 = (byteIndex+3 < data.size()) ? data.at(byteIndex+3) : 0;
    ibValue.All.B4 = (byteIndex+4 < data.size()) ? data.at(byteIndex+4) : 0;
    ibValue.All.B5 = (byteIndex+5 < data.size()) ? data.at(byteIndex+5) : 0;
    ibValue.All.B6 = (byteIndex+6 < data.size()) ? data.at(byteIndex+6) : 0;
    ibValue.All.B7 = (byteIndex+7 < data.size()) ? data.at(byteIndex+7) : 0;
    return ibValue.Int64;
}


void IBHandler::SetInt64(QByteArray &data, quint64 val, int byteIndex)
{
    tIBValue ibValue;
    ibValue.Int64 = val;
    adjustSize(data, '\0', sizeof(val), byteIndex);
    data.replace(byteIndex+0, 1, (char*)&ibValue.All.B0, 1);
    data.replace(byteIndex+1, 1, (char*)&ibValue.All.B1, 1);
    data.replace(byteIndex+2, 1, (char*)&ibValue.All.B2, 1);
    data.replace(byteIndex+3, 1, (char*)&ibValue.All.B3, 1);
    data.replace(byteIndex+4, 1, (char*)&ibValue.All.B4, 1);
    data.replace(byteIndex+5, 1, (char*)&ibValue.All.B5, 1);
    data.replace(byteIndex+6, 1, (char*)&ibValue.All.B6, 1);
    data.replace(byteIndex+7, 1, (char*)&ibValue.All.B7, 1);
}


float IBHandler::GetFloat32(const QByteArray &data, int byteIndex)
{
    tIBValue ibValue;
    ibValue.All.B0 = (byteIndex+0 < data.size()) ? data.at(byteIndex+0) : 0;
    ibValue.All.B1 = (byteIndex+1 < data.size()) ? data.at(byteIndex+1) : 0;
    ibValue.All.B2 = (byteIndex+2 < data.size()) ? data.at(byteIndex+2) : 0;
    ibValue.All.B3 = (byteIndex+3 < data.size()) ? data.at(byteIndex+3) : 0;
    return ibValue.Float;
}


void IBHandler::SetFloat32(QByteArray &data, float val, int byteIndex)
{
    tIBValue ibValue;
    ibValue.Float = val;
    adjustSize(data, '\0', sizeof(val), byteIndex);
    data.replace(byteIndex+0, 1, (char*)&ibValue.All.B0, 1);
    data.replace(byteIndex+1, 1, (char*)&ibValue.All.B1, 1);
    data.replace(byteIndex+2, 1, (char*)&ibValue.All.B2, 1);
    data.replace(byteIndex+3, 1, (char*)&ibValue.All.B3, 1);
}


double IBHandler::GetDouble64(const QByteArray &data, int byteIndex)
{
    tIBValue ibValue;
    ibValue.All.B0 = (byteIndex+0 < data.size()) ? data.at(byteIndex+0) : 0;
    ibValue.All.B1 = (byteIndex+1 < data.size()) ? data.at(byteIndex+1) : 0;
    ibValue.All.B2 = (byteIndex+2 < data.size()) ? data.at(byteIndex+2) : 0;
    ibValue.All.B3 = (byteIndex+3 < data.size()) ? data.at(byteIndex+3) : 0;
    ibValue.All.B4 = (byteIndex+4 < data.size()) ? data.at(byteIndex+4) : 0;
    ibValue.All.B5 = (byteIndex+5 < data.size()) ? data.at(byteIndex+5) : 0;
    ibValue.All.B6 = (byteIndex+6 < data.size()) ? data.at(byteIndex+6) : 0;
    ibValue.All.B7 = (byteIndex+7 < data.size()) ? data.at(byteIndex+7) : 0;
    return ibValue.Double;
}


void IBHandler::SetDouble64(QByteArray &data, double val, int byteIndex)
{
    tIBValue ibValue;
    ibValue.Double = val;
    adjustSize(data, '\0', sizeof(val), byteIndex);
    data.replace(byteIndex+0, 1, (char*)&ibValue.All.B0, 1);
    data.replace(byteIndex+1, 1, (char*)&ibValue.All.B1, 1);
    data.replace(byteIndex+2, 1, (char*)&ibValue.All.B2, 1);
    data.replace(byteIndex+3, 1, (char*)&ibValue.All.B3, 1);
    data.replace(byteIndex+4, 1, (char*)&ibValue.All.B4, 1);
    data.replace(byteIndex+5, 1, (char*)&ibValue.All.B5, 1);
    data.replace(byteIndex+6, 1, (char*)&ibValue.All.B6, 1);
    data.replace(byteIndex+7, 1, (char*)&ibValue.All.B7, 1);
}


QString IBHandler::GetLocal8BitString(QByteArray &data, int byteIndex, int length)
{
    return QString::fromLocal8Bit( data.mid(byteIndex, length) );
}


void IBHandler::SetLocal8BitString(QByteArray &data, QString asciiStr, bool appendEOS, int byteIndex, int length)
{
    char nullChar = 0;
    int asciiLnt = (length == -1) ? asciiStr.size() : length;
    int totalLnt = (appendEOS) ? asciiLnt + 1 : asciiLnt;

    adjustSize(data, ' ', totalLnt, byteIndex);
    data.replace(byteIndex, asciiLnt, asciiStr.toLocal8Bit().data(), asciiLnt);
    if (appendEOS)
        data.replace(byteIndex + asciiLnt, 1, &nullChar, 1);
}


QString IBHandler::GetAsciiString(QByteArray &data, int byteIndex, int length)
{
    return QString::fromLatin1( data.mid(byteIndex, length) );
}


void IBHandler::SetAsciiString(QByteArray &data, QString asciiStr, bool appendEOS, int byteIndex, int length)
{
    char nullChar = 0;
    int asciiLnt = (length == -1) ? asciiStr.toLatin1().size() : length;
    int totalLnt = (appendEOS) ? asciiLnt + 1 : asciiLnt;

    adjustSize(data, ' ', totalLnt, byteIndex);
    data.replace(byteIndex, asciiLnt, asciiStr.toLatin1(), asciiLnt);
    if (appendEOS)
        data.replace(byteIndex + asciiLnt, 1, &nullChar, 1);
}


// getStatusMessage - Returns a human readable GET status message based on the provided status
QString IBHandler::GetStatusMessage(RegGetStatusTypes status)
{
    switch (status)
    {
        case GetSuccess:    return "Register read was successfull";
        case GetNacked:     return "Register read was nacked";
        case GetCRCErr:     return "Register read had CRC error";
        case GetTimeout:    return "Register read had timeout";
        case GetComError:   return "Register read had communication error";
        default:            return "Undefined status!!";
    }
}


// getStatusMessage - Returns a human readable SET status message based on the provided status
QString IBHandler::GetStatusMessage(RegSetStatusTypes status)
{
    switch (status)
    {
    case SetSuccess:    return "Register set was successfull";
    case SetNacked:     return "Register set was nacked";
    case SetCRCErr:     return "Register set had CRC error";
    case SetTimeout:    return "Register set had timeout";
    case SetComError:   return "Register set had communication error";
    default:            return "Undefined status!!";
    }
}


QString IBHandler::GetHexString(const QByteArray &hexdata, int startindex, int count)
{
    QString msgStr;
    int endindex;

    if (count < 0)
        endindex = hexdata.size();
    else
        endindex = startindex + count;

    if (endindex > hexdata.size())
        endindex = hexdata.size();

    if (startindex <= hexdata.size())
    {
        for (int n = startindex; n < endindex ; n++)
        {
            msgStr.append(QString::number((quint8)hexdata.at(n),16).rightJustified(2,'0').toUpper());
            msgStr.append("h ");
        }
    }
    return msgStr;
}


// onReceiverStatus - Emitted from the IBMsgService when a message has been collected.
void IBHandler::slotReceiverStatus(quint8 deviceId, quint8 registerId, MsgTypes txMsgType, MsgTypes rxMsgType, QByteArray msgData)
{
    Q_UNUSED(deviceId)
    Q_UNUSED(registerId)

    switch (rxMsgType)
    {
    case msgCRCErr:  // CRC error - Remote module has reported an CRC error - Resend
        if (m_txCRCRetries > 0)
        {
            m_txCRCRetries--;
            //qDebug() << "CRC ERROR TYPE" << msgType << "devId" << deviceId << "regId" << registerId;
            m_msgService->slotResendMessage();
        }
        else
        {
            passRxMessage(txMsgType, rxMsgType, msgData);
        }
        break;

    case msgBusy:  // Busy - Remote module has send a Busy - Resend
        if (m_txBUSYRetries > 0)
        {
            m_txBUSYRetries--;
            //qDebug() << "CRC ERROR TYPE" << msgType << "devId" << deviceId << "regId" << registerId;
            m_msgService->slotResendMessage();
        }
        else
        {
            passRxMessage(txMsgType, rxMsgType, msgData);
        }
        break;

    case msgIntError:  // Communication error - The IBMsgService has not received a complete message within the timeout period - Resend if allowed
        if (m_txMsgRetries > 0)
        {
            m_txMsgRetries--;
            //qDebug() << "Resending STATUS" << msgStatus << "devId" << deviceId << "regId" << registerId;
            m_msgService->slotResendMessage();
        }
        else
        {
            passRxMessage(txMsgType, rxMsgType, msgData);
        }
        break;

    case msgNack:       // Nack - Remote module has send a Nack - Do not resend since the message won't be accepted
    case msgAck:        // Ack - Remote module has send an Ack (Successfull write)
    case msgDatagram:   // Datagram - Remote module has send a Datagram (Successfull read)
    default:
        passRxMessage(txMsgType, rxMsgType, msgData);
    }
}



QStringList IBHandler::getAvailableComports()
{
    QStringList ports;
    foreach (QSerialPortInfo portinfo, QSerialPortInfo::availablePorts())
        ports.append(portinfo.portName());
    return ports;
}


void IBHandler::adjustSize(QByteArray &data, char fillChar, int elementSize, int index)
{
    while (data.size() < index + elementSize)
        data.append(fillChar);
}



// passRxMessage - Pass and process the received message
void IBHandler::passRxMessage(quint8 txMsgType, MsgTypes rxMsgType, QByteArray msgData)
{
    if (txMsgType == msgRead)      // Send, was a read command
    {
        m_rxMsgData = msgData;
        switch (rxMsgType)
        {
        case msgNack:  // Nack
            m_rxStatus = GetNacked;
            break;
        case msgCRCErr:  // CRC error
            m_rxStatus = GetCRCErr;
            break;
        case msgBusy:  // Busy
            m_rxStatus = GetBusy;
            break;
        case msgAck:  // Ack
            m_rxStatus = GetComError; // Protocol error - We should not be able to get an Ack on a read
            break;
        case msgIntError:  // Timeout
            m_rxStatus = GetTimeout;
            break;
        case msgDatagram:  // Datagram - Remote module has send a Datagram (Successfull read)
            m_rxStatus = GetSuccess;
            break;
        default:
            m_rxStatus = GetComError; // Application error - We should never end here
            break;
        }
    }
    else if (txMsgType == msgWrite || txMsgType == msgWriteSET || txMsgType == msgWriteCLR || txMsgType == msgWriteTGL) // Send was a write command
    {
        switch (rxMsgType)
        {
        case msgNack:  // Nack
            m_txStatus = SetNacked;
            break;
        case msgCRCErr:  // CRC error
            m_txStatus = SetCRCErr;
            break;
        case msgBusy:  // Busy
            m_txStatus = SetBusy;
            break;
        case msgAck:  // Ack - (Successfull write)
            m_txStatus = SetSuccess;
            break;
        case msgIntError:  // Timeout
            m_txStatus = SetTimeout;
            break;
        case msgDatagram:  // Datagram
            m_txStatus = SetComError; // Protocol error - We should not be able to get a datagram on a write
            break;
        default:
            m_txStatus = SetComError; // Application error - We should never end here
            break;
        }
    }
    emit communicationFinished();
}
