"""
from 'get data from multich v2.0.py'
"""

import csv
import time
import numpy as np
import pyvisa as visa
import tkinter as tk
from tkinter import filedialog

def osc_ask_data(channels=[1,2,3], memory_depth='100k', /, oscilloscope_address='TCPIP0::192.168.1.9::inst0::INSTR'):
    '''Used to get data from oscilloscope. Input file_name or not to decide whether to save data to a csv file.

    Need channels, memory_depth, file_name, oscilloscope_address, return waveform_data
    '''

    file_name = input("Please enter the name for the CSV file (or press enter to skip saving): ")

    # Connect to the oscilloscope
    rm = visa.ResourceManager()
    print(rm.list_resources())
    oscilloscope = rm.open_resource(oscilloscope_address)
    print(oscilloscope.query('*IDN?'))  # Query the identification string of the oscilloscope
    oscilloscope.chunk_size = 1024 * 1024  # Set a larger chunk size (adjust as needed)

    # Set up the oscilloscope
    oscilloscope.write(f':ACQ:MDEP {memory_depth}')  # Set the memory depth
    time.sleep(1)
    oscilloscope.write(':STOP')  # Stop acquisition
    oscilloscope.write(':WAV:MODE RAW')  # Set mode to the {NORMal|MAXimum|RAW} waveform
    oscilloscope.write(':WAV:FORM BYTE')  # Set waveform format to {WORD|BYTE|ASCii}
    oscilloscope.write(':WAV:POIN:MODE RAW')  # Set the number of points in the waveform record to RAW

    # Calculate time array and initialize waveform_data with it
    preamble = oscilloscope.query(':WAV:PRE?').split(',')
    num_samples = int(preamble[2])
    time_per_sample = float(preamble[4])
    x_origin = float(preamble[5])
    time_array = np.array([x_origin + i * time_per_sample for i in range(num_samples)])
    waveform_data = [time_array]

    # Retrieve waveform data from each channel
    for channel in channels:
        print(f"Getting data from Channel {channel}...")
        oscilloscope.write(f':WAV:SOUR CHAN{channel}')  # Set source of the waveform
        waveform_raw = oscilloscope.query_binary_values(':WAV:DATA?', datatype='B', container=np.array)  # Retrieve binary waveform data
        preamble = oscilloscope.query(':WAV:PRE?').split(',')
        volt_scale = float(preamble[7])
        volt_offset = float(preamble[8])
        y_reference = float(preamble[9])
        waveform_voltage = (waveform_raw.astype(float) - volt_offset - y_reference) * volt_scale 
        waveform_data.append(waveform_voltage)

    if file_name:
        # choose a folder to save the data
        root = tk.Tk()
        root.withdraw()  # hide the root window
        folder_path = filedialog.askdirectory()
        # Save waveform data to a CSV file
        print('Writing CSV...')
        BUFFER_SIZE = 1000000  # Adjust the buffer size as needed
        with open(f'{folder_path}/{file_name}.csv', 'w', newline='') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(['Time'] + [f'Channel {channel}' for channel in channels])  # Write header
            for row in zip(*waveform_data):  # Transpose and write
                writer.writerow(row)
        print('CSV writing Done')
        # Save the screenshot
        print('Saving screenshot...')
        oscilloscope.write(':SAVE:IMAGe:TYPE TIFF')
        oscilloscope.write(f':SAVE:IMAGe D:\{file_name}.tiff')


    # Disconnect from the oscilloscope
    oscilloscope.write(':RUN')
    oscilloscope.close()
    print('OSC operation Done\n')

    return waveform_data

if __name__ == '__main__':
    oscilloscope_address = 'TCPIP0::192.168.1.9::inst0::INSTR'
    rm = visa.ResourceManager()
    print(rm.list_resources())
    oscilloscope = rm.open_resource(oscilloscope_address)
    print(oscilloscope.query('*IDN?'))  # Query the identification string of the oscilloscope
    oscilloscope.write(':SOURce1:FUNCtion:SHApe DC')
    print(oscilloscope.query(':SOURce1:FUNCtion:SHApe?'))
    oscilloscope.write(':SOURce1:VOLTage:LEVel:IMMediate:OFFSet 0.5')
    
    oscilloscope.close()