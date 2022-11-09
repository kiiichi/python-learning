def GetData(n=5, PreData=None):
    '''Collect the data user input. Could append the old data.

    the first position is collecting number ,the second position is the old data you want to append.
    '''
    if PreData is None:
        PreData = []
    for n in range(n):
        a = input('-->')
        PreData.append(a)
    return PreData
