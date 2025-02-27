from NKTP_DLL import *

result = registerWrite('COM5', 15, 0x30, 0x03, -1)
print('Setting emission ON - Extreme:', RegisterResultTypes(result))


