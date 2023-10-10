import tkinter as tk
from tkinter import ttk
from time import sleep
import pyvisa as visa

def step2target(current_value, target, step, min_value, max_value):
    distance = abs(current_value - target)
    left_steps2target = distance // step

    if distance < step:
        current_value = target
        left_steps2target = 0
    elif current_value < target:
        current_value += step
    elif current_value > target:
        current_value -= step

    # Saturate the current_value if it exceeds the boundaries
    if current_value > max_value:
        current_value = max_value
        left_steps2target = 0
    elif current_value < min_value:
        current_value = min_value
        left_steps2target = 0
    
    return current_value, left_steps2target

def on_ramp():
    oscilloscope.write(':SOURce1:FUNCtion:SHApe RAMP')
    print(oscilloscope.query(':SOURce1:FUNCtion:SHApe?'))

def on_dc():
    oscilloscope.write(':SOURce1:FUNCtion:SHApe DC')
    print(oscilloscope.query(':SOURce1:FUNCtion:SHApe?'))

def on_run2target():
    current_value = float(current_value_var.get())
    target = float(target_var.get())
    step = float(step_var.get())

    # Disable the button
    for button in (run_button, step_target_button_1, step_target_button_2, step_target_button_3, step_target_button_4):
        button.config(state=tk.DISABLED)

    root.update()  # Update the GUI to reflect the change immediately

    while True:
        current_value, left_steps2target = step2target(current_value, target, step, min_value, max_value)
        oscilloscope.write(f':SOURce1:VOLTage:OFFSet {current_value}')
        osc_offset = float(oscilloscope.query(f':SOURce1:VOLTage:OFFSet?'))
        current_percentage.set(f"{'%.2f'% (osc_offset/(max_value-min_value)*2*100)} %")
        current_value_var.set(osc_offset)
        root.update()  # To immediately reflect changes in GUI
        # sleep(0.1)
        if left_steps2target == 0:
            break

    # Enable the button after the loop
    for button in (run_button, step_target_button_1, step_target_button_2, step_target_button_3, step_target_button_4):
        button.config(state=tk.NORMAL)

def on_step(single_step=0.01):
    current_value = float(current_value_var.get())

    # Saturation
    new_value = current_value + single_step
    if new_value > max_value:
        new_value = max_value
    elif new_value < min_value:
        new_value = min_value

    oscilloscope.write(f':SOURce1:VOLTage:OFFSet {new_value}')
    osc_offset = float(oscilloscope.query(f':SOURce1:VOLTage:OFFSet?'))
    current_percentage.set(f"{'%.2f'% (osc_offset/(max_value-min_value)*2*100)} %")
    current_value_var.set(osc_offset)

# Connect to the oscilloscope
rm = visa.ResourceManager()
oscilloscope_address = 'TCPIP0::192.168.1.9::inst0::INSTR'
oscilloscope = rm.open_resource(oscilloscope_address)
print(oscilloscope.query('*IDN?'))  # Query the identification string of the oscilloscope

# GUI
root = tk.Tk()
root.title("Step to Target GUI")
frame = ttk.Frame(root, padding="10")
frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

# Variables
current_value_var = tk.DoubleVar(value=float(oscilloscope.query(f':SOURce1:VOLTage:OFFSet?')))
current_percentage = tk.StringVar(value="0 %")
target_var = tk.DoubleVar(value=0.9)
step_var = tk.DoubleVar(value=0.01)
min_value = -0.9
max_value = 0.9

# Default settings
ttk.Label(frame, text=f"Max Offset: {max_value}V  Min Offset: {min_value}V").grid(column=0, row=0, columnspan=3, sticky=tk.W)

# Current Value
ttk.Label(frame, text="Current Offset:").grid(column=0, row=1, sticky=tk.W)
ttk.Entry(frame, textvariable=current_value_var).grid(column=1, row=1)
ttk.Label(frame, textvariable=current_percentage).grid(column=2, row=1)

# Target
ttk.Label(frame, text="Target Offset:").grid(column=0, row=2, sticky=tk.W)
ttk.Entry(frame, textvariable=target_var).grid(column=1, row=2)

# Step
ttk.Label(frame, text="Offset Step:").grid(column=0, row=3, sticky=tk.W)
ttk.Entry(frame, textvariable=step_var).grid(column=1, row=3)

# Ramp Button
ramp_button = ttk.Button(frame, text="Ramp", command=on_ramp)
ramp_button.grid(column=3, row=1, pady=10)

# DC Button
dc_button = ttk.Button(frame, text="DC", command=on_dc)
dc_button.grid(column=3, row=2, pady=10)

# Run Button
run_button = ttk.Button(frame, text="Run", command=on_run2target)
run_button.grid(column=3, row=3, pady=10)

# Step Target Button
step_target_button_1 = ttk.Button(frame, text="+100%", command=lambda: [target_var.set(max_value-0*(max_value-min_value)), on_run2target()])
step_target_button_1.grid(column=0, row=4, pady=10)
step_target_button_2 = ttk.Button(frame, text="+50%", command=lambda: [target_var.set(max_value-0.25*(max_value-min_value)), on_run2target()])
step_target_button_2.grid(column=1, row=4, pady=10)
step_target_button_3 = ttk.Button(frame, text="0%", command=lambda: [target_var.set(max_value-0.5*(max_value-min_value)), on_run2target()])
step_target_button_3.grid(column=2, row=4, pady=10)
step_target_button_4 = ttk.Button(frame, text="50%", command=lambda: [target_var.set(max_value-0.75*(max_value-min_value)), on_run2target()])
step_target_button_4.grid(column=3, row=4, pady=10)

# Manual Step Button
step_button = ttk.Button(frame, text="<--0.1", command=lambda: [on_step(0.01)])
step_button.grid(column=0, row=5, pady=10)
step_button = ttk.Button(frame, text="<--0.01", command=lambda: [on_step(0.01)])
step_button.grid(column=1, row=5, pady=10)
step_button = ttk.Button(frame, text="0.01-->", command=lambda: [on_step(-0.01)])
step_button.grid(column=2, row=5, pady=10)
step_button = ttk.Button(frame, text="0.1-->", command=lambda: [on_step(-0.1)])
step_button.grid(column=3, row=5, pady=10)

# Bind shortcut keys
root.bind("1", lambda event: [target_var.set(max_value-0*(max_value-min_value)), on_run2target()])
root.bind("2", lambda event: [target_var.set(max_value-0.25*(max_value-min_value)), on_run2target()])
root.bind("3", lambda event: [target_var.set(max_value-0.5*(max_value-min_value)), on_run2target()])
root.bind("4", lambda event: [target_var.set(max_value-0.75*(max_value-min_value)), on_run2target()])
root.bind("a", lambda event: on_step(0.005))
root.bind("d", lambda event: on_step(-0.005))
root.bind("q", lambda event: on_step(0.02))
root.bind("e", lambda event: on_step(-0.02))


root.mainloop()
oscilloscope.close()