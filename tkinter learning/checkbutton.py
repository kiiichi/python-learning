import tkinter as tk
from tkinter import ttk

def get_checkbutton_value():
    value = checkbutton_var.get()
    print(value)

root = tk.Tk()

checkbutton_var = tk.StringVar()

checkbutton = ttk.Checkbutton(root, text="Check Button", variable=checkbutton_var, onvalue=2, offvalue=3)
checkbutton.pack()

button = ttk.Button(root, text="Get Value", command=get_checkbutton_value)
button.pack()

root.mainloop()