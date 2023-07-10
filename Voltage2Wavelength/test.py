import pandas as pd

filename = 'wavelength_meter_data.csv'
output_filename = 'middle_points.csv'
threshold = -0.0001

# Read CSV and extract values
df = pd.read_csv(filename)
values = df['wavelength'].values.tolist()  # Replace 'wavelength' with the actual column name

step_points = []
middle_points = []
flag = 0

print(values[107900-1])