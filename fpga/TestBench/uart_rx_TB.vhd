library ieee;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity uart_rx_tb is
end uart_rx_tb;

architecture TB_ARCHITECTURE of uart_rx_tb is
	-- Component declaration of the tested unit
	component uart_rx
	port(
		UART_RX : in STD_LOGIC;
		CLK : in STD_LOGIC;
		RESET : in STD_LOGIC;
		UART_DATA : out STD_LOGIC_VECTOR(0 to 7); 
		DATA_VALID : out STD_LOGIC
	);
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal UART_RX1 : STD_LOGIC;
	signal CLK : STD_LOGIC;
	signal RESET : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal UART_DATA : STD_LOGIC_VECTOR(0 to 7);
	signal DATA_VALID: STD_LOGIC;

	-- Add your code here ...
	signal END_SIM : BOOLEAN := FALSE;

begin

	-- Unit Under Test port map
	UUT : uart_rx
		port map (
			UART_RX => UART_RX1,
			CLK => CLK,
			RESET => RESET,
			UART_DATA => UART_DATA,
			DATA_VALID => DATA_VALID
		);

	-- Add your stimulus here ...


STIMULUS: process
begin  -- of stimulus process
--wait for <time to next event>; -- <current time>

	RESET <= '1';
    wait for 50 ns;
	RESET <= '0'; 
    wait for 1000 us;
	END_SIM <= TRUE;
--	end of stimulus events
	wait;
end process; -- end of stimulus process

UART_RX_STIMULUS: process
begin  -- of UART_RX_STIMULUS process
--wait for <time to next event>; -- <current time>
	
	UART_RX1 <= '0'; -- start bit
    wait for  52 us;
	UART_RX1 <= '1';
	wait for 52 us; 
	UART_RX1 <= '0';
    wait for  52 us;
	UART_RX1 <= '1';
	wait for 52 us;
	UART_RX1 <= '0';
    wait for  52 us;
	UART_RX1 <= '1';
	wait for 52 us;
	UART_RX1 <= '0';
    wait for  52 us;
	UART_RX1 <= '1';
	wait for 52 us;
	UART_RX1 <= '0';
    wait for  52 us;
	UART_RX1 <= '1'; -- stop bit
	wait for 52 us;
	
--	end of UART_RX_STIMULUS events
	wait;
end process; -- end of UART_RX_STIMULUS process

CLOCK_CLK : process
begin
	--wait for <time to next event>; -- <current time>
	if END_SIM = FALSE then
		CLK <= '0';
		wait for 5 ns;
	else
		wait;
	end if;
	if END_SIM = FALSE then
		CLK <= '1';
		wait for 5 ns;
	else
		wait;
	end if;
end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_uart_rx of uart_rx_tb is
	for TB_ARCHITECTURE
		for UUT : uart_rx
			use entity work.uart_rx(uart_rx);
		end for;
	end for;
end TESTBENCH_FOR_uart_rx;

