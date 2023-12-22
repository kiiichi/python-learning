import pyrpl
from time import sleep
import tkinter as tk
from tkinter import ttk

#Connect to the Red Pitaya

HOSTNAME1 = '192.168.1.17' # pumplocker
HOSTNAME2 = '192.168.1.3' # locallocker
HOSTNAME3 = '192.168.1.27' # MClocker fast loop
HOSTNAME4 = '192.168.1.32' # MClocker slow loop
# HOSTNAME1 = '_FAKE_' # pumplocker
# HOSTNAME2 = '_FAKE_' # locallocker
# HOSTNAME3 = '_FAKE_' # MClocker fast loop
# HOSTNAME4 = '_FAKE_' # MClocker slow loop

p1 = pyrpl.Pyrpl(config='',  # do not use a config file 
                hostname=HOSTNAME1, gui=False)
p2 = pyrpl.Pyrpl(config='',  # do not use a config file
                hostname=HOSTNAME2)
p3 = pyrpl.Pyrpl(config='',  # do not use a config file
                hostname=HOSTNAME3)
p4 = pyrpl.Pyrpl(config='',  # do not use a config file
                hostname=HOSTNAME4)

# Make shortcuts for the modules to be used
p1_asg0=p1.rp.asg0
p1_asg1=p1.rp.asg1
p1_pid0=p1.rp.pid0
p1_pid1=p1.rp.pid1

p2_asg0=p2.rp.asg0
p2_asg1=p2.rp.asg1
p2_pid0=p2.rp.pid0
p2_pid1=p2.rp.pid1

p3_asg0=p3.rp.asg0
p3_asg1=p3.rp.asg1
p3_pid0=p3.rp.pid0
p3_pid1=p3.rp.pid1
p3_iq0=p3.rp.iq0

p4_pid0=p4.rp.pid0
p4_pid1=p4.rp.pid1
# Set default values for modules
p1_asg0.setup(waveform='ramp', 
              frequency=10, 
              amplitude=1, 
              offset=0, 
              trigger_source='immediately', 
              output_direct='off', 
              start_phase=0)
p1_asg1.setup(waveform='ramp', 
              frequency=10, 
              amplitude=1, 
              offset=0, 
              trigger_source='immediately', 
              output_direct='out2', 
              start_phase=0)
p1_pid0.setup(input='in1', 
              output_direct='out1', 
              setpoint=0, 
              p=3, 
              i=200, 
              max_voltage=1, 
              min_voltage=-1, 
              pause_gains='pi', 
              paused=True, 
              differential_mode_enabled=False)
p1_pid0.ival = 0
p1_pid0.inputfilter = [607, 0, 0, 0]
# p1_pid1.setup(input='in2', 
#               output_direct='out2', 
#               setpoint=0, 
#               p=0.1, 
#               i=2000, 
#               max_voltage=1, 
#               min_voltage=-1, 
#               pause_gains='pi', 
#               paused=True, 
#               differential_mode_enabled=False)
# p1_pid1.ival = 0
# p1_pid1.inputfilter = [0, 0, 0, 0]

p2_asg0.setup(waveform='ramp', 
              frequency=10, 
              amplitude=1, 
              offset=0, 
              trigger_source='immediately', 
              output_direct='off', 
              start_phase=0)
p2_asg1.setup(waveform='ramp', 
              frequency=10, 
              amplitude=1, 
              offset=0, 
              trigger_source='immediately', 
              output_direct='off', 
              start_phase=0)
p2_pid0.setup(input='in1', 
              output_direct='out1', 
              setpoint=0, 
              p=0.1, 
              i=2000, 
              max_voltage=1, 
              min_voltage=-1, 
              pause_gains='pi', 
              paused=True, 
              differential_mode_enabled=False)
p2_pid0.ival = 0
p2_pid0.inputfilter = [0, 0, 0, 0]
p2_pid1.setup(input='in2', 
              output_direct='out2', 
              setpoint=0, 
              p=0.1, 
              i=2000, 
              max_voltage=1, 
              min_voltage=-1, 
              pause_gains='pi', 
              paused=True, 
              differential_mode_enabled=False)
p2_pid1.ival = 0
p2_pid1.inputfilter = [0, 0, 0, 0]

p3_asg0.setup(waveform='ramp', 
              frequency=10, 
              amplitude=1, 
              offset=0, 
              trigger_source='immediately', 
              output_direct='off', 
              start_phase=0)

p3_asg1.setup(waveform='ramp', 
              frequency=0.1,
              amplitude=0.2, 
              offset=0, 
              trigger_source='immediately', 
              output_direct='off', 
              start_phase=0)

p3_pid0.setup(input='iq0', 
              output_direct='both', 
              setpoint=0, 
              p=-1, 
              i=-200, 
              max_voltage=1, 
              min_voltage=-1, 
              pause_gains='pi', 
              paused=True, 
              differential_mode_enabled=False)
