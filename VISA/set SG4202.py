import pyvisa as visa

# Set basic parameters
frequency = 1000  # Set the frequency in Hz
amplitude = 1  # Set the amplitude in Vpp
offset = 0  # Set the offset in V
phase = 0  # Set the phase in degrees

# Connect to the signal generator
rm = visa.ResourceManager()
print(rm.list_resources())
signal_generator = rm.open_resource('TCPIP0::192.168.1.46::inst0::INSTR')
print(signal_generator.query('*IDN?'))  # Query the identification string of the signal generator

# Set up the signal generator
signal_generator.write(':OUTP1 OFF')  # Turn off output 1
signal_generator.write(':OUTP2 OFF')  # Turn off output 2
signal_generator.write(f':SOUR1:APPL:SIN {frequency}, {amplitude}, {offset}, {phase}')
signal_generator.write(':OUTP1 ON')  # Turn on output 1
