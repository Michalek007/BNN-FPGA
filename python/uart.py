import time
import serial
import matplotlib.pyplot as plt
import numpy as np


from utils import one_hot_encoder, prepare_mnist_data


x = plt.imread('digit_images_samples\\img_1.jpg')
y = [2]

x = np.array([x])
x, y = prepare_mnist_data(x, y)

uart = serial.Serial(port='COM13', baudrate=19200, bytesize=8, parity=serial.PARITY_NONE,
                     stopbits=serial.STOPBITS_ONE, timeout=0)

print('True digit: ')
print(np.argmax(y[0]))


i = 0
for value in x[0][0]:
    i += 1
    value = int(value)
    uart.write(value.to_bytes(1, byteorder='big'))
    if i % 3 == 0:
        time.sleep(0.1)
        output = int.from_bytes(uart.read_all(), byteorder='big', signed=False)
        print('\nPredicted digit: ')
        print(output)