p3_pid0.ival = 0
p3_pid0.inputfilter = [0, 0, 0, 0]

p3_iq0.setup(input='in1',
             acbandwidth=9716.419,
             frequency=10000,
             phase=0,
             bandwidth=[607.13719,0],
             quadrature_factor=1,
             gain=0,
             amplitude=0.002,
             output_direct='out1')
        
p4_pid0.setup(input='in1', 
              output_direct='out1', 
              setpoint=-0.1, 
              p=-4, 
              i=-10, 
              max_voltage=1, 
              min_voltage=0, 
              pause_gains='pi', 
              paused=True, 
              differential_mode_enabled=False)
p4_pid0.ival = 0
p4_pid0.inputfilter = [151.78, 0, 0, 0]

p4_pid1.setup(input='in2',
              output_direct='out2',
              setpoint=0.1,
              p=10,
              i=50,
              max_voltage=1,
              min_voltage=0,
              pause_gains='pi', 
              paused=True, 
              differential_mode_enabled=False)
p4_pid1.ival = 0
p4_pid1.inputfilter = [151.78, 1.1858, 2.37, 0]


# Define event
def p1_ramp_on(channel_num):
    if channel_num == 0:
        p1_asg0.output_direct = 'out1'
    elif channel_num == 1:
        p1_asg1.output_direct = 'out2'
    else:
        print('Invalid channel number')

def p2_ramp_on(channel_num):
    if channel_num == 0:
        p2_asg0.output_direct = 'out1'
        p2_asg0.amplitude = 1
    elif channel_num == 1:
        p2_asg1.output_direct = 'out2'
        p2_asg1.amplitude = 1
    else:
        print('Invalid channel number')

def p2_miniramp_on(channel_num):
    if channel_num == 0:
        p2_asg0.output_direct = 'out1'
        p2_asg0.amplitude = 0.03
    elif channel_num == 1:
        p2_asg1.output_direct = 'out2'
        p2_asg1.amplitude = 0.03
    else:
        print('Invalid channel number')

def p1_ramp_off(channel_num):
    if channel_num == 0:
        p1_asg0.output_direct = 'off'
    elif channel_num == 1:
        p1_asg1.output_direct = 'off'
    else:
        print('Invalid channel number')

def p2_ramp_off(channel_num):
    if channel_num == 0:
        p2_asg0.output_direct = 'off'
    elif channel_num == 1:
        p2_asg1.output_direct = 'off'
    else:
        print('Invalid channel number')

def p1_pid_paused(channel_num):
    if channel_num == 0:
        p1_pid0.paused = True
    elif channel_num == 1:
        p1_pid1.paused = True
    else:
        print('Invalid channel number')

def p2_pid_paused(channel_num):
    if channel_num == 0:
        p2_pid0.paused = True
    elif channel_num == 1:
        p2_pid1.paused = True
    else:
        print('Invalid channel number')

def p1_pid_unpaused(channel_num):
    if channel_num == 0:
        p1_pid0.paused = False
    elif channel_num == 1:
        p1_pid1.paused = False
    else:
        print('Invalid channel number')

def p2_pid_unpaused(channel_num):
    if channel_num == 0:
        p2_pid0.paused = False
    elif channel_num == 1:
        p2_pid1.paused = False
    else:
        print('Invalid channel number')

def p1_pid_reset(channel_num):
    if channel_num == 0:
        p1_pid0.ival = 0
    elif channel_num == 1:
        p1_pid1.ival = 0
    else:
        print('Invalid channel number')

def p2_pid_reset(channel_num):
    if channel_num == 0:
        p2_pid0.ival = 0
    elif channel_num == 1:
        p2_pid1.ival = 0
    else:
        print('Invalid channel number')

def p3_ramp_on(channel_num):
    if channel_num == 0:
        p3_asg0.output_direct = 'out1'
    elif channel_num == 1:
        p3_asg1.output_direct = 'out2'
    else:
        print('Invalid channel number')

def p3_ramp_off(channel_num):
    if channel_num == 0:
        p3_asg0.output_direct = 'off'
    elif channel_num == 1:
        p3_asg1.output_direct = 'off'
    else:
        print('Invalid channel number')

def p3_pid_paused(channel_num):
    if channel_num == 0:
        p3_pid0.paused = True
    elif channel_num == 1:
        p3_pid1.paused = True
    else:
        print('Invalid channel number')

def p3_pid_unpaused(channel_num):
    if channel_num == 0:
        p3_pid0.paused = False
    elif channel_num == 1:
        p3_pid1.paused = False
    else:
        print('Invalid channel number')

def p3_pid_reset(channel_num):
    if channel_num == 0:
        p3_pid0.ival = 0
    elif channel_num == 1:
        p3_pid1.ival = 0
    else:
        print('Invalid channel number')

