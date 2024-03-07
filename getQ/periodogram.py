import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import welch

# Parameters
zohms = 50
split_num = 1000
sampling_rate = 10000000 # 10MSa/s
window_seg_number = 1
header_rows = 0

# Read data
data1 = pd.read_csv('data/snl1.csv', skiprows=header_rows)
data2 = pd.read_csv('data/squ1.csv', skiprows=header_rows)

signal1 = data1.iloc[:, 0].values
signal2 = data2.iloc[:, 0].values

split_size = len(signal1) // split_num
signal1 = signal1[:split_size*split_num]
signal2 = signal2[:split_size*split_num]
signal1_split = np.array_split(signal1, split_num)
signal2_split = np.array_split(signal2, split_num)

# Welch's method for signal1
Pxx_avg_seg1 = []
for i in range(split_num):
    f1, Pxx_avg_seg1_ = welch(signal1_split[i], fs=sampling_rate, window='boxcar', nperseg=len(signal1_split[i])//window_seg_number, noverlap=None, scaling='spectrum')
    """
    window can be one of the following:
        - boxcar
        - triang
        - blackman
        - hamming
        - hann
        - bartlett
        - flattop
        - parzen
        - bohman
        - blackmanharris
        - nuttall
        - barthann
        - cosine
        - exponential
        - tukey
        - taylor
        - lanczos
    When window is boxcar, window_seg_number is 1, and noverlap is None, the result is equivalent to `scipy.signal.periodogram`.
    """
    Pxx_avg_seg1.append(Pxx_avg_seg1_)
Pxx_avg1 = np.mean(Pxx_avg_seg1, axis=0)
Pxx_avg1 = 10 * np.log10(Pxx_avg1 / zohms) + 30

# Welch's method for signal2
Pxx_avg_seg2 = []
for i in range(split_num):
    f2, Pxx_avg_seg2_ = welch(signal2_split[i], fs=sampling_rate, window='boxcar', nperseg=len(signal2_split[i])//window_seg_number, noverlap=None, scaling='spectrum')
    Pxx_avg_seg2.append(Pxx_avg_seg2_)
Pxx_avg2 = np.mean(Pxx_avg_seg2, axis=0)
Pxx_avg2 = 10 * np.log10(Pxx_avg2 / zohms) + 30

# Plot
plt.figure(figsize=(10, 6))
plt.plot(f1, Pxx_avg1, label='data1')
plt.plot(f2, Pxx_avg2, label='data2')
plt.title('Power Spectral Density Estimation')
plt.xlabel('Frequency (Hz)')
plt.ylabel('Power (dBm)')
plt.xlim(0,100000)
plt.ylim(-85,-75)
plt.legend()
plt.grid(True)
plt.show()
