import numpy as np 

def createWspString(wsFreq, wsAttn, wsPhase, wsPort):
    wsAttn[np.isnan(wsAttn)] = 60
    wsAttn[wsAttn>60] = 60
    wsAttn[wsAttn<=0] = 0
    wsPhase[np.isnan(wsPhase)] = 0
    wspString = ''
    for i in range(len(wsFreq)):
        wspString = '%s%.4f\t%.4f\t%.4f\t%d\n' % (wspString, wsFreq[i], wsAttn[i], wsPhase[i], wsPort[i])
    return wspString