from time import sleep
import tkinter as tk
from tkinter import ttk
from Ctrl_PyrplInstr import *
from Ctrl_HttpInstr import *
from Ctrl_ScpiInstr import *
from parameter_table import FSR, PSG_freq, PSG_power, toptica1_wl_bias, toptica2_wl_bias

def get_ival():
    "Get pid ival and update GUI, also check if ival of pump or local locking is too large and reset if necessary"

    p1_pid0_ival_num = p1_pid0.ival
    p1_pid1_ival_num = p1_pid1.ival
    p2_pid0_ival_num = p2_pid0.ival
    p2_pid1_ival_num = p2_pid1.ival
    p3_pid0_ival_num = p3_pid0.ival

    p1_pid0_ival.set(f"Pump: {'%.2f'% p1_pid0_ival_num}")
    p1_pid1_ival.set(f"P_ref: {'%.2f'% p1_pid1_ival_num}")
    p2_pid0_ival.set(f"Local0: {'%.2f'% p2_pid0_ival_num}")
    p2_pid1_ival.set(f"Local1: {'%.2f'% p2_pid1_ival_num}")
    p3_pid0_ival.set(f"MC: {'%.2f'% p3_pid0_ival_num}")

    if check_autolock_var.get() == 'Auto Reset':
        if p1_pid0_ival_num > 0.6 or p1_pid0_ival_num < -0.6:
            p1_pid_reset(0)
        if p1_pid1_ival_num > 0.6 or p1_pid1_ival_num < -0.6:
            p1_pid_reset(1)
        if p2_pid0_ival_num > 0.6 or p2_pid0_ival_num < -0.6:
            p2_pid_reset(0)
        if p2_pid1_ival_num > 0.6 or p2_pid1_ival_num < -0.6:
            p2_pid_reset(1)

    root.after(100, get_ival)

def ws_toptica_set(n):
    "Set waveshaper and toptica wavelength to sideband n, also update GUI"

    center_wl_1, center_wl_2 = ws_dualband_setup(pump_wl.get(), FSR*n, 40, attenuation=[band1_att.get(), pump_att.get(), band2_att.get()], phase=[band1_degree.get(), pump_degree.get(), band2_degree.get()])
    ctrl_toptica1(center_wl_2 + toptica1_wl_bias)
    ctrl_toptica2(center_wl_1 + toptica2_wl_bias)
    band1_wl.set(f"{'%.5f'% center_wl_1} nm")
    band2_wl.set(f"{'%.5f'% center_wl_2} nm")

# GUI
root = tk.Tk()
root.title("Control Center GUI")
frame = ttk.Frame(root, padding="10")
frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

pump_rp_state = tk.StringVar(value='pump_rp_state')
local_rp_state = tk.StringVar(value='local_rp_state')
MC_FL_rp_state = tk.StringVar(value='MC_FL_rp_state')
MC_SL_rp_state = tk.StringVar(value='MC_SL_rp_state')

p1_pid0_ival = tk.StringVar(value = 'Pump pid ival: 0')
p1_pid1_ival = tk.StringVar(value = 'P_ref pid ival: 0')
p2_pid0_ival = tk.StringVar(value = 'Local pid0 ival: 0')
p2_pid1_ival = tk.StringVar(value = 'Local pid1 ival: 0')
p3_pid0_ival = tk.StringVar(value = 'MC pid ival: 0')

pump_wl = tk.DoubleVar(value=1550)
band1_wl = tk.StringVar(value='center_wl_1')
band2_wl = tk.StringVar(value='center_wl_2')
band_num = tk.StringVar(value='band_num')

pump_att = tk.DoubleVar(value=0)
band1_att = tk.DoubleVar(value=0)
band2_att = tk.DoubleVar(value=0)

pump_degree = tk.DoubleVar(value=0)
band1_degree = tk.DoubleVar(value=0)
band2_degree = tk.DoubleVar(value=0)

ttk.Label(frame, textvariable=pump_rp_state).grid(column=0, row=0)
ttk.Label(frame, textvariable=local_rp_state).grid(column=0, row=1)
ttk.Label(frame, textvariable=MC_FL_rp_state).grid(column=0, row=2)
ttk.Label(frame, textvariable=MC_SL_rp_state).grid(column=0, row=3)

ttk.Label(frame, text="PID Ival").grid(column=1, row=0)
ttk.Label(frame, textvariable=p1_pid0_ival).grid(column=1, row=1)
ttk.Label(frame, textvariable=p1_pid1_ival).grid(column=1, row=2)
ttk.Label(frame, textvariable=p2_pid0_ival).grid(column=1, row=3)
ttk.Label(frame, textvariable=p2_pid1_ival).grid(column=1, row=4)
ttk.Label(frame, textvariable=p3_pid0_ival).grid(column=1, row=5)

