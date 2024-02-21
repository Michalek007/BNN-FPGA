import time
import serial
import matplotlib.pyplot as plt
import numpy as np

from utils import prepare_mnist_data


def uart_init():
    """ UART initialisation. Creates serial.Serial object.

        Returns:
            serial.Serial object
    """
    uart = serial.Serial(port='COM13', baudrate=19200, bytesize=8, parity=serial.PARITY_NONE,
                         stopbits=serial.STOPBITS_ONE, timeout=0)
    return uart


def uart_send_digit_image(file_name: str):
    """ Sends encoded digit image via UART.

        Args:
            file_name: 28x28 pixels image with digit number as name

        Returns:
            tuple of predicted digit collected via UART and true digit
    """
    uart = uart_init()

    x = plt.imread(file_name)

    y = file_name.split('\\')[-1].split('.')[0]
    y = [int(y)]

    x = np.array([x])
    x, y = prepare_mnist_data(x, y)

    print('True digit: ')
    print(np.argmax(y[0]))

    for value in x[0][0]:
        value = int(value)
        print(value)
        uart.write(value.to_bytes(1, byteorder='big'))

    time.sleep(0.1)
    output = int.from_bytes(uart.read_all(), byteorder='big', signed=False)
    print('\nPredicted digit: ')
    print(output)

    return output, y


if __name__ == '__main__':
    uart_send_digit_image('digit_images_samples\\0.jpg')
