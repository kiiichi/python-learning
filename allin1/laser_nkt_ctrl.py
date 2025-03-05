from NKTMethods.NKTP_DLL import *
from ctypes import *
from parameter_table import PORTNAME_NKT
# from time import sleep

def nkt_read_wavelength(portname=PORTNAME_NKT):
    rdResult, StandardWl = registerReadU32(portname, 1, 0x32, -1)
    rdResult, OffsetWl = registerReadS32(portname, 1, 0x72, -1)
    return (StandardWl + OffsetWl)/10000

# Open the COM port
openResult = openPorts(PORTNAME_NKT, 0, 0)
print('[Laser NKT] Opening the comport:', PortResultTypes(openResult))

if __name__ == '__main__':
    print('[Laser NKT] Wavelength:', nkt_read_wavelength())
    closeResult = closePorts('COM5')
    print('Close the comport:', PortResultTypes(closeResult))