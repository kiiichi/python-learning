from toptica.lasersdk.dlcpro.v3_0_1 import DLCpro, NetworkConnection

# This example prints the current uptime of a DLC pro. It does so by importing
# two classes: DLCpro is the device class (for firmware version 2.2.0) and
# NetworkConnection is the connection class for Ethernet-capable devices.

# Note: The with-statement automatically calls open() and close()
#       of the connection class at the appropriate times.

with DLCpro(NetworkConnection('192.168.1.29')) as dlc:
    print(dlc.uptime_txt.get())

