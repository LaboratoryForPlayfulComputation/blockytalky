import serial
import time
PORT="/dev/ttyACM1"
baud=115200
s=serial.Serial(PORT)
s.baudrate =baud
s.parity = serial.PARITY_NONE
s.databits = serial.EIGHTBITS
s.stopbits = serial.STOPBITS_ONE
def setup():
    once=1
    PORT="/dev/ttyACM1"
    baud=115200
    s=serial.Serial(PORT)
    s.baudrate =baud
    s.parity = serial.PARITY_NONE
    s.databits = serial.EIGHTBITS
    s.stopbits = serial.STOPBITS_ONE

def uart_send(data):
    data=str(data)
    send=s.write(data + "#")
    print("reached here")
    return send

def uart_wrapper(deli,data1):
    data=str(data1)
    total=deli+"^"+data+"#"
    tot=str(total)
    send=s.write(total)
    return send

def uart_no(value):
    send=s.write(value+"#")
    return send

if __name__=='__main__':
    uart_wrapper("strin",10)
