from NKTMethods.NKTP_DLL import *
from ctypes import *
from parameter_table import PORTNAME_NKT
from time import sleep

# Open the COM port
openResult = openPorts(PORTNAME_NKT, 0, 0)
print('[Laser NKT] Opening the comport:', PortResultTypes(openResult))
rdResult, NKTStandardWl = registerReadU32(PORTNAME_NKT, 1, 0x32, -1)
print('[Laser NKT] Standard wavelength:', NKTStandardWl, RegisterResultTypes(rdResult))

class LaserNkt:
    def read_wavelength(portname=PORTNAME_NKT):
        rdResult, OffsetWl = registerReadS32(portname, 1, 0x72, -1)
        return (NKTStandardWl + OffsetWl)/10000

    def turn_on(portname=PORTNAME_NKT):
        wrResult = registerWriteU8(portname, 1, 0x30, 1, -1)
        return RegisterResultTypes(wrResult)

    def turn_off(portname=PORTNAME_NKT):
        wrResult = registerWriteU8(portname, 1, 0x30, 0, -1) 
        return RegisterResultTypes(wrResult)

    def read_status(portname=PORTNAME_NKT):
        rdResult, status = registerReadU16(portname, 1, 0x66, -1)
        status = format(status, '016b')
        if status[-1] == '1':
            return 'Laser ON'
        elif status[-1] == '0':
            return 'Laser OFF'
        else:
            return 'Unknown ON/OFF'
        
    def read_power_mw(portname=PORTNAME_NKT):
        rdResult, power = registerReadU16(portname, 1, 0x17, -1)
        return power/100
        
    def read_power_dbm(portname=PORTNAME_NKT):
        rdResult, power = registerReadS16(portname, 1, 0x90, -1)
        return power/100

    def write_wl(wavelength, portname=PORTNAME_NKT):
        offset_wavelength = int(wavelength*10000 - NKTStandardWl)
        wrResult = registerWriteS16(portname, 1, 0x2a, offset_wavelength, -1)
        return RegisterResultTypes(wrResult)

if __name__ == '__main__':
    print('[Laser NKT] Wavelength:', nkt_read_wavelength())
    print('[Laser NKT] Turn on:', nkt_turn_on())
    sleep(1.0)
    print('[Laser NKT] Status:', nkt_read_status())
    print('[Laser NKT] Power:', nkt_read_power_mw())
    print('[Laser NKT] Power:', nkt_read_power_dbm())
    print('[Laser NKT] Turn off:', nkt_turn_off())
    sleep(2.0)
    print('[Laser NKT] Status:', nkt_read_status())
    print('[Laser NKT] Power:', nkt_read_power_mw())
    print('[Laser NKT] Power:', nkt_read_power_dbm())
    closeResult = closePorts('COM5')
    print('Close the comport:', PortResultTypes(closeResult))