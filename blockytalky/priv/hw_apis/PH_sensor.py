import grovepi
import struct 
import serial,time
Count =0.000
print(Count)
Voltage =0.000
Intercept = -19.295;
Slope = 175.416;
grovepi.pinMode(1,"INPUT")
while True:
    try:
        # Get sensor value
        sensor_value = grovepi.analogRead(1)
	ph_value=sensor_value/0.25
#	time.sleep(2)
#Count=grovepi.analogRead(1)
#Voltage = (Count / 256) 
#SensorReading= Intercept + Voltage * Slope;
	print(ph_value)
    except IOError:
	print("error")
 
