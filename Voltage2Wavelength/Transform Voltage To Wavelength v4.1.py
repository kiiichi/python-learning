import pandas as pd
import tkinter as tk
from tkinter import filedialog
import numpy as np
from scipy.optimize import curve_fit
import matplotlib.pyplot as plt
import warnings
import re

def interpolate_voltage_to_wavelength(voltage, fiting_curve_name):
    """Modified from looking up reference table and interpolating to get a polynomial fitting from reference table.
    
    Need a voltage and a fitting curve name, return interpolated_wavelength
    """
    # voltage = np.float64(voltage)
    match fiting_curve_name:
        case 'toptica1':
            interpolated_wavelength = 1.41735740e-12 * voltage**5 - 5.70767417e-10 * voltage**4 + 1.15683891e-07 * voltage**3 - 1.37073757e-05 * voltage**2 - 1.58771892e-03 * voltage + 3.84508009e-01
        case 'toptica2':
            interpolated_wavelength = 1.45757887e-12 * voltage**5 - 7.47082543e-10 * voltage**4 + 1.66903897e-07 * voltage**3 - 1.84056335e-05 * voltage**2 - 1.72441280e-03 * voltage + 4.32064375e-02
        case _:
            print('[Function]interpolate_voltage_to_wavelength: No such fitting curve name')

    # return np.float64(interpolated_wavelength)
    return interpolated_wavelength

# """ Genarate Reference Dictionary """
# # Import the Excel file as a pandas DataFrame
# reference_data = pd.read_csv('reference_data_0.1_refine_2.0.csv')

# # Transform the DataFrame into a dictionary where the keys are the voltage values and the values are the wavelength values
# reference_table = dict(zip(reference_data['voltage'], reference_data['wavelength']))

'''Input Parameters'''
set_wavelength = 1549.90212

""" Input, Transform, and Output """
# create the Tkinter root window
root = tk.Tk()
root.withdraw() # hide the root window

# show the file dialog box and get the selected file
file_path = filedialog.askopenfilename()

# get the flie name and the folder path and containing the file
file_name = file_path.rsplit('/', 1)[1] # assuming Unix-style path separator
folder_path = file_path.rsplit('/', 1)[0]  
file_name_num = re.findall(r'\d+\.\d+', file_name)
arc_factor = float(file_name_num[0])
set_voltage = float(file_name_num[1])
print(f'arc_factor: {arc_factor}, set_voltage: {set_voltage}')

df = pd.read_csv(file_path, names=['time', 'voltage_scope', 'power'], skiprows=1)
data = df.to_numpy()
time_values = data[:, 0]
slope, intercept = np.polyfit(time_values, data[:, 1], 1)
voltage_fit = slope * time_values + intercept
voltage_actual_values = voltage_fit * arc_factor + set_voltage
df['voltage_actual'] = pd.DataFrame(voltage_actual_values)
power = data[:, 2]
# Interpolate the corresponding wavelength values
wavelength_values = interpolate_voltage_to_wavelength(voltage_actual_values, 'toptica1') + set_wavelength
# Write the results to a new CSV file
df['wavelength'] = pd.DataFrame(wavelength_values)
df.to_csv(f'{folder_path}/refined_{file_name}', index=False)
# df.to_csv(f'{folder_path}/refined_{file_name}', index=False, float_format='%.15f')
print('refined file saved')


""" Curve Fitting """
# Extract the two columns of interest into NumPy arrays
x = wavelength_values
y = power

# Define the math function want to fit
def Lorentz(x,y0,A,xc,w):
    y = y0 + (2*A/np.pi)*(w/(4*(x-xc)**2 + w**2))
    return y

# Define the initial values
y0 = np.average(y[0:1000])

A = 0

min_y_index = np.argmin(y)
min_y = y[min_y_index]
xc = x[min_y_index]

half_y = min_y + (y0-min_y)/2
half_y_index = np.argmin(np.abs(y - half_y))
half_y_x_point = x[half_y_index]
w = np.abs(half_y_x_point - xc)

popt, pcov = curve_fit(Lorentz, x, y, p0=[y0,A,xc,w], maxfev=100000)
# popt, pcov = curve_fit(Lorentz, x, y,  maxfev=10000)
# Evaluate the fitted function over a range of x values
x_fit = np.linspace(x.min(), x.max(), 10000)
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
# extract the wavelength at the corresponding time
# w0 = wavelength_values[min_y_index]
w0 = xc
# w = np.abs(wavelength_values[half_y_index] - w0)
delatw = w

q_loaded = w0/delatw
transport0 = min_y/y0

with warnings.catch_warnings():
    warnings.filterwarnings("ignore", message="invalid value encountered in sqrt")
    q_instinct_under = 2*q_loaded/(1+np.sqrt(transport0))
    q_instinct_over = 2*q_loaded/(1-np.sqrt(transport0))

q_instinct_critical = 2*q_loaded

print(f"FWHM is {delatw}")
print(f"Q_loaded is {q_loaded:.2e}")
print(f"Under couple Q_instinct is {q_instinct_under:.2e}")
print(f"Critical couple Q_instinct is {q_instinct_critical:.2e}")
print(f"Over couple Q_instinct is {q_instinct_over:.2e}")
