import json
import numpy as np


def transpose_weights(json_model):
    """ Transposes layers weights extract from json BNN model.

        Args:
            json_model: json BNN model

        Returns:
            transposed weights list
    """
    all_weights = []
    for obj in json_model:
        if obj.get('type') != 'dense':
            continue

        w_vector = obj.get('weights')
        weights = [list() for _ in range(len(w_vector[0]))]
        for row in w_vector:
            n = len(row)
            for i in range(n):
                weights[i].append(row[i])
        all_weights.append(weights)
    return all_weights


def parse_weights_to_vhdl(weights: list):
    """ Parses given weights list to VHDL code, equivalent to assigning value to signal W.

        Args:
            weights: list of layers weights

        Returns:
            parsed VHDL code string
    """
    weights_str = '\n'
    for w_vector in weights:
        i = 0
        weights_str += '\n'
        for row in w_vector:
            if type(row) != list:
                continue

            weights_str += f'W({i})<="'
            for value in reversed(row):
                if value == 1:
                    weights_str += '1'
                else:
                    weights_str += '0'
            i += 1
            weights_str += '";\n'
    print(weights_str)
    return weights_str


def parse_normalization_params_to_vhdl(json_model):
    """ Parses normalization params extracted from json BNN model to VHDL code,
        equivalent to initialising signals GAMMA, BETA, MEAN, STD_DEV with type NORMALIZATION_ARRAY.

        Args:
            json_model: json BNN model

        Returns:
            parsed VHDL code string
    """
    normalization_params_str = '\n'
    for obj in json_model:
        if obj.get('type') != 'batch_normalization':
            continue

        normalization_params_str += '\n'
        values_array = obj.get('weights')
        for i in range(len(values_array)):
            values = np.array(values_array[i])
            if i == 0 or i == 1:
                values = values * 1000
            values = values.astype('int32')

            if i == 0:
                normalization_params_str += 'signal GAMMA : NORMALIZATION_ARRAY :='
            if i == 1:
                normalization_params_str += 'signal BETA : NORMALIZATION_ARRAY :='
            if i == 2:
                normalization_params_str += 'signal MEAN : NORMALIZATION_ARRAY :='
            if i == 3:
                values[values == 0] = 1
                normalization_params_str += 'signal STD_DEV : NORMALIZATION_ARRAY :='

            values_str = str(values.tolist()).lstrip('[').rstrip(']')
            values_str = ' (' + values_str + ')'
            normalization_params_str += values_str + ';\n'

        print(normalization_params_str)
        return normalization_params_str


if __name__ == '__main__':
    with open('models\\bnn_mnist_model.json', 'r') as f:
        json_model = json.loads(f.read())

    layers_weights = transpose_weights(json_model=json_model)
    parse_weights_to_vhdl(weights=layers_weights)

    parse_normalization_params_to_vhdl(json_model=json_model)
