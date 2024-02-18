import numpy as np


def one_hot_encoder(input_array, n_classes: int):
    """ Encodes input array in one hot encoding.
        Args:
            input_array: array which consist integers from domain n: <0, N> and n is natural number
            n_classes: number of classes, will length of encoded one hot vector
        Returns:
            One hot encoded array.
    """
    output_array = []
    N = n_classes
    for i in range(len(input_array)):
        i_array = [0 for _ in range(N)]
        i_array[input_array[i]] = 1
        output_array.append(i_array)
    return output_array


def prepare_mnist_data(x, y):
    """ Prepares data obtained from MNIST dataset to be used in NeuralNetwork methods.
        Args:
            x: numpy array containing image data (pixels) in shape N X 28 x 28
            y: array containing numbers from 0 to 9
        Returns:
            x -> numpy array containing vectors of length 28*28
            y -> numpy array containing one hot encoded vectors
    """

    # reshaping 28x28 to vectors 28*28
    x = x.reshape(x.shape[0], 1, 28 * 28)

    # encoding data with one hot code
    y = one_hot_encoder(y, 10)
    y = np.array(y)
    return x, y
