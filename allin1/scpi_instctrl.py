import pyvisa as visa
from parameter_table import HOSTNAME_PSG, HOSTNAME_DLCPRO1, HOSTNAME_DLCPRO2, HOSTNAME_RIGOLOSC
from toptica.lasersdk.client import Client, NetworkConnection

def ctrl_toptica1(wl):
    with Client(NetworkConnection(HOSTNAME_DLCPRO1)) as client:
        client.set('laser1:ctl:wavelength-set', wl)
        client.set('laser1:scan:offset', 80)
def ctrl_toptica2(wl):
    with Client(NetworkConnection(HOSTNAME_DLCPRO2)) as client:
        client.set('laser1:ctl:wavelength-set', wl)
        client.set('laser1:scan:offset', 80)
def ctrl_psg(freq, power):
    rm = visa.ResourceManager()
    PSG = rm.open_resource('TCPIP0::' + HOSTNAME_PSG + '::inst0::INSTR')
    PSG.write(':SOURce:FREQuency:FIXed ' + str(freq) + 'GHZ')
    PSG.write(':SOURce:POWer:LEVel:IMMediate:AMPLitude ' + str(power) + 'DBM')
    PSG.write(':OUTPut:STATe ON')
    PSG.close()

with Client(NetworkConnection(HOSTNAME_DLCPRO1)) as client:
    print('DLCPRO1 Connected: '+ client.get('uptime-txt', str))
with Client(NetworkConnection(HOSTNAME_DLCPRO2)) as client:
    print('DLCPRO2 Connected: '+ client.get('uptime-txt', str))
rm = visa.ResourceManager()
PSG = rm.open_resource('TCPIP0::' + HOSTNAME_PSG + '::inst0::INSTR')
print('PSG Connected: '+ PSG.query('*IDN?'))
PSG.close()

if __name__ == '__main__':

    # # PSG test
    # ip = '192.168.1.8'
    # rm = visa.ResourceManager()
    # print(rm.list_resources())
    # PSG = rm.open_resource('TCPIP0::' + ip + '::inst0::INSTR')
    # print(PSG.query('*IDN?'))
    # PSG.write(':SOURce:FREQuency:FIXed 37GHZ')
    # PSG.write(':SOURce:POWer:LEVel:IMMediate:AMPLitude -10DBM')
    # PSG.write(':OUTPut:STATe ON')
    # PSG.close()

    # Toptica test
    ctrl_toptica2(1550.12)