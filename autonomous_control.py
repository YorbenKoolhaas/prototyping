import numpy as np
import cv2 as cv
import math
import RPi.GPIO as GPIO
from gpiozero import PWMOutputDevice
from time import sleep
from adafruit_motorkit import MotorKit
from adafruit_motor import stepper


def clockwise():
	
	global arr1
	global arr2
	
	arrOUT = arr1[3:] + arr1[:3]
	arr1 = arr2
	arr2 = arrOUT
	
	GPIO.output(chan_list, arrOUT)
	sleep(DELAY)
	
	return True
	
def counterclockwise():
	global arr1
	global arr2
	
	arrOUT = arr1[1:] + arr1[:1]
	arr1 = arr2
	arr2 = arrOUT
	
	GPIO.output(chan_list, arrOUT)
	sleep(DELAY)
	
	return True

def double_clockwise():

	kit.stepper1.onestep(direction=stepper.FORWARD, style=stepper.SINGLE)
	kit.stepper2.onestep(direction=stepper.BACKWARD, style=stepper.SINGLE)
	sleep(DELAY)

	return True

def double_counterclockwise():

	kit.stepper1.onestep(direction=stepper.BACKWARD, style=stepper.SINGLE)
	kit.stepper2.onestep(direction=stepper.FORWARD, style=stepper.SINGLE)
	sleep(DELAY)

	return True


if __name__ == '__main__':

    TOLERANCE = 25 # decides when motors start moving, higher value = more sensitivity
    DELAY = 0.001 # delay between steps of the motors

    # defining GPIO pins for middle motor
    chan_list = [23, 27, 18, 17]
    chan_list.reverse()
    ENA = PWMOutputDevice(25)
    ENB = PWMOutputDevice(24)

    GPIO.setmode(GPIO.BCM)
    GPIO.setwarnings(False)

    for pin in chan_list:
        print(f'setup pin: {pin}')
        GPIO.setup(pin, GPIO.OUT)

    # defines the pulses for the coils
    arr1 = [1, 1, 0, 0]
    arr2 = [0, 1, 1, 0]

    kit = MotorKit() # MotorKit is used for the stepper motor hat

    # initializing object tracking
    cap = cv.VideoCapture(0)

    ret, frame = cap.read()
    bbox = cv.selectROI('select', frame, False)
    x, y, w, h = bbox

    # used for calculating the tolerance
    total_width, total_height = frame.shape
    total_mid_x, total_mid_y = total_width // 2, total_height // 2

    # selecting the region of interest and calculating pdf
    roi = frame[y:y+h, x:x+w]
    hsv_roi = cv.cvtColor(roi, cv.COLOR_BGR2HSV)
    mask = cv.inRange(hsv_roi, np.array((0., 60., 32.)),
                    np.array((180., 255., 255.)))
    roi_hist = cv.calcHist([hsv_roi], [0], mask, [180], [0, 180])
    cv.normalize(roi_hist, roi_hist, 0, 255, cv.NORM_MINMAX)

    # termination criteria for the mean shift algorithm
    term_crit = (cv.TERM_CRITERIA_EPS | cv.TERM_CRITERIA_COUNT, 10, 1)

    while True:
        ret, frame = cap.read()

        if ret == True:
            hsv = cv.cvtColor(frame, cv.COLOR_BGR2HSV)
            dst = cv.calcBackProject([hsv], [0], roi_hist, [0, 180], 1)

            ret, track_window = cv.meanShift(dst, bbox, term_crit)

            x, y, w, h = track_window

            mid_x, mid_y = x + w // 2, y + h // 2

            # only move motors if out of tolerance
            if not math.isclose(mid_x, total_mid_x, abs_tol=total_width // TOLERANCE):
                # determining direction
                if mid_x < total_mid_x:
                    clockwise()
                else:
                    counterclockwise()

            if not math.isclose(mid_y, total_mid_y, abs_tol=total_height // TOLERANCE):
                if mid_y < total_mid_y:
                    double_clockwise()
                else:
                    double_counterclockwise()
            
            # If escape is pressed, exit the loop
            k = cv.waitKey(30) & 0xff
            if k == 27:
                break
        else:
            break
    
    # Close all windows
    cap.release()
    cv.destroyAllWindows()
    # Reset GPIO pins
    GPIO.output(chan_list, (0, 0, 0, 0))
    GPIO.cleanup()