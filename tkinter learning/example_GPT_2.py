import tkinter as tk
from tkinter import ttk
from tkinter import messagebox

def show_name(widget_name):
    """Function to display a messagebox with the widget's name."""
    messagebox.showinfo("Widget Name", f"You interacted with {widget_name}!")

root = tk.Tk()
root.title("Tkinter Widget Showcase")

# --- Menu ---
menu = tk.Menu(root)
root.config(menu=menu)

file_menu = tk.Menu(menu)
menu.add_cascade(label="File", menu=file_menu)
file_menu.add_command(label="Exit", command=root.quit)

help_menu = tk.Menu(menu)
menu.add_cascade(label="Help", menu=help_menu)
help_menu.add_command(label="About", command=lambda: show_name("About Menu Item"))

# --- Notebook (TabControl) ---
notebook = ttk.Notebook(root)
notebook.pack(pady=10, expand=True, fill=tk.BOTH)

# Tab1
tab1 = ttk.Frame(notebook)
notebook.add(tab1, text="Tab 1")
check_var = tk.StringVar()
# Adding widgets to Tab1
label_tab1 = ttk.Label(tab1, textvariable=check_var)
label_tab1.pack(pady=20)

# Tab2
tab2 = ttk.Frame(notebook)
notebook.add(tab2, text="Tab 2")

# Adding widgets to Tab2
label_tab2 = ttk.Label(tab2, text="This is inside Tab 2!")
label_tab2.pack(pady=20)

# --- Remaining Widgets from previous example ---
# For brevity, I'll just add a few here, but you can add them all if you want

# Button
button = ttk.Button(root, text="Button", command=lambda: show_name("Button"))
button.pack(pady=10)

# Entry
entry = ttk.Entry(root)
entry.insert(0, "This is an Entry!")
entry.pack(pady=10)

# Checkbutton
check_var = tk.StringVar()  
checkbutton = ttk.Checkbutton(root, text="Checkbutton", variable=check_var, onvalue="Checked", offvalue="Unchecked", command=lambda: show_name("Checkbutton"))
checkbutton.pack(pady=10)

root.mainloop()
