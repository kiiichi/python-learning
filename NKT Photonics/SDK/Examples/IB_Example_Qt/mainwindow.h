#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include "Interbus/ibhandler.h"

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

private slots:

    void butOpenClose();
    void butReadRegister();
    void butWriteRegisterU8();
    void butWriteRegisterU16();

    // IBHandler slot
    void comportOpened(QString portname, bool opened);

private:
    Ui::MainWindow *ui;

    IBHandler *interbus;



};

#endif // MAINWINDOW_H
