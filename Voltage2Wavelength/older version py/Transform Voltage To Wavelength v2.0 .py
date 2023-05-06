import pandas as pd
import tkinter as tk
from tkinter import filedialog

def interpolate_voltage_to_wavelength(voltage, reference_table):
    """Interpolate the wavelength value for a given voltage value using the reference table. Can be modify by interpolate module in SciPy. Details in 'https://zhuanlan.zhihu.com/p/136700122'
    
    Need a reference table and a voltage, return interpolated_wavelength
    """

    closest_voltage_below = max(filter(lambda v: v <= voltage, reference_table.keys()), default=None)
    closest_voltage_above = min(filter(lambda v: v >= voltage, reference_table.keys()), default=None)

    # If the two closest voltage values are the same, return the corresponding wavelength value without interpolation
    if closest_voltage_below == closest_voltage_above:
        return reference_table[closest_voltage_below]
    # If the input voltage is outside the range of the reference table, return None
    if closest_voltage_below is None or closest_voltage_above is None: 
        return None
    
    closest_wavelength_below = reference_table[closest_voltage_below]
    closest_wavelength_above = reference_table[closest_voltage_above]
    fraction = (voltage - closest_voltage_below) / (closest_voltage_above - closest_voltage_below)
    interpolated_wavelength = closest_wavelength_below + fraction * (closest_wavelength_above - closest_wavelength_below)
    return interpolated_wavelength


""" Genarate Reference Dictionary """
# Import the Excel file as a pandas DataFrame
reference_data = pd.read_csv('reference_data.csv')

# Transform the DataFrame into a dictionary where the keys are the voltage values and the values are the wavelength values
reference_table = dict(zip(reference_data['voltage'], reference_data['wavelength']))


""" Example usage """
voltage_values1 = [1.25, 2.8, 142]
for voltage in voltage_values1:
    wavelength = interpolate_voltage_to_wavelength(voltage, reference_table)
    print(f"Input voltage: {voltage}, Output wavelength: {wavelength}")


""" Input, Transform, and Output """
arc_factor = 1
set_voltage = 80
set_wavelength = 1550.
# create the Tkinter root window
root = tk.Tk()
root.withdraw() # hide the root window

# show the file dialog box and get the selected file
file_path = filedialog.askopenfilename()

# get the flie name and the folder path and containing the file
file_name = file_path.rsplit('/', 1)[1] # assuming Unix-style path separator
folder_path = file_path.rsplit('/', 1)[0]  

df = pd.read_csv(file_path, names=['time', 'power', 'voltage_scope'], skiprows=12)
voltage_actual_values = (df['voltage_scope']*arc_factor+set_voltage).tolist() # Convert the voltage values to a list
df['voltage_actual'] = voltage_actual_values
# Interpolate the corresponding wavelength values
wavelength_values = [interpolate_voltage_to_wavelength(v, reference_table)+set_wavelength for v in voltage_actual_values]

# Write the results to a new CSV file
df['wavelength'] = wavelength_values
df.to_csv(f'{folder_path}/refined_{file_name}', index=False)

print('refined file saved')