def slow_ramp(state):
    if state == 'on':
        p3_asg1.output_direct = 'out1'
        p3_asg1.waveform = 'ramp'
        p3_asg1.offset = 0
    if state == 'off':
        p3_asg1.output_direct = 'out1'
        current_out1 = p3.rp.sampler.out1
        p3_asg1.waveform = 'dc'
        p3_asg1.offset = current_out1


def get_ival():
    p1_pid0_ival.set(float('%.4f'% p1_pid0.ival))
    p2_pid0_ival.set(float('%.4f'% p2_pid0.ival))
    p2_pid1_ival.set(float('%.4f'% p2_pid1.ival))
    p3_pid0_ival.set(float('%.4f'% p3_pid0.ival))
    root.after(200, get_ival)

# GUI
root = tk.Tk()
root.title("Locking GUI")
frame = ttk.Frame(root, padding="10")
frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

pump_rp_state = tk.StringVar(value='pump_rp_state')
local_rp_state = tk.StringVar(value='local_rp_state')
MC_rp_state = tk.StringVar(value='MC_rp_state')

p1_pid0_ival = tk.DoubleVar(value=0)
p2_pid0_ival = tk.DoubleVar(value=0)
p2_pid1_ival = tk.DoubleVar(value=0)
p3_pid0_ival = tk.DoubleVar(value=0)

ttk.Label(frame, textvariable=pump_rp_state).grid(column=0, row=0)
ttk.Label(frame, textvariable=local_rp_state).grid(column=1, row=0)
ttk.Label(frame, textvariable=MC_rp_state).grid(column=2, row=0)

ttk.Label(frame, text="Pump pid ival:").grid(column=0, row=1)
ttk.Label(frame, textvariable=p1_pid0_ival).grid(column=1, row=1, sticky=tk.W)
ttk.Label(frame, text="Local pid0 ival:").grid(column=0, row=2)
ttk.Label(frame, textvariable=p2_pid0_ival).grid(column=1, row=2, sticky=tk.W)
ttk.Label(frame, text="Local pid1 ival:").grid(column=0, row=3)
ttk.Label(frame, textvariable=p2_pid1_ival).grid(column=1, row=3, sticky=tk.W)

ttk.Label(frame, text="MC pid ival:").grid(column=0, row=4)
ttk.Label(frame, textvariable=p3_pid0_ival).grid(column=1, row=4, sticky=tk.W)

ttk.Label(frame, text="----------------------- SHORT CUT -----------------------").grid(column=0, row=5, columnspan=3)
ttk.Label(frame, text="Pump&Local rp: z = ramp, r = reset, f = lock, c = miniramp").grid(column=0, row=6, columnspan=3, sticky=tk.W)
ttk.Label(frame, text="MC rp: ctrl+z = ramp, ctrl+r = reset, ctrl+n = coarselock, ctrl+m = finelock").grid(column=0, row=7, columnspan=3, sticky=tk.W)

# Bind shortcut keys
root.bind('<Control-q>', lambda e: root.destroy())

root.bind('r', lambda e: [p1_pid_reset(0), p2_pid_reset(0), p2_pid_reset(1)])
root.bind('z', lambda e: [p1_pid_paused(0), p2_pid_paused(0), p2_pid_paused(1), 
                          p1_pid_reset(0), p2_pid_reset(0), p2_pid_reset(1),
                          p1_ramp_on(0), p2_ramp_on(0), p2_ramp_on(1),
                          pump_rp_state.set('Pump Ramping'), local_rp_state.set('Local Ramping')])
root.bind('f', lambda e: [p1_ramp_off(0), p2_ramp_off(0), p2_ramp_off(1),
                          p1_pid_unpaused(0), p2_pid_unpaused(0), p2_pid_unpaused(1),
                          pump_rp_state.set('Pump Locked'), local_rp_state.set('Local Locked')])
root.bind('c', lambda e: [p1_pid_paused(0), p2_pid_paused(0), p2_pid_paused(1), 
                          p1_pid_reset(0), p2_pid_reset(0), p2_pid_reset(1),
                          p1_ramp_on(0), p2_miniramp_on(0), p2_ramp_off(1),
                          pump_rp_state.set('Pump miniramping'), local_rp_state.set('Local Ramping')])

root.bind('<Control-r>', lambda e: p3_pid_reset(0))
root.bind('<Control-z>', lambda e: [p3_pid_paused(0),
                                    p3_pid_reset(0), 
                                    p3_ramp_on(0), 
                                    p3_ramp_off(1),
                                    MC_rp_state.set('MC Ramping')])
root.bind('<Control-n>', lambda e: [p3_ramp_off(0),
                                    slow_ramp('on'), 
                                    p3_pid_unpaused(0),
                                    MC_rp_state.set('MC Coarse Locking')])
root.bind('<Control-m>', lambda e: [slow_ramp('off'), 
                                    p3_pid_reset(0), 
                                    p3_pid_unpaused(0),
                                    MC_rp_state.set('MC Fine Locking')])

root.after(200, get_ival)
root.mainloop()