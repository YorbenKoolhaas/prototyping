# Usage Guide

In this repository there are 3 main files: autonomous_control.py, object_tracker.py and stepper.py. Before running any of these programs, please make sure both motor driver boards are correctly connected to a sufficient power supply (>=9 volt).

stepper.py is the program where the motors are controlled by the keyboard.
To run stepper.py simply open a terminal on the raspberry pi and enter this command: 
`python stepper.py`
The program should setup 4 pins and then initialize pygame (this can take a few seconds). A pygame window should open after setting up the pins. When focused on the pygame window, the motors are controlled by the keys: W, A, S and D. W and S control the double stepper motors and A and D control the single stepper motor.
If the motors do not move check the following:
1. Do the motor driver boards have power?
2. Is the raspberry pi focused on the pygame window?
3. Are there any connectivity issues (keyboard, lose wires)?

To close the program simply go back to the terminal and press `ctrl+c`

object_tracker.py is the program where the object tracking algorithm is implemented. For this program the motors are not needed, but a camera is required.
To run object_tracker.py simply open a terminal on the raspberry pi and type in:
`python object_tracker.py`
As soon as the program is run, it turns on the camera and takes a single frame. A window should pop up with this frame. On this window you can select the area you want to track by dragging the mouse while pressing left mouse button. 
A blue rectangle should now be drawn on the frame. Press enter to open a new window with live tracking or repeat the selecting process if the rectangle is not correctly placed.

So far I have not encountered any problems running this program.

To close the program press `esc` while focused on one of the pop up windows

Lastly autonomous_control.py is the program where the object tracking and motor control are combined
To run autonomous_control.py simply open a terminal on the raspberry pi and enter the following command:
`python autonomous_control.py`
This program works the same as object_tracker.py, but now the motors should move according to the position of the object.
If any issues arise check the tips on stepper.py. In addition to that check if the tracking window is aligned with the object you are trying to check.

There are some videos in the videos folder that show how the program is supposed to work.
