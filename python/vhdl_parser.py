import json

import numpy as np

with open('models\\bnn_mnist_model.json', 'r') as f:
    json_model = json.loads(f.read())

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


weights_str = '\n'
for w_vector in all_weights:
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

