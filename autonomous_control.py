import numpy as np
import cv2 as cv
import math

cap = cv.VideoCapture(0)

ret, frame = cap.read()
bbox = cv.selectROI('select', frame, False)

total_width, total_height = frame.shape[0], frame.shape[1]
total_mid_x, total_mid_y = total_width // 2, total_height // 2

x, y, w, h = bbox

roi = frame[y:y+h, x:x+w]
hsv_roi = cv.cvtColor(roi, cv.COLOR_BGR2HSV)
mask = cv.inRange(hsv_roi, np.array((0., 60., 32.)),
                  np.array((180., 255., 255.)))
roi_hist = cv.calcHist([hsv_roi], [0], mask, [180], [0, 180])
cv.normalize(roi_hist, roi_hist, 0, 255, cv.NORM_MINMAX)

term_crit = (cv.TERM_CRITERIA_EPS | cv.TERM_CRITERIA_COUNT, 10, 1)

while(1):
    ret, frame = cap.read()

    if ret == True:
        hsv = cv.cvtColor(frame, cv.COLOR_BGR2HSV)
        dst = cv.calcBackProject([hsv], [0], roi_hist, [0, 180], 1)

        ret, track_window = cv.meanShift(dst, bbox, term_crit)

        x, y, w, h = track_window

        mid_x, mid_y = x + w // 2, y + h // 2
        if not math.isclose(mid_x, total_mid_x, total_width // 10):
            if mid_x < total_mid_x:
                # Move left
                print("Move Left")
            else:
                # Move right
                print("Move Right")
        if not math.isclose(mid_y, total_mid_y, total_height // 10):
            if mid_y < total_mid_y:
                # Move up
                print("Move Up")
            else:
                # Move down
                print("Move Down")
        

        k = cv.waitKey(30) & 0xff
        if k == 27:
            break
    else:
        break
cap.release()
cv.destroyAllWindows()