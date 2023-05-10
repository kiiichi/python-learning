import re

s = "ain1.4v83.4v"
numbers = re.findall(r'\d+\.\d+', s)

print(numbers) # Output: ['19.99', '15.99']
