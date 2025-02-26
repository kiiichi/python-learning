#ifndef IBCOMMON_H
#define IBCOMMON_H

#include <QMetaType>

enum RegGetStatusTypes
{
    GetSuccess,
    GetBusy,
    GetNacked,
    GetCRCErr,
    GetTimeout,
    GetComError,
    GetPortClosed,
    GetPortNotFound
};
Q_DECLARE_METATYPE ( RegGetStatusTypes )

enum RegSetStatusTypes : char
{
    SetSuccess,
    SetBusy,
    SetNacked,
    SetCRCErr,
    SetTimeout,
    SetComError,
    SetPortClosed,
    SetPortNotFound
};
Q_DECLARE_METATYPE ( RegSetStatusTypes )

enum MsgTypes : char
{
    msgNack = 0x00,         // Response - Message not understood, not applicable, or not allowed.
    msgCRCErr = 0x01,       // Response - CRC error in received message.
    msgBusy = 0x02,         // Response - Cannot respond at the moment. Module too busy.
    msgAck = 0x03,          // Response - Received query message understood. Write accepted.
    msgRead = 0x04,         // Command  - Read the contents of a register.
    msgWrite = 0x05,        // Command  - Normal write to a register.
    msgWriteSET = 0x06,     // Command  - OR Write - Write 1 or more bits to a register. Set bit(s) for setting bit(s).
    msgWriteCLR = 0x07,     // Command  - NAND Write - Write 1 or more bits to a register. Set bit(s) for clearing bit(s).
    msgDatagram = 0x08,     // Response - Register content returned. Read response.
    msgWriteTGL = 0x09,     // Command  - XOR Write - Write 1 or more bits to a register. Set bit(s) for flipping bit(s).
                            // note: msgWriteSET/CLR/TGL types is not supported on all devices.
    msgIntError = 0xFF      // Internal error flag.
};
Q_DECLARE_METATYPE ( MsgTypes )

enum RxStates : char
{
    RxStStopped,
    RxStHunting_SOT,
    RxStHunting_EOT,
    RxStMessageReady,
    RxStTimeout_Error,
    RxStCRC_Error,
    RxStGarbage_Error,
    RxStOverrun_Error,
    RxStSync_Error
};
Q_DECLARE_METATYPE ( RxStates )


#endif // IBCOMMON_H
