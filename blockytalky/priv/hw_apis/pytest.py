import grovepi
import time


BUZZER = 3
grovepi.pinMode(BUZZER,"OUTPUT")

while True:
	try:
		grovepi.digitalWrite(BUZZER,0)
		i = input()
		while i != -1:
			grovepi.analogWrite(BUZZER,i)
			i = input()
		grovepi.analogWrite(BUZZER,0)
		#grovepi.digitalWrite(BUZZER,1)
		#time.sleep(1)
		#grovepi.digitalWrite(BUZZER,0)
	except:
		print ("error")
