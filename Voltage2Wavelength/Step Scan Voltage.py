from time import sleep
from toptica.lasersdk.client import Client, NetworkConnection
from toptica.lasersdk.client import UserLevel, Subscription, Timestamp, SubscriptionValue

def TopticaSleep(ExtraTime=0):
    """Automatically set toptica laser sleep time for tuning voltage or wavelength.

    The variables MUST be defined: SetVol, SetWl, LastSetVol, LastSetWl
    """
    sleep(1) # Waiting for reaction, can be modified by adding a Callback
    sleep(max(0.02*abs(SetVol-LastSetVol),0.2*abs(SetWl-LastSetWl))) 
    sleep(ExtraTime)
def ReadVolSet():
    """Simplify the operation for reading 'laser1:dl:pc:voltage-set'.

    No output
    """
    return client.get('laser1:dl:pc:voltage-set', float)
def ReadVolAct():
    """Simplify the operation for reading 'laser1:dl:pc:voltage-act'.

    No output
    """
    return client.get('laser1:dl:pc:voltage-act',float)
def ReadWlSet():
    """Simplify the operation for reading 'laser1:ctl:wavelength-set'.

    No output
    """
    return client.get('laser1:ctl:wavelength-set', float)
def ReadWlAct():
    """Simplify the operation for reading 'laser1:ctl:wavelength-act'.

    No output
    """
    return client.get('laser1:ctl:wavelength-act', float)
def WriteVol(SetVol=80.):
    """Simplify the operation for writing 'laser1:dl:pc:voltage-set'
    
    Default Voltage is 80"""
    client.set('laser1:dl:pc:voltage-set', SetVol)
def WriteWl(SetWl=1550.):
    """Simplify the operation for writing 'laser1:ctl:wavelength-set'
    
    Default  Wavelength is 1550"""
    client.set('laser1:ctl:wavelength-set', SetWl)

DLCPRO_CONNECTION = '192.168.1.29'

with Client(NetworkConnection(DLCPRO_CONNECTION)) as client:

    """ read information """
    print(client.get('uptime-txt', str),"===== Connected Device =====")
    # client.set('system-label', 'the 1st laser')
    print("This is a {} with serial number {}.\nLabel is '{}'".format(
        client.get('system-type'), client.get('serial-number'), client.get('system-label', str)))
    LastSetVol=ReadVolSet()
    LastSetWl=ReadWlSet()

    """ Setting Scan Parameter """
    StartVol=0.000
    StopVol=140
    ScanStepVol=0.1
    SetWl=1550.

    """ prepare to scan """
    SetVol=StartVol
    WriteVol(SetVol)
    WriteWl(SetWl)
    TopticaSleep()
    
    """ start scan """
    input("Press any button to start...")
    client.set('laser1:dl:pc:external-input:enabled',False)
    while SetVol <= StopVol:
        WriteVol(SetVol)
        LastSetVol=ReadVolSet()
        TopticaSleep(0.5)
        SetVol = SetVol + ScanStepVol