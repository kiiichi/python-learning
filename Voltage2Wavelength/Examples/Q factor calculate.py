import pandas as pd
import numpy as np
from scipy.optimize import curve_fit
import matplotlib.pyplot as plt

# Read the CSV file into a Pandas dataframe
df = pd.read_csv('data/refined.csv')

# Extract the two columns of interest into NumPy arrays
x = df['time'].values
y = df['power'].values

# Define the math function you want to fit
def Lorentz(x,y0,A,xc,w):
    y = y0 + (2*A/np.pi)*(w/(4*(x-xc)**2 + w**2))
    return y

# Fit the function to the data using SciPy's curve_fit method
popt, pcov = curve_fit(Lorentz, x, y, maxfev=10000)

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

# calculate the Q factor
v1 = 299792458/w1
v2 = 299792458/w2
v0 = 299792458/w0
delta_v = abs(v1 - v2)
q_loaded = v0/delta_v
transport0 = power0/y0
q_instinct_under = 2*q_loaded/(1+np.sqrt(transport0))
q_instinct_over = 2*q_loaded/(1-np.sqrt(transport0))
q_instinct_critical = 2*q_loaded

print(f"FWHM is {delta_v}")
print(f"Q_loaded is {q_loaded:.2e}")
print(f"The under couple Q_instinct is {q_instinct_under:.2e}")
print(f"The critical couple Q_instinct is {q_instinct_critical:.2e}")
print(f"The over couple Q_instinct is {q_instinct_over:.2e}")

# Plot the original data and the fitted function
plt.plot(x, y, 'o', label='Data')
plt.plot(x_fit, y_fit, label='Fitted Function')
plt.legend()
plt.show()
