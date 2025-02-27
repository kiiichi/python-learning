from NKTMethods.NKTP_DLL import *
from ctypes import *
from time import sleep

portData = {}

# Here we define the PortStatusCallback handler
#----------------------------------------------------------------------------------------------------------------------------------
def PortStatusCallback(portname, status, curScanAdr, maxScanAdr, foundType):
    #if (status == 0):   #  //!<  0 - Unknown status.
    if (status == 1):   #  //!<  1 - The port is opening.
        print(portname, ' Opening')
    if (status == 2):   #  //!<  2 - The port is now open.
        print(portname, ' Opened')
    if (status == 3):   #  //!<  3 - The port open failed.
        print(portname, ' Open failed!!')
    if (status == 4):   #  //!<  4 - The port scanning is started.
        print(portname, ' Buscanning started')
    #if (status == 5):   #  //!<  5 - The port scanning progress.
    if (status == 6):   #  //!<  6 - The port scan found a device.
        portData.setdefault(portname,[]).append([curScanAdr,foundType])
    if (status == 7):   #  //!<  7 - The port scanning ended.
        print(portname, ' Buscanning ended')
    if (status == 8):   #  //!<  8 - The port is closing.
        print(portname, ' Closing')
    if (status == 9):   #  //!<  9 - The port is now closed.
        print(portname, ' Closed')
    #if (status == 10):  #  //!< 10 - The port is open and ready.
        
    #print('PortStatusCallback - portname:', portname, 'status', status, 'curScanAdr', curScanAdr, 'maxScanAdr', maxScanAdr, 'foundType', foundType)

# Create a reference to the PortStatusCallback function above, this is very important to avoid garbage collection
PortStatusCallbackPtr = portStatusCallbackFuncPtr(PortStatusCallback)

# Set the callback function pointers
setCallbackPtrPortInfo(PortStatusCallbackPtr)


print('Find modules on all existing and accessible ports - Might take a few seconds to complete.....')
print('Scanning following ports:', getAllPorts())

# Use the openPorts function with Auto & Live settings. This will scan and detect modules
# on all ports returned by the getAllPorts function.
# Please note that a port being in use by another application, will show up in this list but will
# not show any devices due to this port being inaccessible.
openPorts(getAllPorts(), 1, 1)

# Traverse the portData dictionary and retrieve found modules
print('Following ports has modules:')
for portName in portData.keys():
    deviceList = portData[portName]
    for device in deviceList:
        print('Comport:',portName,'Device type:',"0x%0.2X" % device[1],'at address:',device[0])

# Close all ports
closePorts('')


# Open the COM port
# Not nessesary, but would speed up the communication, since the functions does
# not have to open and close the port on each call
openResult = openPorts('COM5', 0, 0)
print('Opening the comport:', PortResultTypes(openResult))

# Example - Reading of the Firmware Revision register 0x64(regId) in BASIK (K1x2) at address 8 (devId)
# index = 2, because the str starts at byte index 2
rdResult, FWVersionStr = registerReadAscii('COM5', 1, 0x64, 2)
print('Reading firmware version str:', FWVersionStr, RegisterResultTypes(rdResult))

# Example - Turn on emission on BASIK (K1x2) by setting register 0x30 = 1
# See SDK Instruction Manual page 41
wrResult = registerWriteU8('COM5', 1, 0x30, 1, -1) 
print('Turn on emission:', RegisterResultTypes(rdResult))

print('sleeping for 4 seconds')
sleep(4.0)

# Example get serial number str
rdResult, serial = deviceGetModuleSerialNumberStr('COM5', 1)
print('Serial:', serial, DeviceResultTypes(rdResult))
      
# Example - Turn off emission on BASIK (K1x2) by setting register 0x30 = 0
# See SDK Instruction Manual page 41
wrResult = registerWriteU8('COM5', 1, 0x30, 0, -1) 
print('Turn off emission:', RegisterResultTypes(wrResult))

# Close the Internet port
closeResult = closePorts('COM5')
print('Close the comport:', PortResultTypes(closeResult))

