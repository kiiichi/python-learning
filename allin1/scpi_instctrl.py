import pyvisa as visa
from connection_table import HOSTNAME_PSG

def ctrl_psg(freq, power):
    rm = visa.ResourceManager()
    PSG = rm.open_resource('TCPIP0::' + HOSTNAME_PSG + '::inst0::INSTR')
    PSG.write(':SOURce:FREQuency:FIXed ' + str(freq) + 'GHZ')
    PSG.write(':SOURce:POWer:LEVel:IMMediate:AMPLitude ' + str(power) + 'DBM')
    PSG.write(':OUTPut:STATe ON')
    PSG.close()

if __name__ == '__main__':

    # PSG test
    ip = '192.168.1.8'
    rm = visa.ResourceManager()
    print(rm.list_resources())
    PSG = rm.open_resource('TCPIP0::' + ip + '::inst0::INSTR')
    print(PSG.query('*IDN?'))
    PSG.write(':SOURce:FREQuency:FIXed 37GHZ')
    PSG.write(':SOURce:POWer:LEVel:IMMediate:AMPLitude -10DBM')
    PSG.write(':OUTPut:STATe ON')
    PSG.close()
