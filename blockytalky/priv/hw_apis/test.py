import btgrovepi
from grovepi import *
rot = 1
pinMode(rot,"INPUT")
while True:
	try:
		io_vals = []
		print(analogRead(rot))
		"""for i in range(10):
			io = raw_input("Enter io for " + str(i) + " :")
			io_vals.append(io)
		btgrovepi.setup(io_vals)

		type = "default"
		while type != "q":
			type = raw_input("Enter sensor type d or a: ")
			port_num = input("Enter port num: ")
			io = raw_input ("Enter io i or o: ")
			if io == "OUTPUT":
				value = input("Set to value: ")
				btgrovepi.set_component(port_num,value,type)
			else:
				#btgrovepi.set_sensor_type(port_num,io)
				print ("Sensor value: ")
				if io == "DHT":
					[t,h] = btgrovepi.get_sensor_value(port_num,type,io)
					print ("t: ",t," h: ",h)
				else:
					print (btgrovepi.get_sensor_value(port_num,type,io))
			#print ("Sensor type: ")
			#print (btgrovepi.get_port_type(port_num))
			#print ("Sensor io: ")
			#print (btgrovepi.get_port_io(port_num))
		"""
	except TypeError:
		print ("TypeError")
	except IOError:
		print ("IOError")
