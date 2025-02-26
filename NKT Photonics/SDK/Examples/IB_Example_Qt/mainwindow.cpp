#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    // Create the Interbus handler
    interbus = new IBHandler(this);
    connect(interbus, SIGNAL(comportOpened(QString,bool)), this, SLOT(comportOpened(QString,bool)));

    // Fill the port combobox with available ports
    ui->cbComports->clear();
    ui->cbComports->addItems( interbus->getAvailableComports() );

    connect(ui->pbOpenClose, SIGNAL(pressed()), this, SLOT(butOpenClose()));

    connect(ui->pbReadRegister, SIGNAL(pressed()), this, SLOT(butReadRegister()));
    connect(ui->pbWriteRegisterU8, SIGNAL(pressed()), this, SLOT(butWriteRegisterU8()));
    connect(ui->pbWriteRegisterU16, SIGNAL(pressed()), this, SLOT(butWriteRegisterU16()));

}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::butOpenClose()
{
    if (interbus->isComportOpen())
        interbus->closeComport();
    else
        interbus->openComport(ui->cbComports->currentText());
}

void MainWindow::butReadRegister()
{
    QByteArray readData;

    RegGetStatusTypes status = interbus->readRegister((quint8)ui->spinBoxDevice->value(), (quint8)ui->spinBoxRegister->value(), readData);
    switch (status)
    {
    case GetSuccess:
        ui->pteStatus->appendPlainText("Read success: " + interbus->GetHexString(readData, 0));
        break;
    case GetBusy:           ui->pteStatus->appendPlainText("Read busy"); break;
    case GetNacked:         ui->pteStatus->appendPlainText("Read nacked"); break;
    case GetCRCErr:         ui->pteStatus->appendPlainText("Read CRC error"); break;
    case GetTimeout:        ui->pteStatus->appendPlainText("Read timeout error"); break;
    case GetComError:       ui->pteStatus->appendPlainText("Read communication error"); break;
    case GetPortClosed:     ui->pteStatus->appendPlainText("Read port closed"); break;
    case GetPortNotFound:   ui->pteStatus->appendPlainText("Read port not found"); break;
    }
}

void MainWindow::butWriteRegisterU8()
{
    QByteArray writeData;

    interbus->SetInt8(writeData, ui->spinBoxWriteValueU8->value(), 0);

    RegSetStatusTypes status = interbus->writeRegister((quint8)ui->spinBoxDevice->value(), (quint8)ui->spinBoxRegister->value(), writeData);
    switch (status)
    {
    case SetSuccess:
        ui->pteStatus->appendPlainText("Write U8 success: " + interbus->GetHexString(writeData, 0));
        break;
    case SetBusy:           ui->pteStatus->appendPlainText("Write U8 busy"); break;
    case SetNacked:         ui->pteStatus->appendPlainText("Write U8 nacked"); break;
    case SetCRCErr:         ui->pteStatus->appendPlainText("Write U8 CRC error"); break;
    case SetTimeout:        ui->pteStatus->appendPlainText("Write U8 timeout error"); break;
    case SetComError:       ui->pteStatus->appendPlainText("Write U8 communication error"); break;
    case SetPortClosed:     ui->pteStatus->appendPlainText("Write U8 port closed"); break;
    case SetPortNotFound:   ui->pteStatus->appendPlainText("Write U8 port not found"); break;
    }
}

void MainWindow::butWriteRegisterU16()
{
    QByteArray writeData;

    interbus->SetInt16(writeData, ui->spinBoxWriteValueU16->value(), 0);

    RegSetStatusTypes status = interbus->writeRegister((quint8)ui->spinBoxDevice->value(), (quint8)ui->spinBoxRegister->value(), writeData);
    switch (status)
    {
    case SetSuccess:
        ui->pteStatus->appendPlainText("Write U16 success: " + interbus->GetHexString(writeData, 0));
        break;
    case SetBusy:           ui->pteStatus->appendPlainText("Write U16 busy"); break;
    case SetNacked:         ui->pteStatus->appendPlainText("Write U16 nacked"); break;
    case SetCRCErr:         ui->pteStatus->appendPlainText("Write U16 CRC error"); break;
    case SetTimeout:        ui->pteStatus->appendPlainText("Write U16 timeout error"); break;
    case SetComError:       ui->pteStatus->appendPlainText("Write U16 communication error"); break;
    case SetPortClosed:     ui->pteStatus->appendPlainText("Write U16 port closed"); break;
    case SetPortNotFound:   ui->pteStatus->appendPlainText("Write U16 port not found"); break;
    }
}

void MainWindow::comportOpened(QString portname, bool opened)
{
    Q_UNUSED(portname)

    ui->cbComports->setEnabled(!opened);
    if (opened)
        ui->pbOpenClose->setText(tr("Close"));
    else
        ui->pbOpenClose->setText(tr("Open"));
}

