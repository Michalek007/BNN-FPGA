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

    def save_to_json(self, file_name: str):
        model_dict = []
        with larq.context.quantized_scope(True):

            layers = (
                self.dense_1, self.batch_normalization_1,
                self.dense_2, self.batch_normalization_2,
                self.dense_last
            )

            for layer in layers:
                if isinstance(layer, larq.layers.QuantDense):
                    model_dict.append(dict(
                        type='dense',
                        weights=layer.get_weights()[0].tolist()
                    ))
                elif isinstance(layer, tf.keras.layers.BatchNormalization):
                    model_dict.append(dict(
                        type='batch_normalization',
                        weights=list(map(lambda np_array: np_array.tolist(), layer.get_weights()))
                    ))

        json_model = json.dumps(model_dict)
        with open(file_name, 'w') as f:
            f.write(json_model)


def deploy_mnist_model(n_training_samples: int, n_test_samples: int, file_name: str, from_file: bool = False):
    """
    Deploys BNN mnist model. Model fitting and validation is performed.
    Trained model is saved in .h5 & .json files if from_file is False,
    otherwise only validation is performed on loaded model.

    Args:
        n_training_samples: number of samples from training dataset
        n_test_samples: number of samples from test dataset
        file_name: name of the file in which mode will ba saved or form which will be loaded
        from_file: if True loads model's weights from file or fits model otherwise

    Returns:
        compiled BnnMnistModel(tf.keras.Model) model
    """
    (x_train, y_train), (x_test, y_test) = get_mnist_data(
        n_training_samples=n_training_samples,
        n_test_samples=n_test_samples
    )
    print('Dataset loaded!')

    model = BnnMnistModel()

    model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=1e-3),
                  loss=tf.keras.losses.CategoricalCrossentropy(),
                  metrics=[tf.keras.metrics.CategoricalAccuracy()])
    print('Model compiled!')

    if from_file:
        # loading model from .h5 file
        model.predict(x_test[0])
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

        # with larq.context.quantized_scope(True):
        #     model.save_weights('bnn_mnist_model_binary.h5')  # save binary weights

        model.save_to_json(file_name=f'models\\{file_name}.json')

    return model


if __name__ == '__main__':
    mnist_model = deploy_mnist_model(
        n_training_samples=30_000,
        n_test_samples=10_000,
        file_name='bnn_mnist_model',
        # file_name='bnn_mnist_model_test',
        from_file=True
    )
