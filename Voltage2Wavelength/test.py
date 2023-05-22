import re

s = ' 过偶1.1vfac80.1v.csv'

match = re.search(r'\s?(\d+\.?\d*)v(\d+\.?\d*)', s)

if match:
    num1 = match.group(1)
    num2 = match.group(2)

    print(num1, num2)
