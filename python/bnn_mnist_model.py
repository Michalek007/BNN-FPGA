import numpy as np
import tensorflow as tf
import larq
import json

from mnist_data_loader import MnistDataloader
from utils import one_hot_encoder, prepare_mnist_data


class BnnMnistModel(tf.keras.Model):
    def __init__(self):
        super().__init__()
        self.flatten = tf.keras.layers.Flatten()
        self.dense_1 = larq.layers.QuantDense(
            50,
            kernel_quantizer='ste_sign',
            kernel_constraint='weight_clip',
            use_bias=False,
            activation='relu',
            input_shape=(28*28, 1)
        )
        self.batch_normalization_1 = tf.keras.layers.BatchNormalization(momentum=0.9)
        self.dense_2 = larq.layers.QuantDense(
            50,
            input_quantizer='ste_sign',
            kernel_quantizer='ste_sign',
            kernel_constraint='weight_clip',
            use_bias=False,
            activation='relu',
            input_shape=(50, 1)
        )
        self.batch_normalization_2 = tf.keras.layers.BatchNormalization(momentum=0.9)
        self.dense_last = larq.layers.QuantDense(
            10,
            input_quantizer='ste_sign',
            kernel_quantizer='ste_sign',
            kernel_constraint='weight_clip',
            use_bias=False,
            activation='softmax',
            input_shape=(50, 1)
        )

    def call(self, inputs, training=None, mask=None):
        x = self.flatten(inputs)
        x = self.dense_1(x)
        x = self.batch_normalization_1(x)
        x = self.dense_2(x)
        x = self.batch_normalization_2(x)
        return self.dense_last(x)


mnist_base_path = 'C:\\Users\\Public\\Projects\\MachineLearning\\Datasets\\archive\\'
mnist_loader = MnistDataloader(
    training_images_filepath=mnist_base_path + 'train-images.idx3-ubyte',
    training_labels_filepath=mnist_base_path + 'train-labels.idx1-ubyte',
    test_images_filepath=mnist_base_path + 't10k-images.idx3-ubyte',
    test_labels_filepath=mnist_base_path + 't10k-labels.idx1-ubyte',
)

(x_train, y_train), (x_test, y_test) = mnist_loader.load_data()
print('Dataset loaded!')


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


model = BnnMnistModel()

model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=1e-3),
              loss=tf.keras.losses.CategoricalCrossentropy(),
              metrics=[tf.keras.metrics.CategoricalAccuracy()])
print('Model compiled!')


from_file = True  # choose if load model weights from file or fit model otherwise


if from_file:
    print(model.predict(x_test[0]))
    print(y_test[0])
    model.load_weights('bnn_mnist_model.h5')
else:
    model.fit(x_train, y_train, epochs=35, verbose='2')
    print('Model trained!')


metrics = model.evaluate(x_test, y_test)
print(metrics)


print(model.predict(x_test[0]))
print(y_test[0])


if not from_file:
    model.save_weights('models\\bnn_mnist_model.h5')  # save full precision latent weights


model_dict = []
with larq.context.quantized_scope(True):
    # model.save_weights('bnn_mnist_model_binary.h5')  # save binary weights

    model_dict.append(dict(
        type='dense',
        weights=model.dense_1.get_weights()[0].tolist()
    ))

    batch_normalisation_weights_array = model.batch_normalization_1.get_weights()
    batch_normalization_weights = []
    for i in range(4):
        batch_normalization_weights.append(batch_normalisation_weights_array[i].tolist())
    model_dict.append(dict(
        type='batch_normalization',
        weights=batch_normalization_weights
    ))

    model_dict.append(dict(
        type='dense',
        weights=model.dense_2.get_weights()[0].tolist()
    ))

    batch_normalisation_weights_array = model.batch_normalization_2.get_weights()
    batch_normalization_weights = []
    for i in range(4):
        batch_normalization_weights.append(batch_normalisation_weights_array[i].tolist())
    model_dict.append(dict(
        type='batch_normalization',
        weights=batch_normalization_weights
    ))

    model_dict.append(dict(
        type='dense',
        weights=model.dense_last.get_weights()[0].tolist()
    ))


json_model = json.dumps(model_dict)
with open('models\\bnn_mnist_model.json', 'w') as f:
    f.write(json_model)
