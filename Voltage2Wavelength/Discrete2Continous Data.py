# Define the reference table as a dictionary mapping voltage values to wavelength values
reference_table = {
    0.5: 350,
    1.0: 400,
    1.5: 450,
    2.0: 500,
    2.5: 550,
    3.0: 600
}

# Define a function to interpolate the wavelength value for a given voltage value
def interpolate_voltage_to_wavelength(voltage):
    # Find the two nearest voltage values in the reference table
    closest_voltage_below = max(filter(lambda v: v <= voltage, reference_table.keys()))
    closest_voltage_above = min(filter(lambda v: v >= voltage, reference_table.keys()))
    
    # Calculate the fraction between the two nearest voltage values
    fraction = (voltage - closest_voltage_below) / (closest_voltage_above - closest_voltage_below)
    
    # Interpolate the wavelength value between the two nearest wavelength values
    wavelength_below = reference_table[closest_voltage_below]
    wavelength_above = reference_table[closest_voltage_above]
    interpolated_wavelength = wavelength_below + fraction * (wavelength_above - wavelength_below)
    
    return interpolated_wavelength

# Example usage
voltage_values = [1.25, 2.8, 0.6]
for voltage in voltage_values:
    wavelength = interpolate_voltage_to_wavelength(voltage)
    print(f"Input voltage: {voltage}, Output wavelength: {wavelength}")
    
