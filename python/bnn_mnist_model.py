import numpy as np
import tensorflow as tf
import larq
import json

from utils import get_mnist_data


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


(x_train, y_train), (x_test, y_test) = get_mnist_data(n_training_samples=30_000, n_test_samples=10_000)
print('Dataset loaded!')

model = BnnMnistModel()

model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=1e-3),
              loss=tf.keras.losses.CategoricalCrossentropy(),
              metrics=[tf.keras.metrics.CategoricalAccuracy()])
print('Model compiled!')

file_name = 'bnn_mnist_model_test'
from_file = True  # choose if load model weights from file or fit model otherwise


if from_file:
    # loading model from .h5 file
    print(model.predict(x_test[0]))
    print(y_test[0])
    model.load_weights(f'models\\{file_name}.h5')
else:
    # model fitting
    model.fit(x_train, y_train, epochs=35, verbose='2')
    print('Model trained!')


# model validation
metrics = model.evaluate(x_test, y_test)
print(metrics)


# sample prediction for visualisation
print(model.predict(x_test[0]))
print(y_test[0])


if not from_file:
    model.save_weights(f'models\\{file_name}.h5')  # save full precision latent weights

    # preparing data for json file
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

    # saving model data in json file
    json_model = json.dumps(model_dict)
    with open(f'models\\{file_name}.json', 'w') as f:
        f.write(json_model)
