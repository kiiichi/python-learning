#ifndef IBHANDLER_H
#define IBHANDLER_H

#include <QObject>
#include <QByteArray>
#include <QString>
#include <QStringList>
#include <QSerialPortInfo>
#include <QSerialPort>
#include "ibcommon.h"
#include "ibmsgservice.h"

class IBHandler : public QObject
{
    Q_OBJECT
public:
    explicit IBHandler(QObject *parent = 0);
    ~IBHandler();

    QStringList getAvailableComports();
    bool openComport(QString comport);
    void closeComport();
    bool isComportOpen();

    RegSetStatusTypes writeRegister(const quint8 devId, const quint8 regId, const QByteArray &writeData);

    RegGetStatusTypes readRegister(const quint8 devId, const quint8 regId, QByteArray &readData);


    // Helper Functions
    quint8 GetInt8(const QByteArray &data, int byteIndex);
    void SetInt8(QByteArray &data, quint8 val, int byteIndex);

    quint16 GetInt16(const QByteArray &data, int byteIndex);
    void SetInt16(QByteArray &data, quint16 val, int byteIndex);

    quint32 GetInt32(const QByteArray &data, int byteIndex);
    void SetInt32(QByteArray &data, quint32 val, int byteIndex);

    quint64 GetInt64(const QByteArray &data, int byteIndex);
    void SetInt64(QByteArray &data, quint64 val, int byteIndex);

    float GetFloat32(const QByteArray &data, int byteIndex);
    void SetFloat32(QByteArray &data, float val, int byteIndex);

    double GetDouble64(const QByteArray &data, int byteIndex);
    void SetDouble64(QByteArray &data, double val, int byteIndex);

    QString GetLocal8BitString(QByteArray &data, int byteIndex, int length = -1);
    void SetLocal8BitString(QByteArray &data, QString asciiStr, bool appendEOS, int byteIndex, int length = -1);

    QString GetAsciiString(QByteArray &data, int byteIndex, int length = -1);
    void SetAsciiString(QByteArray &data, QString asciiStr, bool appendEOS, int byteIndex, int length = -1);

    QString GetStatusMessage(RegGetStatusTypes status);
    QString GetStatusMessage(RegSetStatusTypes status);

    QString GetHexString(const QByteArray &hexdata, int startindex, int count = -1);

signals:
    void comportOpened(QString portname, bool opened);

    void communicationFinished();

private slots:
    void slotReceiverStatus(quint8 deviceId, quint8 registerId, MsgTypes txMsgType, MsgTypes rxMsgType, QByteArray msgData);

private:
    QSerialPort *m_serialport;
    IBMsgService *m_msgService;

    int m_txMsgRetries;
    int m_txCRCRetries;
    int m_txBUSYRetries;

    quint8 m_txDevId;
    quint8 m_txRegId;
    QByteArray m_txMsgData;
    QByteArray m_rxMsgData;

    //QByteArray readData;
    RegGetStatusTypes m_rxStatus;

    //QByteArray writeData;
    RegSetStatusTypes m_txStatus;



    void adjustSize(QByteArray &data, char fillChar, int elementSize, int index);

    typedef struct
    {
        quint8 B0;
        quint8 B1;
        quint8 B2;
        quint8 B3;
        quint8 B4;
        quint8 B5;
        quint8 B6;
        quint8 B7;
    } tAll;

    typedef union tIBValue
    {
      tAll All;
      quint8 Int8;
      quint16 Int16;
      quint32 Int32;
      quint64 Int64;
      float Float;
      double Double;
      tIBValue() : Int64(0) {}
    } IBValue;

    void passRxMessage(quint8 txMsgType, MsgTypes rxMsgType, QByteArray msgData);
};

#endif // IBHANDLER_H
