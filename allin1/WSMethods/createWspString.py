import numpy as np 

def createWspString(wsFreq, wsAttn, wsPhase, wsPort):
    wsAttn[np.isnan(wsAttn)] = 60
    wsAttn[wsAttn>60] = 60
    wsAttn[wsAttn<=0] = 0
    wsPhase[np.isnan(wsPhase)] = 0
    wspString = ''
    # for i in range(len(wsFreq)):
    #     wspString = '%s%.4f\t%.4f\t%.4f\t%d\n' % (wspString, wsFreq[i], wsAttn[i], wsPhase[i], wsPort[i])
    for i in range(len(wsFreq)-1):
        wspString = '%s%.4f\t%.4f\t%.4f\t%d\n' % (wspString, wsFreq[i+1], wsAttn[i+1], wsPhase[i+1], wsPort[i+1])
    return wspString