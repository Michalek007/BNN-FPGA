SetActiveLib -work
comp -include "$dsn\src\top.vhd" 
comp -include "$dsn\src\TestBench\top_TB_mnist.vhd" 
asim +access +r TESTBENCH_FOR_top 
wave 
wave -noreg INPUT_UART_RX
wave -noreg CLK
wave -noreg RESET
wave -noreg OUTPUT
wave -noreg OUTPUT_UART_TX
wave -noreg {/top_tb/UUT/COUNTER}
wave -noreg {/top_tb/UUT/INPUT_BUFFER}
wave -noreg {/top_tb/UUT/BUFFER_FULL}
wave -noreg {/top_tb/UUT/LAYER_INPUT}

wave -noreg {/top_tb/UUT/U3/INTEGER_INPUT}
wave -noreg {/top_tb/UUT/U3/INTEGER_W_DOT_INPUT}
wave -noreg {/top_tb/UUT/U3/W_DOT_INPUT}
wave -noreg {/top_tb/UUT/U3/RELU}
wave -noreg {/top_tb/UUT/U3/NORMALIZED_BATCH}

wave -noreg {/top_tb/UUT/U4/W_XOR_INPUT}
wave -noreg {/top_tb/UUT/U4/POP_COUNTER}
wave -noreg {/top_tb/UUT/U4/NORMALIZED_BATCH}

wave -noreg {/top_tb/UUT/U5/W_XOR_INPUT}
wave -noreg {/top_tb/UUT/U5/POP_COUNTER}
wave -noreg {/top_tb/UUT/U5/SOFTMAX_EXP}
wave -noreg {/top_tb/UUT/U5/SOFTMAX_SUM}
wave -noreg {/top_tb/UUT/U5/SOFTMAX}

run 3000 us
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\uart_rx_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_uart_rx 
