SetActiveLib -work
comp -include "$dsn\src\uart_tx.vhd" 
comp -include "$dsn\src\TestBench\uart_tx_TB.vhd" 
asim +access +r TESTBENCH_FOR_uart_tx 
wave 
wave -noreg DATA_ACTIVE
wave -noreg CLK
wave -noreg UART_TX1
wave -noreg RESET
wave -noreg UART_DATA
wave -noreg DATA_VALID

run 1500.00 us
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\uart_tx_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_uart_tx 
