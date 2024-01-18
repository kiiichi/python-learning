import numpy as np 
from io import StringIO

def splitWspString(string):
    #            fileName of wspFile, delimiter= tab, rotate output
    wspCols = np.genfromtxt(StringIO(string), delimiter='\t', unpack=True)
    #          wsFreq,    wsAttn,     wsPhase,    wsPort
    return wspCols[0], wspCols[1], wspCols[2], wspCols[3]