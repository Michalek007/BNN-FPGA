# BNN-FPGA

Implementation of Binary Neural Network in VHDL for FPGA.
Model was trained with MNIST dataset in Python with larq and tensorflow libraries, then deployed on FPGA (Nexys 4 DDR board with Xilinx Artix-7 XC7A100T-CSG324).

## fpga

Contains BNN implementation and UART communication in VHDL. In TestBench directory are simulation files.
Structure:
* **uart_rx** - UART receiver
* **uart_rx** - UART transimtter
* **layer_constants** - contains constants variables defining number of neurons in layers, types and clock freq
* **top** - BNN implementation with UART communication
* **layer** - input layer with batch normalization and reLu activation
* **layer_hidden** - hidden layer with batch normalization and reLu activation
* **layer_output** - output layer with softmax activation
* **pop_cnt** - population counter

## python

Contains BNN model implemented and trained with larq and tensorflow libraries.
Structure:
* **bnn_mnist_model** - BNN MNIST model implementation, fitting and validation
* **vhdl_parser** - extracts model's weights and parses to VHDL code
* **uart** - sending sample model input data to FPGA via UART
* **bnn_mnist_model_fpga** - Python simulation of BNN model implementation on FPGA
* **mnist_data_loader** - loads MNIST dataset
* **utils** - utility functions for preparing MNIST data

 Best model performed with 86.68% (tested on test dataset with 10_000 samples).
