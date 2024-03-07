# import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
# from decimal import Decimal

y0 = -39.57149
xc = -14806.76462
w = 64070.91401
A = 60.23689

def fit_func(x):
    return y0 + A * np.sin(np.pi/w * (x - xc))

x1 = -8192
x2 = 8192
y1 = fit_func(x1)
y2 = fit_func(x2)

def linear_func(x):
    return (y2 - y1)/(x2 - x1) * (x - x1) + y1

def fix_func(x):
    return np.arcsin( (linear_func(x) - y0)/A ) * w/np.pi + xc 

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(10, 4))

ax1.plot(np.arange(-8192, 8192), fit_func(np.arange(-8192, 8192)), label='fit')
ax1.plot(np.arange(-8192, 8192), linear_func(np.arange(-8192, 8192)), label='fix')
ax1.legend()
ax1.set_title('displacement transfer function')
ax2.plot(np.arange(-8192, 8192), fix_func(np.arange(-8192, 8192)), label='fix function')
ax2.legend()
ax2.set_title('table fix function')

plt.tight_layout()
plt.show()

# Read txt file
with open('data/random.txt', 'r') as txtfile:
    txtlines = txtfile.read().splitlines()
disp_operation = np.array(txtlines, dtype=int)

fixed_disp_operation = np.round(fix_func(disp_operation)).astype(int)

max_value_in_fixed_table = max(fixed_disp_operation)
min_value_in_fixed_table = min(fixed_disp_operation)
fix_legal = max_value_in_fixed_table <= 8192 and min_value_in_fixed_table >= -8192

# write txt file
if fix_legal:
    with open('data/random_fixed.txt', 'w') as txtfile:
        for i in fixed_disp_operation:
            txtfile.write(str(i) + '\n')
    print('Fix done')
else: 
    print('Fix illegal')
print(f'Max value in fixed table: {max_value_in_fixed_table}, Min value in fixed table: {min_value_in_fixed_table}')