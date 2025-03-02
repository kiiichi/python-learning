from NKTMethods.NKTP_DLL import *
from ctypes import *
from time import sleep

# Open the COM port
# Not nessesary, but would speed up the communication, since the functions does
# not have to open and close the port on each call
openResult = openPorts('COM5', 0, 0)
print('Opening the comport:', PortResultTypes(openResult))

# wrResult = registerWriteU8('COM5', 1, 0x30, 1, -1) 
# print('Turn on emission:', RegisterResultTypes(wrResult))

sleep(2.0)

rdResult, StandardWl = registerReadU32('COM5', 1, 0x32, -1)
print('Standard wavelength:', StandardWl, RegisterResultTypes(rdResult))

rdResult, OffsetWl = registerReadS32('COM5', 1, 0x72, -1)
print('Offset wavelength:', OffsetWl, 'Actual wavelength:', StandardWl + OffsetWl, RegisterResultTypes(rdResult))

rdResult, Temperature = registerReadS16('COM5', 1, 0x1C, -1)
print('Temperature:', Temperature, RegisterResultTypes(rdResult))

# wrResult = registerWriteU8('COM5', 1, 0x30, 0, -1) 
# print('Turn off emission:', RegisterResultTypes(wrResult))

# Close the Internet port
closeResult = closePorts('COM5')
print('Close the comport:', PortResultTypes(closeResult))