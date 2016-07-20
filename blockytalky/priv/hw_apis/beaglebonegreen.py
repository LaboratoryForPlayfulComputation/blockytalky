from grovepi import *
from beaglebonegreen_adc import *
import Adafruit_BBIO.GPIO as GPIO

NO_SENSOR = -1
#def setup(sensorA0 = NO_SENSOR, sensorA1 = NO_SENSOR, sensorA2 = NO_SENSOR, sensorD2 = NO_SENSOR, sensorD3 = NO_SENSOR, sensorD4 = NO_SENSOR, sensorD5 = NO_SENSOR, sensorD6 = NO_SENSOR, sensorD7 = NO_SENSOR, sensorD8 = NO_SENSOR):
def setup(io_vals = []): #array with indices as ports and values as plugged-in-component io types 
    #0  1  2  3  4  5  6  7  8  9  ... 10     11    12    13
    #A0 A1 A2 D3 D4 D5 D6 D7 D8 D2 ... SERIAL I2C-1 I2C-2 I2C-3
   #loop through and check all
    for i in range(len(io_vals)):
        print "port" + io_vals[i]
		set_sensor_type(i,io_vals[i])
    return

def get_sensor_value(port_num,sensor_type,sensor_io):
    val = 0
    val2 = 0
    print "sensor io is INPUT, port_num:", port_num
    try: 
	    if sensor_type == "analog":
	    	val = 2
	    elif sensor_type == "digital":
			val = 1 #GPIO.input("P9_22") check hw update on front-end  
    except: 
	    return "Error"
    if (val != val or val2 != val2):
	    return -2
    else:
        return val

def set_sensor_type(port_num, sensor_io): #sets the pinmode (I/O) if applicable
    print "*********** setting sensor type **************"
    print "port number: ", port_num, "sensor_io: ", sensor_io
    if (sensor_io == "OUTPUT"):
    	if (port_num == 1):
    		GPIO.setup("P9_22", GPIO.OUT)
    	else:
    		print "okay" #add I2C support
    else: #INPUT
    	if (port_num == 1):
    		GPIO.setup("P9_22", GPIO.IN)
    	else:
    		print "okay" #add I2C support
    return

#Writes values to ports
def set_component(port_num,value,component_type):
    if component_type == "digital":
        print "setting digital component..."
	    set_digital_component(port_num,value)
	#for now we do not have I2C output
    return

#Writes digital value to digital component
def set_digital_component(port_num,value):
    if (value == True): #python considers all values != 0 or False to be true
		GPIO.output("P9_22", GPIO.HIGH)
    else:
		GPIO.output("P9_22", GPIO.LOW)
    return

#Writes analog value to analog component
def set_analog_component(port_num,value):
    	analogWrite(port_num,value)
    return
