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

def on_run():
    current_value = float(current_value_var.get())
    target = float(target_var.get())
    step = float(step_var.get())

    # Disable the button
    for button in (run_button, step_target_button_1, step_target_button_2, step_target_button_3, step_target_button_4):
        button.config(state=tk.DISABLED)

    root.update()  # Update the GUI to reflect the change immediately

    while True:
        current_value, left_steps2target = step2target(current_value, target, step)
        current_value_var.set(current_value)
        root.update()  # To immediately reflect changes in GUI
        sleep(0.5)
        if left_steps2target == 0:
            break

    # Enable the button after the loop
    for button in (run_button, step_target_button_1, step_target_button_2, step_target_button_3, step_target_button_4):
        button.config(state=tk.NORMAL)

root = tk.Tk()
root.title("Step to Target GUI")

frame = ttk.Frame(root, padding="10")
frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

# Variables
current_value_var = tk.DoubleVar(value=0)
target_var = tk.DoubleVar(value=4)
step_var = tk.DoubleVar(value=1.5)

# Current Value
ttk.Label(frame, text="Current Value:").grid(column=0, row=0, sticky=tk.W)
ttk.Entry(frame, textvariable=current_value_var).grid(column=1, row=0)

# Target
ttk.Label(frame, text="Target:").grid(column=0, row=1, sticky=tk.W)
ttk.Entry(frame, textvariable=target_var).grid(column=1, row=1)

# Step
ttk.Label(frame, text="Step:").grid(column=0, row=2, sticky=tk.W)
ttk.Entry(frame, textvariable=step_var).grid(column=1, row=2)

# Run Button
run_button = ttk.Button(frame, text="Run", command=on_run)
run_button.grid(columnspan=2, column=0, row=3, pady=10)

# Step Target Button
step_target_button_1 = ttk.Button(frame, text="Target -5", command=lambda: [target_var.set(target_var.get() - 5), on_run()])
step_target_button_1.grid(column=0, row=4, pady=10)
step_target_button_2 = ttk.Button(frame, text="Target -1", command=lambda: [target_var.set(target_var.get() - 1), on_run()])
step_target_button_2.grid(column=1, row=4, pady=10)
step_target_button_3 = ttk.Button(frame, text="Target +1", command=lambda: [target_var.set(target_var.get() + 1), on_run()])
step_target_button_3.grid(column=2, row=4, pady=10)
step_target_button_4 = ttk.Button(frame, text="Target +5", command=lambda: [target_var.set(target_var.get() + 5), on_run()])
step_target_button_4.grid(column=3, row=4, pady=10)

root.mainloop()
