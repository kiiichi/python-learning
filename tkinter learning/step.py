from time import sleep
from custfunc import *

def step2target(current_value, target, step):
    """Used to step current_value towards target. Returns the new current_value and how many steps need to be taken."""

    distance = abs(current_value - target)
    left_steps2target = distance // step
    
    if distance < step:
        current_value = target
        left_steps2target = 0
    elif current_value < target:
        current_value += step
    elif current_value > target:
        current_value -= step
    
    return current_value, left_steps2target

current_value = 0
target = -1
step = 1.1

while True:
    current_value, left_steps2target = step2target(current_value, target, step)
    print(f"{current_value}, {left_steps2target}")
    # sleep(0.1)
    if left_steps2target == 0:
        break