ttk.Label(frame, text="Wavelength (nm)").grid(column=2, row=0)
ttk.Entry(frame, textvariable=pump_wl, width=9, justify="center").grid(column=2, row=1)
ttk.Label(frame, textvariable=band1_wl).grid(column=2, row=2)
ttk.Label(frame, textvariable=band2_wl).grid(column=2, row=3)
ttk.Label(frame, textvariable=band_num).grid(column=2, row=4)

ttk.Label(frame, text="Attenuation (dB)").grid(column=3, row=0)
ttk.Entry(frame, textvariable=pump_att, width=9, justify="center").grid(column=3, row=1)
ttk.Entry(frame, textvariable=band1_att, width=9, justify="center").grid(column=3, row=2)
ttk.Entry(frame, textvariable=band2_att, width=9, justify="center").grid(column=3, row=3)

ttk.Label(frame, text="Phase (degree)").grid(column=4, row=0)
ttk.Entry(frame, textvariable=pump_degree, width=9, justify="center").grid(column=4, row=1)
ttk.Entry(frame, textvariable=band1_degree, width=9, justify="center").grid(column=4, row=2)
ttk.Entry(frame, textvariable=band2_degree, width=9, justify="center").grid(column=4, row=3)

# Check buttons
check_autolock_var = tk.StringVar(value='Manual Reset')
check_autolock_button =  ttk.Checkbutton(frame, text="Auto Reset", variable=check_autolock_var, onvalue="Auto Reset", offvalue="Manual Reset").grid(column=0, row=4)

ttk.Label(frame, text="------------------------------------------------ SHORT CUT -------------------------------------------------").grid(column=0, row=6, columnspan=5)
ttk.Label(frame, text="default rp: ctrl + ( 1 = pump, 2 = local, 3 = MC_FL, 4 = MC_SL, 0 = ALL)").grid(column=0, row=7, columnspan=5, sticky=tk.W)
ttk.Label(frame, text="Pump&Local rp: ctrl+z = ramp, ctrl+r = reset, ctrl+f = lock, ctrl+c = miniramp").grid(column=0, row=8, columnspan=5, sticky=tk.W)
ttk.Label(frame, text="MC rp: ctrl+n = ramp, ctrl+m = reset, ctrl+, = coarselock, ctrl+. = finelock").grid(column=0, row=9, columnspan=5, sticky=tk.W)
ttk.Label(frame, text="PSG and WS: ctrl + shift + 1~9 (Toptica as local) | alt + 1~9 (EOcomb as local) = sideband 1-9").grid(column=0, row=10, columnspan=5, sticky=tk.W)


# Bind shortcut keys
root.bind('<Control-q>', lambda e: root.destroy())

root.bind('<Control-KeyPress-1>', lambda e: [p1_setup(), pump_rp_state.set('Pump&P_ref Default')])
root.bind('<Control-KeyPress-2>', lambda e: [p2_setup(), local_rp_state.set('Local Default')])
root.bind('<Control-KeyPress-3>', lambda e: [p3_setup(), MC_FL_rp_state.set('MC_FL Default')])
root.bind('<Control-KeyPress-4>', lambda e: [p4_setup(), MC_SL_rp_state.set('MC_SL Default')])
root.bind('<Control-KeyPress-0>', lambda e: [p1_setup(), p2_setup(), p3_setup(), p4_setup(),
                          pump_rp_state.set('Pump&P_ref Default'), local_rp_state.set('Local Default'), MC_FL_rp_state.set('MC_FL Default'), MC_SL_rp_state.set('MC_SL Default')])

root.bind('<Control-KeyPress-r>', lambda e: [p1_pid_reset(0), p1_pid_reset(1), p2_pid_reset(0), p2_pid_reset(1)])
root.bind('<Control-KeyPress-z>', lambda e: [p1_pid_paused(0), p1_pid_paused(1), p2_pid_paused(0), p2_pid_paused(1), 
                          p1_pid_reset(0), p1_pid_reset(1), p2_pid_reset(0), p2_pid_reset(1),
                          p1_ramp_on(0), p1_ramp_on(1), p2_ramp_on(0), p2_ramp_on(1),
                          pump_rp_state.set('Pump&P_ref Ramping'), local_rp_state.set('Local Ramping')])
root.bind('<Control-KeyPress-f>', lambda e: [p1_ramp_off(0), p1_ramp_off(1), p2_ramp_off(0), p2_ramp_off(1),
                          p1_pid_unpaused(0), p1_pid_unpaused(1), p2_pid_unpaused(0), p2_pid_unpaused(1),
                          pump_rp_state.set('Pump&P_ref Locked'), local_rp_state.set('Local Locked')])
