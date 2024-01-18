import requests
import json

def uploadPredefinedProfile(ip, profileType, center, bandwidth, attn, port, timeout=20):
    data = {'type' : profileType, 'port' : port, 'center' : center, 'bandwidth' : bandwidth, 'attn' : attn}
    r = requests.post('http://' + ip + '/waveshaper/loadprofile', json.dumps(data), timeout=timeout)
    return r