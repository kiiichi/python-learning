import csv
import numpy as np
import pyvisa as visa

# Connect to the oscilloscope
rm = visa.ResourceManager()
oscilloscope = rm.open_resource('TCPIP0::192.168.1.9::inst0::INSTR')

# Set up the oscilloscope
oscilloscope.write(':STOP')  # Stop acquisition
oscilloscope.write(':WAV:SOUR CHAN1')  # Set {D0|...|D15|CHANnel1|...|CHANnel4|MATH1|...|MATH4} as the source of the waveform
oscilloscope.write(':WAV:MODE NORM')  # Set mode to the {NORMal|MAXimum|RAW} waveform
oscilloscope.write(':WAV:FORM ASC')  # Set waveform format to {WORD|BYTE|ASCii}

waveform = oscilloscope.query(':WAV:DATA?')  # Send command to retrieve waveform data
waveform_data = waveform[11:]
print(waveform_data)

# Convert waveform values to floats
waveform_data = np.fromstring(waveform_data, dtype=float, sep=',')

# Save waveform data to a CSV file
with open('waveform.csv', 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(['Time', 'Voltage'])  # Write header
    for i, voltage in enumerate(waveform_data):
        time = i * 1  # Calculate time based on the sample index and time per sample
        writer.writerow([time, voltage])

# Disconnect from the oscilloscope
oscilloscope.close()
