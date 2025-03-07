import pyvisa as visa
from parameter_table import HOSTNAME_RIGOLOSC

rm = visa.ResourceManager()
print(rm.list_resources())
oscilloscope = rm.open_resource(HOSTNAME_RIGOLOSC)
# print(oscilloscope.query('*IDN?'))  # Query the identification string of the oscilloscope
# oscilloscope.write(':MEASure:ITEM VAVG,CHAN1')
print(oscilloscope.query(':MEASure:ITEM? VAVG,CHAN1'))
print(oscilloscope.query(':MEASure:ITEM? VAVG,CHAN1'))
oscilloscope.close()
oscilloscope.open()
print(oscilloscope.query(':MEASure:ITEM? VAVG,CHAN1'))
oscilloscope.close()
