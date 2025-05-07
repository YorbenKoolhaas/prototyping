from gpiozero import OutputDevice
from time import sleep
import pygame
import sys

pygame.init()


def set_step(w1, w2, w3, w4):
    IN1.value = w1
    IN2.value = w2
    IN3.value = w3
    IN4.value = w4


def step_motor(steps, direction=1, delay=0.005):

    for _ in range(steps):
        for step in (step_sequence if direction > 0 else reversed(step_sequence)):
            set_step(*step)
            sleep(delay)


if __name__ == '__main__':

    DELAY = 0.001

    IN1 = OutputDevice(14)
    IN2 = OutputDevice(15)
    IN3 = OutputDevice(18)
    IN4 = OutputDevice(23)

    step_sequence = [
            [1, 0, 0, 0],
            [1, 1, 0, 0],
            [0, 1, 0, 0],
            [0, 1, 1, 0],
            [0, 0, 1, 0],
            [0, 0, 1, 1],
            [0, 0, 0, 1],
            [1, 0, 0, 1]
    ]

    screen = pygame.display.set_mode((100, 100))

    try:
        while True:
            events = pygame.event.get()
            for event in events:
                if event.type == pygame.KEYDOWN:
                    if event.key == pygame.locals.K_w:
                        step_motor(1, direction=1, delay=DELAY)
                    elif event.key == pygame.locals.K_s:
                        step_motor(1, direction=-1, delay=DELAY)

    except KeyboardInterrupt:
        print('Program stopped by user')
        sys.exit()