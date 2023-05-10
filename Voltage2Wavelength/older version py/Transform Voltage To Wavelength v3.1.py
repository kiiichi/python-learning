import pandas as pd
import tkinter as tk
from tkinter import filedialog
import numpy as np
from scipy.optimize import curve_fit
import matplotlib.pyplot as plt
import warnings


'''Input Parameters'''
arc_factor = 0.2
set_voltage = 74.7
set_wavelength = 1549.97684

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
reference_data = pd.read_csv('reference_data_1.csv')

# Transform the DataFrame into a dictionary where the keys are the voltage values and the values are the wavelength values
reference_table = dict(zip(reference_data['voltage'], reference_data['wavelength']))


""" Example usage """
voltage_values1 = [1.25, 2.8, 142]
for voltage in voltage_values1:
    wavelength = interpolate_voltage_to_wavelength(voltage, reference_table)
    print(f"Input voltage: {voltage}, Output wavelength: {wavelength}")


""" Input, Transform, and Output """
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


""" Curve Fitting """
# Extract the two columns of interest into NumPy arrays
x = df['time'].values
y = df['power'].values

# Define the math function you want to fit
def Lorentz(x,y0,A,xc,w):
    y = y0 + (2*A/np.pi)*(w/(4*(x-xc)**2 + w**2))
    return y

# Fit the function to the data using SciPy's curve_fit method

y0 = np.average(y[0:1000])

A = 0

min_y = min(y)
position_xc = df.index[df['power'] == min_y].tolist()[0]
xc = df['time'][position_xc]

half_power = min_y + (y0-min_y)/2
half_power_point = min(y, key=lambda v: abs(v - half_power))
position_half_power = df.index[df['power'] == half_power_point].tolist()[0]
w = df['time'][position_half_power] - xc

popt, pcov = curve_fit(Lorentz, x, y, p0=[y0,A,xc,w], maxfev=100000)
# popt, pcov = curve_fit(Lorentz, x, y,  maxfev=10000)
# Evaluate the fitted function over a range of x values
x_fit = np.linspace(x.min(), x.max(), 100)
y_fit = Lorentz(x_fit, *popt)

# extract the values of a, b, and c from the optimized parameters
y0, A, xc, w = popt

# extract the variances of a, b, and c from the covariance matrix
var_y0, var_A, var_xc, var_w = np.diag(pcov)

# print the results
print(f"y0 = {y0:.8f} +/- {np.sqrt(var_y0):.8f}")
print(f"A = {A:.8f} +/- {np.sqrt(var_A):.8f}")
print(f"xc = {xc:.8f} +/- {np.sqrt(var_xc):.8f}")
print(f"w = {w:.8f} +/- {np.sqrt(var_w):.8f}")

# Plot the original data and the fitted function
plt.plot(x, y, ',', label='Data')
plt.plot(x_fit, y_fit, label='Fitted Function')
# plt.xlim(x.min(), x.max())
plt.legend()
plt.show()


""" Calculate Quality Factor"""
# Calculate the full width at half maximum (FWHM)
x1 = xc - w
x2 = xc + w

# locate the closest time to x1 and x2
closest_time_x1 = min(x, key=lambda v: abs(v - x1))
closest_time_x2 = min(x, key=lambda v: abs(v - x2))
closest_time_xc = min(x, key=lambda v: abs(v - xc))

# locate the position of a certain value in a column
position_x1 = df.index[df['time'] == closest_time_x1].tolist()[0]
position_x2 = df.index[df['time'] == closest_time_x2].tolist()[0]
position_xc = df.index[df['time'] == closest_time_xc].tolist()[0]

# extract the wavelength at the position
w1 = df['wavelength'][position_x1]
w2 = df['wavelength'][position_x2]
w0 = df['wavelength'][position_xc]
power0 = df['power'][position_xc]
print(f"FWHM_x1 point position is {position_x1}, wavelength is {w1}")
print(f"FWHM_x2 point position is {position_x2}, wavelength is {w2}")

delta_w = abs(w1 - w2)
q_loaded = w0/delta_w
transport0 = power0/y0

with warnings.catch_warnings():
    warnings.filterwarnings("ignore", message="invalid value encountered in sqrt")
    q_instinct_under = 2*q_loaded/(1+np.sqrt(transport0))
    q_instinct_over = 2*q_loaded/(1-np.sqrt(transport0))

q_instinct_critical = 2*q_loaded

print(f"FWHM is {delta_w}")
print(f"Q_loaded is {q_loaded:.2e}")
print(f"Under couple Q_instinct is {q_instinct_under:.2e}")
print(f"Critical couple Q_instinct is {q_instinct_critical:.2e}")
print(f"Over couple Q_instinct is {q_instinct_over:.2e}")