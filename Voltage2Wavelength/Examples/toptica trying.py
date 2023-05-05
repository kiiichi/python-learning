from time import sleep
from toptica.lasersdk.client import Client, NetworkConnection
from toptica.lasersdk.client import UserLevel, Subscription, Timestamp, SubscriptionValue

DLCPRO_CONNECTION = '192.168.1.29'


with Client(NetworkConnection(DLCPRO_CONNECTION)) as client:
    print(client.get('uptime-txt', str),"===== Connected Device =====")
    # client.set('system-label', 'the 1st laser')
    print("This is a {} with serial number {}.\nLabel is '{}'".format(
        client.get('system-type'), client.get('serial-number'), client.get('system-label', str)))
    
    '''随便试点啥'''
    # client.set('laser1:dl:pc:external-input:enabled',False)

print()