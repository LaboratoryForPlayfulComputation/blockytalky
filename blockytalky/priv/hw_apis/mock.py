
import random
PORT_A = 0
PORT_B = 1
PORT_C = 2
PORT_D = 3

def setup():
    return "hello"
def echo(v):
    return v
def get_sensor_value(port_num):
    if port_num == 0:
        return 0
    if port_num == 1:
        return 1
    if port_num == 2:
        return random.randint(0,1)
    if port_num == 3:
        return random.randint(-100,100)
def set_sensor_type(port_num, type):
    return 1
