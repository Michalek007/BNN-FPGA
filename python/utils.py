import numpy as np

from mnist_data_loader import MnistDataloader


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


def get_mnist_data(n_training_samples: int, n_test_samples: int):
    """ Returns prepared MNIST dataset.
        Args:
           n_training_samples: number of samples from training dataset
           n_test_samples: number of samples from test dataset
        Returns:
             (x_train, y_train), (x_test, y_test)
             x_train, y_train -> numpy arrays of training dataset
             x_test, y_test -> numpy arrays of test dataset
    """

    mnist_base_path = 'C:\\Users\\Public\\Projects\\MachineLearning\\Datasets\\archive\\'
    mnist_loader = MnistDataloader(
        training_images_filepath=mnist_base_path + 'train-images.idx3-ubyte',
        training_labels_filepath=mnist_base_path + 'train-labels.idx1-ubyte',
        test_images_filepath=mnist_base_path + 't10k-images.idx3-ubyte',
        test_labels_filepath=mnist_base_path + 't10k-labels.idx1-ubyte',
    )

    (x_train, y_train), (x_test, y_test) = mnist_loader.load_data()

    # training data
    x_train = x_train[0:n_training_samples]
    y_train = y_train[0:n_training_samples]

    x_train = np.array(x_train)
    x_train, y_train = prepare_mnist_data(x_train, y_train)

    # validation data
    x_test = x_test[0:n_test_samples]
    y_test = y_test[0:n_test_samples]

    x_test = np.array(x_test)
    x_test, y_test = prepare_mnist_data(x_test, y_test)

    return (x_train, y_train), (x_test, y_test)
