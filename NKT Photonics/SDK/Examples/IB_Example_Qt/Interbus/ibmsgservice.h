#ifndef IBMSGSERVICE_H
#define IBMSGSERVICE_H

#include <QObject>
#include <QPointer>
#include <QSerialPort>
#include <QTimer>
#include <QDebug>
#include "ibcommon.h"

class IBMsgService : public QObject
{
    Q_OBJECT
public:
    explicit IBMsgService(QSerialPort *comport, QObject *parent = 0);

signals:
    void sigReceiverStatus(quint8 deviceId, quint8 registerId, MsgTypes txMsgType, MsgTypes rxMsgType, QByteArray msgData);

public slots:
    void slotSendMessage(quint8 devId, quint8 regId, MsgTypes msgType, QByteArray msgData);
    void slotResendMessage();

private slots:
    void slotRxBytesReceived();
    void slotRxMessageTimeout();
    void slotTxBytesSend(qint64 byteCount);

private:
    QPointer<QSerialPort> wrkPort;
    QTimer rxTimeoutTimer;

    RxStates rxState;
    bool rxEscape;

    int rxMsgTimeout;
    quint8 rxDeviceId;
    quint8 rxRegisterId;

    ushort rxCalcCRC;
    QByteArray rxMsg;

    quint8 txMasterId;
    quint8 txDeviceId;
    quint8 txRegisterId;
    MsgTypes txMsgType;
    QByteArray txMsgData;

    ushort txCalcCRC;
    QByteArray txBuffer;

    ushort calcCRC16(unsigned char data, ushort OldCRC);
    void txMsgAppend(QByteArray *data, bool escParse, bool updCRC);
    void txMsgAppend(unsigned char data, bool escParse, bool updCRC);

    void showMessage(QString header, QByteArray *msg);

};

#endif // IBMSGSERVICE_H
