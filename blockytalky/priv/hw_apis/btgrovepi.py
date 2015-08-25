from grovepi import *



NO_SENSOR = -1
#def setup(sensorA0 = NO_SENSOR, sensorA1 = NO_SENSOR, sensorA2 = NO_SENSOR, sensorD2 = NO_SENSOR, sensorD3 = NO_SENSOR, sensorD4 = NO_SENSOR, sensorD5 = NO_SENSOR, sensorD6 = NO_SENSOR, sensorD7 = NO_SENSOR, sensorD8 = NO_SENSOR):
def setup(io_vals = []): #array with indices as ports and values as plugged-in-component io types 
    #0  1  2  3  4  5  6  7  8  9  ... 10     11    12    13
    #A0 A1 A2 D3 D4 D5 D6 D7 D8 D2 ... SERIAL I2C-1 I2C-2 I2C-3
   #loop through and check all
    for i in range(len(io_vals)):
	if io_vals[i] == "INPUT":
		if i == 9:
			set_sensor_type(2,io_vals[i])
		else:
			set_sensor_type(i,io_vals[i])
	if io_vals[i] == "OUTPUT":
		if i == 9:
			set_sensor_type(2,io_vals[i])
		else:
			set_sensor_type(i,io_vals[i])
    return
def get_sensor_value(port_num,sensor_type,sensor_io):
    try: 
	    if sensor_io == "ULTRASONIC":
		return ultrasonicRead(port_num)
	    if sensor_io == "DHT":
		return dht(port_num,0)

	    if sensor_type == "analog":
		return analogRead(port_num)
	    elif sensor_type == "digital":
		return digitalRead(port_num)
	    else:
		 return -1
    except IOError: 
	    return "Error"
def set_sensor_type(port_num, sensor_io): #sets the pinmode if applicable
    if (sensor_io != "DHT" and sensor_io != "ULTRASONIC"):
	pinMode(port_num,sensor_io)
    return

#Writes values to ports
def set_component(port_num,value,component_type):
    if component_type == "digital":
	set_digital_component(port_num,value)
    elif component_type == "analog":
	set_analog_component(port_num,value)
    else:
	set_pwm_component(port_num,value)
    return

#Writes digital value to digital component
def set_digital_component(port_num,value):
    #can set with true/false or with 0/1
    if value == True:
	digitalWrite(port_num,1)
    elif value == False:
	digitalWrite(port_num,0)
    else:
	digitalWrite(port_num,value)
    return

#Writes analog value to analog component
def set_analog_component(port_num,value):
    analogWrite(port_num,value)
    return

#Write analog value to PWM component
def set_pwm_component(port_num,value):
    analogWrite(port_num,value)
    return
