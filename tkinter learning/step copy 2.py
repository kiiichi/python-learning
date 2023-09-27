import tkinter as tk
from tkinter import ttk
from time import sleep

def step2target(current_value, target, step):
    distance = abs(current_value - target)
    left_steps2target = distance // step

    if distance < step:
        current_value = target
        left_steps2target = 0
    elif current_value < target:
        current_value += step
    elif current_value > target:
        current_value -= step

    return current_value, left_steps2target

def on_apply():
    # The loop now takes its values directly from the entries, no need for trace
    current_value = float(current_value_var.get())
    target = float(target_var.get())
    step = float(step_var.get())

    while switch_var.get():  # Check if switch is ON
        current_value, left_steps2target = step2target(current_value, target, step)
        current_value_var.set(current_value)
        root.update()
        sleep(0.5)

root = tk.Tk()
root.title("Step to Target GUI")

frame = ttk.Frame(root, padding="10")
frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

# Variables
current_value_var = tk.DoubleVar(value=0)
target_var = tk.DoubleVar(value=4)
step_var = tk.DoubleVar(value=1.5)
switch_var = tk.IntVar(value=0)

# Current Value
ttk.Label(frame, text="Current Value:").grid(column=0, row=0, sticky=tk.W)
ttk.Entry(frame, textvariable=current_value_var).grid(column=1, row=0)

# Target
ttk.Label(frame, text="Target:").grid(column=0, row=1, sticky=tk.W)
ttk.Entry(frame, textvariable=target_var).grid(column=1, row=1)

# Step
ttk.Label(frame, text="Step:").grid(column=0, row=2, sticky=tk.W)
ttk.Entry(frame, textvariable=step_var).grid(column=1, row=2)

# Apply Button
apply_button = ttk.Button(frame, text="Apply", command=on_apply)
apply_button.grid(column=0, row=3, pady=10)

# Switch (Checkbutton to act as a switch)
switch_button = ttk.Checkbutton(frame, text="Run", variable=switch_var)
switch_button.grid(column=1, row=3, pady=10)

root.mainloop()
