import time
import serial
import matplotlib.pyplot as plt
import numpy as np

from utils import prepare_mnist_data, get_mnist_data


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
        uart.write(value.to_bytes(1, byteorder='big'))

    time.sleep(0.1)
    output = int.from_bytes(uart.read_all(), byteorder='big', signed=False)
    print('\nPredicted digit: ')
    print(output)

    return output, y


def uart_mnist_validate():
    """ Validates implemented BNN mnist model on FPGA via UART.

        Returns:
            calculated accuracy based on equation: correct predictions / samples
    """
    uart = uart_init()

    (x_train, y_train), (x_test, y_test) = get_mnist_data(n_training_samples=1000, n_test_samples=10_000)

    samples = len(x_test)
    correct = 0
    for i in range(samples):
        for value in x_test[i][0]:
            value = int(value)
            uart.write(value.to_bytes(1, byteorder='big'))
        time.sleep(0.1)
        predicted_class = int.from_bytes(uart.read_all(), byteorder='big', signed=False)
        true_class = np.argmax(y_test[i])
        if predicted_class == true_class:
            correct += 1

    accuracy = correct / samples
    return accuracy


if __name__ == '__main__':
    uart_send_digit_image('digit_images_samples\\0.jpg')

    # uart_mnist_validate()
