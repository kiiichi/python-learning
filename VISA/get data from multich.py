import csv
import time
import numpy as np
import pyvisa as visa

def retrieve_and_save_waveform(file_name = 'waveform.csv', channels = [2,3,4], memory_depth = '100k', oscilloscope_address = 'TCPIP0::192.168.1.9::inst0::INSTR'):
   

    # # Set basic file parameters
    # file_name = 'waveform.csv'  # Set the file name
    # channels = [2,3,4]  # Set the channels to retrieve data from
    # memory_depth = '100k'  # Set the memory depth to {AUTO|1k|10k|100k|1M|10M|25M|50M}
    # oscilloscope_address = 'TCPIP0::192.168.1.9::inst0::INSTR'

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

    # Retrieve waveform data from each channel
    waveform_data = []
    volt_scales = []
    volt_offsets = []
    for channel in channels:
        print(f"Getting data from Channel {channel}...\n")
        oscilloscope.write(f':WAV:SOUR CHAN{channel}')  # Set {D0|...|D15|CHANnel1|...|CHANnel4|MATH1|...|MATH4} as the source of the waveform
        preamble = oscilloscope.query(':WAV:PRE?').split(',')
        time_per_sample = float(preamble[4])
        x_origin = float(preamble[5])
        volt_scale = float(preamble[7])
        volt_offset = float(preamble[8])
        y_reference = float(preamble[9])
        waveform_raw = oscilloscope.query_binary_values(':WAV:DATA?', datatype='B', container=np.array)  # Retrieve binary waveform data
        waveform_data.append((waveform_raw.astype(float) - volt_offset - y_reference) * volt_scale )  # Convert waveform values to voltage
        volt_scales.append(volt_scale)  # Save the volt scale and offset for each channel
        volt_offsets.append(volt_offset)

    # Save waveform data to a CSV file
    print('Writing CSV...\n')
    BUFFER_SIZE = 1000000  # Adjust the buffer size as needed
    with open(f'data\{file_name}', 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['Time'] + [f'Channel {channel}' for channel in channels])  # Write header
        buffer = []
        num_samples = min(len(data) for data in waveform_data)
        for i in range(num_samples):
            sample_time = x_origin + i * time_per_sample  # Calculate time based on the sample index and time per sample
            row = [sample_time] + [data[i] for data in waveform_data]
            buffer.append(row)
            if len(buffer) >= BUFFER_SIZE:
                writer.writerows(buffer)  # Write the buffered rows to the file
                buffer = []
        if buffer:
            writer.writerows(buffer)  # Write any remaining buffered rows

    # Disconnect from the oscilloscope
    oscilloscope.write(':RUN')
    oscilloscope.close()
    print('OSC operation Done')

retrieve_and_save_waveform('custom_waveform.csv', [1, 2], '1k')