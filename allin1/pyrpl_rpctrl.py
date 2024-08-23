import pyrpl
from parameter_table import HOSTNAME_RP1, HOSTNAME_RP2, HOSTNAME_RP3, HOSTNAME_RP4

#Connect to the Red Pitaya
p1 = pyrpl.Pyrpl(config='',  # do not use a config file 
                hostname=HOSTNAME_RP1, gui=True)
p2 = pyrpl.Pyrpl(config='',  # do not use a config file
                hostname=HOSTNAME_RP2, gui=True)
p3 = pyrpl.Pyrpl(config='',  # do not use a config file
                hostname=HOSTNAME_RP3, gui=True)
p4 = pyrpl.Pyrpl(config='',  # do not use a config file
                hostname=HOSTNAME_RP4, gui=False)

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

p4_asg0=p4.rp.asg0
p4_pid0=p4.rp.pid0
p4_pid1=p4.rp.pid1

# Set default values for modules
def p1_setup():
    p1_asg0.setup(waveform='ramp', 
                frequency=10, 
                amplitude=1, 
                offset=0, 
                trigger_source='immediately', 
                output_direct='off', 
                start_phase=0)
    p1_asg1.setup(waveform='ramp', 
                frequency=10, #找模式时改成10
                amplitude=1, 
                offset=0, 
                trigger_source='immediately', 
                output_direct='off', 
                start_phase=0)
    p1_pid0.setup(input='in1', 
                output_direct='out1', 
                setpoint=0, 
                p=1.0010e-1, # 20_initial # 3_toptica_as_local_last_version
                i=1.0000e3, # 1000_initial # 200_toptica_as_local_last_version
                max_voltage=1, 
                min_voltage=-1, 
                pause_gains='pi', 
                paused=True, 
                differential_mode_enabled=False)
    p1_pid0.ival = 0
    p1_pid0.inputfilter = [1.944e4, 0, 0, 0] # []_initial # 607, 1.944e4, 0, 0_toptica_as_local_last_version
    p1_pid1.setup(input='off', 
                  output_direct='out2', 
                  setpoint=0, 
                  p=1.0010e-2, # 3_toptica_as_local_last_version
                  i=5.0000e2, #200_toptica_as_local_last_version
                  max_voltage=1, 
                  min_voltage=-1, 
                  pause_gains='pi', 
                  paused=True, 
                  differential_mode_enabled=False)
    p1_pid1.ival = 0
    p1_pid1.inputfilter = [0, 0, 0, 0] # []_initial # 607, 1.944e4, 0, 0_toptica_as_local_last_version
def p2_setup():
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
                p=1.0010e-1, # 0.1_toptica_as_local_last_version
                i=2.0000e3, # 2000_toptica_as_local_last_version
                max_voltage=1, 
                min_voltage=-1, 
                pause_gains='pi', 
                paused=True, 
                differential_mode_enabled=False)
    p2_pid0.ival = 0
    p2_pid0.inputfilter = [1.944e4, 0, 0, 0] # [] # 1.944e4, 0, 0, 0_toptica_as_local_last_version
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
    p2_pid1.inputfilter = [1.944e4, 0, 0, 0] #[]

def p3_setup():
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
                p=-0.4, # -1 before ,-0.1 
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
                frequency=100000, # 10000 before
                phase=70, # 0 before
                bandwidth=[9.716e3,9.716e3], # [607.13719,0] before
                quadrature_factor=10, # 1 before
                gain=0,
                amplitude=0.1, # 0.002 before
                output_direct='out1')
        
def p4_setup():
    p4_asg0.setup(waveform='ramp', 
                frequency=10, 
                amplitude=1, 
                offset=0, 
                trigger_source='immediately', 
                output_direct='out2', 
                start_phase=0)
    p4_pid0.setup(input='in1', 
                output_direct='out1', 
                setpoint=-0.1, 
                p=-4, 
                i=-10, 
                max_voltage=1, 
                min_voltage=0, 
                pause_gains='pi', 
                paused=False, 
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
                paused=False, 
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
        p2_asg0.amplitude = 0.25
    elif channel_num == 1:
        p2_asg1.output_direct = 'out2'
        p2_asg1.amplitude = 0.25
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

