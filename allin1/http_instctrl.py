import requests
import json
import numpy as np
from WSMethods import *
from connection_table import HOSTNAME_WS

def ws_dualband_setup(center_pump_wl, space_freq, bandwidth_freq, attenuation=[0,0], phase=[0,0], port=[1,1], ip = HOSTNAME_WS):
    """ This function is used to generate the .wsp file for dual-band wavesheper filter. Return the center wavelngth of each band on OSA.

    Args:
        center_pump_wl: the wavelength of the pump laser in OSA, unit: nm, it will be automaticly compensated the frequency offset between OSA and WS
        space_freq: the frequency spacing between each band and the pump laser, unit: GHz
        bandwidth_freq: the bandwidth of each band, the bandwidth of each band is the same, unit: GHz
        attenuation: the attenuation of each band, the attenuation of each band can be different, use [attn1, attn2] from, unit: dB, do not need negative sign
        phase: the phase of each band, the phase of each band can be different, use [phase1, phase2] from, unit: degree
        port: the port of each band, the port of each band can be different, use [port1, port2] from
        ip: the IP address of the wavesheper, default: HOSTNAME_WS
    """

    # Preparing the data for dual band
    c = 299792.458
    fixed_center_pump_wl = center_pump_wl + 0.027 # Compensate the frequency offset between OSA and WS
    center_pump_freq = c/fixed_center_pump_wl # transfer nm to THz
    center_freq_1 = center_pump_freq - space_freq/1000
    center_freq_2 = center_pump_freq + space_freq/1000
    center_wl_1 = c/center_freq_1 - 0.027
    center_wl_2 = c/center_freq_2 - 0.027
    freq1_l = center_freq_1 - bandwidth_freq/2000
    freq1_h = center_freq_1 + bandwidth_freq/2000
    freq2_l = center_freq_2 - bandwidth_freq/2000
    freq2_h = center_freq_2 + bandwidth_freq/2000

    wsFreq1 = np.linspace(freq1_l, freq1_h, int((freq1_h-freq1_l)/0.001 + 1)).round(3)
    wsAttn1 = np.zeros(wsFreq1.shape) + attenuation[0]
    wsPhase1 = np.zeros(wsFreq1.shape) + phase[0]
    wsPort1 = np.zeros(wsFreq1.shape) + port[0]

    wsFreq2 = np.linspace(freq2_l, freq2_h, int((freq2_h-freq2_l)/0.001 + 1)).round(3)
    wsAttn2 = np.zeros(wsFreq2.shape) + attenuation[1]
    wsPhase2 = np.zeros(wsFreq2.shape) + phase[1]
    wsPort2 = np.zeros(wsFreq2.shape) + port[1]

    # Make blank to combin a .wsp file
    result = requests.get('http://' + ip + '/waveshaper/devinfo').json()
    print(result)
    s = result['startfreq']
    e = result['stopfreq']

    wsFreqBlank0 = np.linspace(s, freq1_l, int((freq1_l-s)/0.001 + 1)).round(3)
    wsAttnBlank0 = np.zeros(wsFreqBlank0.shape)
    wsPhaseBlank0 = np.zeros(wsFreqBlank0.shape)
    wsPortBlank0 = np.zeros(wsFreqBlank0.shape)

    wsFreqBlank1 = np.linspace(freq1_h, freq2_l, int((freq2_l-freq1_h)/0.001 + 1)).round(3)
    wsAttnBlank1 = np.zeros(wsFreqBlank1.shape)
    wsPhaseBlank1 = np.zeros(wsFreqBlank1.shape)
    wsPortBlank1 = np.zeros(wsFreqBlank1.shape)

    wsFreqBlank2 = np.linspace(freq2_h, e, int((e-freq2_h)/0.001 + 1)).round(3)
    wsAttnBlank2 = np.zeros(wsFreqBlank2.shape)
    wsPhaseBlank2 = np.zeros(wsFreqBlank2.shape)
    wsPortBlank2 = np.zeros(wsFreqBlank2.shape)

    wsFreq = np.hstack ([wsFreqBlank0, wsFreq1, wsFreqBlank1, wsFreq2, wsFreqBlank2])
    wsAttn = np.hstack ([wsAttnBlank0, wsAttn1, wsAttnBlank1, wsAttn2, wsAttnBlank2])
    wsPhase = np.hstack ([wsPhaseBlank0, wsPhase1, wsPhaseBlank1, wsPhase2, wsPhaseBlank2])
    wsPort = np.hstack ([wsPortBlank0, wsPort1, wsPortBlank1, wsPort2, wsPortBlank2])

    r = uploadProfile(ip, wsFreq, wsAttn, wsPhase, wsPort)
    
    return center_wl_1, center_wl_2

if __name__ == '__main__':

    ws_dualband_setup(1550, 400, 50, attenuation=[0,0], phase=[0,90], port=[1,1])