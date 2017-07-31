import serial
import time
PORT="/dev/ttyACM0"
baud=115200
s=serial.Serial(PORT)
s.baudrate =baud
s.parity = serial.PARITY_NONE
s.databits = serial.EIGHTBITS
s.stopbits = serial.STOPBITS_ONE
def setup():
    once=1
    PORT="/dev/ttyACM0"
    baud=115200
    s=serial.Serial(PORT)
    s.baudrate =baud
    s.parity = serial.PARITY_NONE
    s.databits = serial.EIGHTBITS
    s.stopbits = serial.STOPBITS_ONE

def uart_send(data):
    data=str(data)
    total="Num"+"^"+data+"#"
    send=s.write(total)
    print("reached here")
    return send

def uart_wrapper(deli,data1):
    data=str(data1)
    total="Key"+"^"+deli+"^"+data+"#"
    send=s.write(total)
    print("time")
    return send

def uart_no(value):
    total="group"+"^"+value+"#"
    send=s.write(total)
    return send

if __name__=='__main__':
    uart_wrapper("data",10)
