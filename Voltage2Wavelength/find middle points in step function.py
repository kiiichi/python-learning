import csv

def extract_middle_points(filename):
    with open(filename, 'r') as file:
        reader = csv.reader(file)
        next(reader)  # Skip header row
        values = [float(row[0]) for row in reader]

    step_points = []
    middle_points = []

    # Find step points
    for i in range(1, len(values) - 1):
        if values[i] < values[i - 1] and values[i] < values[i + 1]:
            step_points.append(i)

    # Find middle points and calculate averages
    for i in range(1, len(step_points)):
        start = step_points[i - 1]
        end = step_points[i]
        middle = (start + end) // 2
        average = sum(values[start:end]) / (end - start)
        middle_points.append((middle, average))

    return middle_points

# Usage example
filename = 'wavelength_meter_data.csv'
middle_points = extract_middle_points(filename)
for point in middle_points:
    print(f"Middle Point: {point[0]}, Average Value: {point[1]}")
