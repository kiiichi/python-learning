import pyvisa as visa
from time import sleep
import csv

if __name__ == '__main__':

    # PSG test
    ip = '192.168.1.8'
    rm = visa.ResourceManager()
    print(rm.list_resources())
    SA = rm.open_resource('GPIB0::18::INSTR')
    print(SA.query('*IDN?'))
    SA.write(':INPut:COUPling DC')
    print(SA.query(':INPut:COUPling?'))
    # sleep(0.1)
    SA.write(':SENSe:FREQuency:STARt 10 Hz')
    SA.write(':SENSe:FREQuency:STOP 10 kHz')
    # SA.write(':SENSe:BANDwidth 1 kHz')
    SA.write(':DISPlay:WINDow1:TRACe:Y:SCALe:RLEVel -100 dBm')
    SA.write(':TRACe1:UPDate ON')
    SA.write(':TRACe1:DISPlay ON')
    # SA.write(':TRACe2:UPDate OFF')
    # SA.write(':TRACe2:DISPlay OFF')
    # SA.write(':TRACe3:UPDate OFF')
    # SA.write(':TRACe3:DISPlay OFF')
    # SA.write(':TRACe4:UPDate OFF')
    # SA.write(':TRACe4:DISPlay OFF')
    SA.write(':BAND:RESolution:AUTO ON')
    SA.write(':BAND:VIDeo:AUTO ON')
    SA.write(':BAND:VIDeo 1Hz')
    # print(SA.query(':DISPlay:WINDow1:TRACe:Y:SCALe:PDIVision 10DB'))
    print(SA.query(':MMEMory:CDIRectory?'))

    # SA.write(':TRACe1:UPDate OFF')
    raw_data = SA.query(':TRACe1:DATA? TRACE1')

    data = [float(num) for num in raw_data.split(',')]
    print(raw_data)
    print(data)
    # Write data to CSV file
    with open('data.csv', 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerows(data)
