from time import sleep
from toptica.lasersdk.client import Client, NetworkConnection
from toptica.lasersdk.client import UserLevel, Subscription, Timestamp, SubscriptionValue

def ReadVol():
    client.get('laser1:dl:pc:voltage-set', float)
DLCPRO_CONNECTION = '192.168.1.29'


with Client(NetworkConnection(DLCPRO_CONNECTION)) as client:

    print(client.get('uptime-txt', str),"===== Connected Device =====")
    # client.set('system-label', 'the 1st laser')
    print("This is a {} with serial number {}.\nLabel is '{}'".format(
        client.get('system-type'), client.get('serial-number'), client.get('system-label', str)))
    
    LastSetVol=client.get('laser1:dl:pc:voltage-set', float)
    LastSetWl=client.get('laser1:ctl:wavelength-set', float)
    
    SetVol=80.000
    SetWl=1549.89

    client.set('laser1:dl:pc:voltage-set', SetVol)
    client.set('laser1:ctl:wavelength-set', SetWl)
    sleep(1) #等待网络延迟，可以加入判定
    sleep(max(0.02*abs(SetVol-LastSetVol),0.2*abs(SetWl-LastSetWl))) 

    print("Set Voltage: {} Actual Voltage: {}.\n".format(
        client.get('laser1:dl:pc:voltage-set', float), client.get('laser1:dl:pc:voltage-act',float)))
    
    print("Set Wavelength: {} Actual Wavelength: {}.\n".format(
        client.get('laser1:ctl:wavelength-set', float), client.get('laser1:ctl:wavelength-act',float)))
    
print()
