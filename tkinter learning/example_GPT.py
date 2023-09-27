import tkinter as tk
from tkinter import ttk
from tkinter import messagebox

def show_name(widget_name):
    """Function to display a messagebox with the widget's name."""
    messagebox.showinfo("Widget Name", f"You interacted with {widget_name}!")

root = tk.Tk()
root.title("Tkinter Widget Showcase")

# Label
label = ttk.Label(root, text="This is a Label!")
label.pack(pady=10)

# Button
button = ttk.Button(root, text="Button", command=lambda: show_name("Button"))
button.pack(pady=10)

# Entry
entry = ttk.Entry(root)
entry.insert(0, "This is an Entry!")
entry.pack(pady=10)

# Text
text_widget = tk.Text(root, height=3, width=20)
text_widget.insert(tk.END, "This is a Text widget!")
text_widget.pack(pady=10)

# Checkbutton
check_var = tk.StringVar()
checkbutton = ttk.Checkbutton(root, text="Checkbutton", variable=check_var, onvalue="Checked", offvalue="Unchecked", command=lambda: show_name("Checkbutton"))
checkbutton.pack(pady=10)

# Radiobuttons
radio_var = tk.StringVar()
radio1 = ttk.Radiobutton(root, text="Radiobutton 1", value="A", variable=radio_var, command=lambda: show_name("Radiobutton 1"))
radio2 = ttk.Radiobutton(root, text="Radiobutton 2", value="B", variable=radio_var, command=lambda: show_name("Radiobutton 2"))
radio1.pack(pady=5)
radio2.pack(pady=5)

# Listbox
listbox = tk.Listbox(root)
items = ["Item 1", "Item 2", "Item 3"]
for item in items:
    listbox.insert(tk.END, item)
listbox.pack(pady=10)

# Scrollbar (connected to a Listbox for this example)
scrollbar = ttk.Scrollbar(root, orient="vertical", command=listbox.yview)
scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
listbox.config(yscrollcommand=scrollbar.set)

# Combobox (dropdown menu)
combobox = ttk.Combobox(root, values=["Option 1", "Option 2", "Option 3"])
combobox.set("This is a Combobox!")
combobox.pack(pady=10)

# Spinbox
spinbox = tk.Spinbox(root, from_=0, to=10)
spinbox.insert(0, "0 (Spinbox)")
spinbox.pack(pady=10)

# Scale (slider)
scale = ttk.Scale(root, from_=0, to=100, orient=tk.HORIZONTAL)
scale.set(50)  # set initial value
scale.pack(pady=10)

# Progressbar
progress = ttk.Progressbar(root, orient="horizontal", length=200, mode="determinate")
progress.pack(pady=10)
progress["value"] = 70  # set progress level

root.mainloop()
