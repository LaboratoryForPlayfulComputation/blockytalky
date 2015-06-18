from BrickPi import *
#Generic (functional) API for brickpi operations
#Author: Matthew Ahrens
#Originally created: June.13.2015
#
NO_SENSOR = -1

def setup(sensor1 = None, sensor2 = None , sensor3 = None , sensor4 = None):
    BrickPiSetup()
    if(sensor1 != NO_SENSOR):
        BrickPi.SensorType[PORT_1] = sensor1
    if(sensor2 != NO_SENSOR):
        BrickPi.SensorType[PORT_2] = sensor2
    if(sensor3 != NO_SENSOR):
        BrickPi.SensorType[PORT_3] = sensor3
    if(sensor4 != NO_SENSOR):
        BrickPi.SensorType[PORT_4] = sensor4
    BrickPiSetupSensors()
    BrickPi.MotorEnable[PORT_A] = 1 #Enable the Motor A
    BrickPi.MotorEnable[PORT_B] = 1 #Enable the Motor B
    BrickPi.MotorEnable[PORT_C] = 1 #Enable the Motor C
    BrickPi.MotorEnable[PORT_D] = 1 #Enable the Motor D
def get_sensor_value(port_num):
    return BrickPi.Sensor[port_num]
def set_sensor_type(port_num, sensor_type):
    BrickPi.SensorType[port_num] = sensor_type
    BrickPiSetupSensors()
def get_encoder_value(port_num):
    BrickPiUpdateValues()
    return BrickPi.Encoder[port_num]
def set_motor_value(port_num):
    BrickPi.MotorSpeed[port_num]
    BrickPiUpdateValues()
