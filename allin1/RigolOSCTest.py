import pyvisa as visa

rm = visa.ResourceManager()
# print(rm.list_resources())
oscilloscope = rm.open_resource('TCPIP0::192.168.1.9::inst0::INSTR')
# print(oscilloscope.query('*IDN?'))  # Query the identification string of the oscilloscope
# oscilloscope.write(':MEASure:ITEM VAVG,CHAN1')
print(oscilloscope.query(':MEASure:ITEM? VAVG,CHAN1'))
print(oscilloscope.query(':MEASure:ITEM? VAVG,CHAN1'))
oscilloscope.close()
oscilloscope.open()
print(oscilloscope.query(':MEASure:ITEM? VAVG,CHAN1'))
oscilloscope.close()