root.bind('<Control-KeyPress-c>', lambda e: [p1_pid_paused(0), p1_pid_paused(1), p2_pid_paused(0), p2_pid_paused(1), 
                          p1_pid_reset(0), p1_pid_reset(1), p2_pid_reset(0), p2_pid_reset(1),
                          p1_ramp_on(0), p1_ramp_on(1), p2_miniramp_on(0), p2_ramp_off(1),
                          pump_rp_state.set('Pump&P_ref Ramping'), local_rp_state.set('Local1 Miniramping')])

root.bind('<Control-KeyPress-m>', lambda e: p3_pid_reset(0))
root.bind('<Control-KeyPress-n>', lambda e: [p3_pid_paused(0),
                                    p3_pid_reset(0), 
                                    p3_ramp_on(0), 
                                    p3_ramp_off(1),
                                    MC_FL_rp_state.set('MC Ramping')])
root.bind('<Control-KeyPress-,>', lambda e: [p3_ramp_off(0),
                                    slow_ramp('on'), 
                                    p3_pid_unpaused(0),
                                    MC_FL_rp_state.set('MC Coarse Locking')])
root.bind('<Control-KeyPress-.>', lambda e: [slow_ramp('off'), 
                                    p3_pid_reset(0), 
                                    p3_pid_unpaused(0),
                                    MC_FL_rp_state.set('MC Fine Locking')])

root.bind("<Alt-KeyPress-1>", lambda e: [ctrl_psg(PSG_freq[0], PSG_power[1]), ws_toptica_set(1), band_num.set('Side Band 1')])
root.bind("<Alt-KeyPress-2>", lambda e: [ctrl_psg(PSG_freq[0], PSG_power[2]), ws_toptica_set(2), band_num.set('Side Band 2')])
root.bind("<Alt-KeyPress-3>", lambda e: [ctrl_psg(PSG_freq[0], PSG_power[3]), ws_toptica_set(3), band_num.set('Side Band 3')])
root.bind("<Alt-KeyPress-4>", lambda e: [ctrl_psg(PSG_freq[0], PSG_power[4]), ws_toptica_set(4), band_num.set('Side Band 4')])
root.bind("<Alt-KeyPress-5>", lambda e: [ctrl_psg(PSG_freq[0], PSG_power[5]), ws_toptica_set(5), band_num.set('Side Band 5')])
root.bind("<Alt-KeyPress-6>", lambda e: [ctrl_psg(PSG_freq[0], PSG_power[6]), ws_toptica_set(6), band_num.set('Side Band 6')])
root.bind("<Alt-KeyPress-7>", lambda e: [ctrl_psg(PSG_freq[0], PSG_power[7]), ws_toptica_set(7), band_num.set('Side Band 7')])
root.bind("<Alt-KeyPress-8>", lambda e: [ctrl_psg(PSG_freq[0], PSG_power[8]), ws_toptica_set(8), band_num.set('Side Band 8')])
root.bind("<Alt-KeyPress-9>", lambda e: [ctrl_psg(PSG_freq[0], PSG_power[9]), ws_toptica_set(9), band_num.set('Side Band 9')])
root.bind('<Control-KeyPress-!>', lambda e: [ctrl_psg(PSG_freq[1], PSG_power[1]), ws_toptica_set(1), band_num.set('Side Band 1')])
root.bind('<Control-KeyPress-@>', lambda e: [ctrl_psg(PSG_freq[2], PSG_power[2]), ws_toptica_set(2), band_num.set('Side Band 2')])
root.bind('<Control-KeyPress-#>', lambda e: [ctrl_psg(PSG_freq[3], PSG_power[3]), ws_toptica_set(3), band_num.set('Side Band 3')])
root.bind('<Control-KeyPress-$>', lambda e: [ctrl_psg(PSG_freq[4], PSG_power[4]), ws_toptica_set(4), band_num.set('Side Band 4')])
root.bind('<Control-KeyPress-%>', lambda e: [ctrl_psg(PSG_freq[5], PSG_power[5]), ws_toptica_set(5), band_num.set('Side Band 5')])
root.bind('<Control-KeyPress-^>', lambda e: [ctrl_psg(PSG_freq[6], PSG_power[6]), ws_toptica_set(6), band_num.set('Side Band 6')])
root.bind('<Control-KeyPress-&>', lambda e: [ctrl_psg(PSG_freq[7], PSG_power[7]), ws_toptica_set(7), band_num.set('Side Band 7')])
root.bind('<Control-KeyPress-*>', lambda e: [ctrl_psg(PSG_freq[8], PSG_power[8]), ws_toptica_set(8), band_num.set('Side Band 8')])
root.bind('<Control-KeyPress-(>', lambda e: [ctrl_psg(PSG_freq[9], PSG_power[9]), ws_toptica_set(9), band_num.set('Side Band 9')])


root.after(100, get_ival)
root.mainloop()