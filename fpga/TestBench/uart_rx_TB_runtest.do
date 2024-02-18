SetActiveLib -work
comp -include "$dsn\src\uart_rx.vhd" 
comp -include "$dsn\src\TestBench\uart_rx_TB.vhd" 
asim +access +r TESTBENCH_FOR_uart_rx 
wave 
wave -noreg UART_RX1
wave -noreg CLK
wave -noreg RESET
wave -noreg UART_DATA
wave -noreg DATA_VALID

run 1000 us
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\uart_rx_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_uart_rx 
