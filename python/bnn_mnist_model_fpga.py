import numpy as np
import json

from mnist_data_loader import MnistDataloader
from utils import prepare_mnist_data

np.random.seed(0)


class Layer:
    """ Implements layer in network.
        Contains forward method for forward propagation.

        If from_dict is given, sets weights based on values for 'weights' key (expected arrays).
        If not generates random weights.

        Attributes:
            output: calculated output array (should be passed to next layer)
            input: given input array (output of previous layer)
    """
    def __init__(self, n_inputs: int, n_neurons: int, from_dict: dict = None, quantize_input: bool = True):

        if from_dict:
            self.weights = np.array(
                from_dict.get('weights')
            )

        else:
            self.weights = 0.10 * np.random.randn(n_inputs, n_neurons)

        self.quantize_input = quantize_input
        self.output = None
        self.input = None
        self.input_error = None

    def forward(self, inputs):
        """ Forward propagation.
            output = dot product(inputs, weights) + biases
        """
        if self.quantize_input:
            inputs = np.sign(inputs)
            inputs[inputs == 0] = 1

        self.input = inputs
        self.output = np.dot(inputs, self.weights)


class ActivationReLU:
    """ ReLU function -> y = x if x > 0 else 0 """
    def __init__(self):
        self.output = None
        self.input = None

    def forward(self, inputs):
        self.input = inputs
        self.output = np.maximum(0, inputs)


class BatchNormalization:
    """ Batch normalization -> gamma * (batch - mean) / std_dev + beta """
    def __init__(self, from_dict: dict):
        self.gamma = np.array(
            from_dict.get('weights')[0]
        )
        self.beta = np.array(
            from_dict.get('weights')[1]
        )
        self.mean = np.array(
            from_dict.get('weights')[2]
        )
        self.std_dev = np.array(
            from_dict.get('weights')[3]
        )
        self.output = None
        self.input = None

    def forward(self, inputs):
        self.input = inputs
        self.output = self.gamma * (inputs - self.mean) / self.std_dev + self.beta


class ActivationSoftmax:
    """ Softmax function -> y = e^x / sum(e^x) """
    def __init__(self):
        self.output = None
        self.input = None

    def forward(self, inputs):
        self.input = inputs
        exp_values = np.exp(inputs)
        probabilities = exp_values / np.sum(exp_values)
        self.output = probabilities


class NeuralNetwork:
    """ Implements neural network model.

        Api:
            validate -> validates model with test data

            predict -> predicts results based on given input

        Attributes:
            layers: list of Layers or activation function objects
    """
    def __init__(self, from_file: str = None):
        self.layers = []

        if from_file:
            self.load_model(file=from_file)

    def add_layer(self, layer):
        """ Adds layer to network.
            Args:
                layer: Layer or activation function object
        """
        self.layers.append(layer)

    def predict(self, input_data):
        """ Predicts output for given input data.
            Args:
                input_data: numpy array of input data
            Returns:
                list of predicted outputs
        """
        samples = len(input_data)
        result = []

        # run network over all samples
        for i in range(samples):
            # forward propagation
            inputs = input_data[i]
            for layer in self.layers:
                layer.forward(inputs)
                inputs = layer.output
            result.append(inputs)

        return result

    def validate(self, x_test, y_test):
        """ Validates network for given test dataset.
            Args:
                x_test: numpy array of X test data
                y_test: numpy array of Y test data (true results)
            Returns:
                accuracy for given dataset (correct predictions / samples)
        """
        samples = len(x_test)
        correct = 0

        # run network over all samples
        for i in range(samples):
            # forward propagation
            inputs = x_test[i]
            for layer in self.layers:
                layer.forward(inputs)
                inputs = layer.output

            out = self.layers[-1].output
            predicted_class = np.argmax(out)

            true_class = np.argmax(y_test[i])

            if predicted_class == true_class:
                correct += 1

        accuracy = correct/samples

        print('\nAccuracy: ')
        print(accuracy)
        return accuracy

    def load_model(self, file: str):
        """ Loads model from given file.
            Args:
                file: file name or path
        """
        with open(file, 'r') as f:
            json_model = json.loads(f.read())

        i = 0
        for layer in json_model:
            if layer.get('type') == 'dense':
                quantize_input = True
                if i == 0:
                    quantize_input = False
                self.add_layer(layer=Layer(0, 0, dict(
                    weights=np.array(layer.get('weights')),
                    ), quantize_input
                ))
                if i == 2:
                    self.add_layer(ActivationSoftmax())
                else:
                    self.add_layer(ActivationReLU())
                i += 1
            elif layer.get('type') == 'batch_normalization':
                self.add_layer(layer=BatchNormalization(dict(
                    weights=np.array(layer.get('weights'))
                    )
                ))


network = NeuralNetwork(from_file='models\\bnn_mnist_model.json')

mnist_base_path = 'C:\\Users\\Public\\Projects\\MachineLearning\\Datasets\\archive\\'
mnist_loader = MnistDataloader(
    training_images_filepath=mnist_base_path + 'train-images.idx3-ubyte',
    training_labels_filepath=mnist_base_path + 'train-labels.idx1-ubyte',
    test_images_filepath=mnist_base_path + 't10k-images.idx3-ubyte',
    test_labels_filepath=mnist_base_path + 't10k-labels.idx1-ubyte',
)

(x_train, y_train), (x_test, y_test) = mnist_loader.load_data()

# training data
N = 30_000
x_train = x_train[0:N]
y_train = y_train[0:N]

x_train = np.array(x_train)
x_train, y_train = prepare_mnist_data(x_train, y_train)

# validation data
N = 10_000
x_test = x_test[0:N]
y_test = y_test[0:N]

x_test = np.array(x_test)
x_test, y_test = prepare_mnist_data(x_test, y_test)


accuracy = network.validate(x_test, y_test)
