import requests
import json
from .createWspString import *

def uploadProfile(ip, wsFreq, wsAttn, wsPhase, wsPort, timeout=20):
    data = {'type' : 'wsp', 'wsp' : createWspString(wsFreq, wsAttn, wsPhase, wsPort)}
    r = requests.post('http://' + ip + '/waveshaper/loadprofile', json.dumps(data), timeout=timeout)
    return r