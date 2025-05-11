import numpy as np
import cv2 as cv

opt = 'mean'  # 'mean' or 'cam'

cap = cv.VideoCapture(0)

ret, frame = cap.read()
bbox = cv.selectROI('select', frame, False)

x, y, w, h = bbox

roi = frame[y:y+h, x:x+w]
hsv_roi = cv.cvtColor(roi, cv.COLOR_BGR2HSV)
mask = cv.inRange(hsv_roi, np.array((0., 60., 32.)),
                  np.array((180., 255., 255.)))
roi_hist = cv.calcHist([hsv_roi], [0], mask, [180], [0, 180])
cv.normalize(roi_hist, roi_hist, 0, 255, cv.NORM_MINMAX)

term_crit = (cv.TERM_CRITERIA_EPS | cv.TERM_CRITERIA_COUNT, 10, 1)

while True:
    ret, frame = cap.read()

    if ret == True:
        hsv = cv.cvtColor(frame, cv.COLOR_BGR2HSV)
        dst = cv.calcBackProject([hsv], [0], roi_hist, [0, 180], 1)

        if opt == 'mean':
            ret, track_window = cv.meanShift(dst, bbox, term_crit)
            dx, dy = track_window[0] - x, track_window[1] - y
            x, y, w, h = track_window
            img2 = cv.rectangle(frame, (x, y), (x+w, y+h), 255, 2)
        
        elif opt == 'cam':
            ret, track_window = cv.CamShift(dst, bbox, term_crit)
            dx, dy = track_window[0] - x, track_window[1] - y
            x, y, w, h = track_window
            box_pts = cv.boxPoints(ret)
            frame = cv.polylines(frame, [np.int32(box_pts)], True, 255, 2)

        frame = cv.line(frame, (x + w//2, y + h//2), (x+dx + w//2, y+dy + h//2), (0, 0, 255), 2)
        cv.imshow('gfg', frame)

        k = cv.waitKey(5) & 0xff
        if k == 27:
            break
    else:
        break
cap.release()
cv.destroyAllWindows()