import pandas as pd

filename = 'wavelength_meter_data.csv'
output_filename = 'middle_points.csv'
threshold = -0.00011

# Read CSV and extract values
df = pd.read_csv(filename)
values = df['wavelength'].values.tolist()  # Replace 'wavelength' with the actual column name

step_points = []
middle_points = []
middle_average = []
tolerate_flag = 0
average_num = 10

# Find step points
for i in range(1, len(values) - 1):
    if values[i] - values[i - 1] < threshold/2:
        if i - tolerate_flag < 3:
            continue
        step_points.append(i)
        tolerate_flag = i

# Find middle points and calculate averages
for i in range(len(step_points) - 1):
    start = step_points[i]
    end = step_points[i + 1]
    middle = (start + end) // 2
    middle_points.append(middle)
    average = sum(values[ middle - average_num : middle + average_num ]) / (2 * average_num)
    middle_average.append(average)

# Add the last middle point manually
middle_points.append('nan')
middle_average.append('nan')

# Write middle points and step points to CSV
output_data = {'step_points': step_points, 'middle_points': middle_points, 'middle_average': middle_average}
output_df = pd.DataFrame(output_data)
output_df.to_csv(output_filename, index=False)

print(f"Points written to {output_filename}.")
