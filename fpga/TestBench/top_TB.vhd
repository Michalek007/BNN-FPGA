library ieee;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity top_tb is
end top_tb;

architecture TB_ARCHITECTURE of top_tb is
	-- Component declaration of the tested unit
	component top
	port(
		INPUT_UART_RX : in STD_LOGIC;
		CLK : in STD_LOGIC;
		RESET : in STD_LOGIC;
		OUTPUT : out STD_LOGIC_VECTOR(0 to 7);
		OUTPUT_UART_TX : out STD_LOGIC
	);
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal INPUT_UART_RX : STD_LOGIC;
	signal CLK : STD_LOGIC;
	signal RESET : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal OUTPUT : STD_LOGIC_VECTOR(0 to 7);
	signal OUTPUT_UART_TX : STD_LOGIC;

	-- Add your code here ...
	signal END_SIM : BOOLEAN := FALSE;

begin

	-- Unit Under Test port map
	UUT : top
		port map (
			INPUT_UART_RX => INPUT_UART_RX,
			CLK => CLK,
			RESET => RESET,
			OUTPUT => OUTPUT,
			OUTPUT_UART_TX => OUTPUT_UART_TX
		);

	-- Add your stimulus here ...


STIMULUS: process
begin  -- of stimulus process
--wait for <time to next event>; -- <current time>

	RESET <= '1';
    wait for 50 ns; -- 50 ns
	RESET <= '0'; 
    wait for 3000 us; -- 3050 ns
	END_SIM <= TRUE;
--	end of stimulus events
	wait;
end process; -- end of stimulus process

UART_RX_STIMULUS: process
begin  -- of UART_RX_STIMULUS process
--wait for <time to next event>; -- <current time>
	
	INPUT_UART_RX <= '0'; -- start bit
    wait for  52 us;
	INPUT_UART_RX <= '1';
	wait for 52 us; 
	INPUT_UART_RX <= '0';
    wait for  52 us;
	INPUT_UART_RX <= '1';
	wait for 52 us;
	INPUT_UART_RX <= '0';
    wait for  52 us;
	INPUT_UART_RX <= '1';
	wait for 52 us;
	INPUT_UART_RX <= '0';
    wait for  52 us;
	INPUT_UART_RX <= '1';
	wait for 52 us;
	INPUT_UART_RX <= '0';
    wait for  52 us;
	INPUT_UART_RX <= '1'; -- stop bit
	wait for 52 us;
	
	INPUT_UART_RX <= '0'; -- start bit
    wait for  52 us;
	INPUT_UART_RX <= '1';
	wait for 52 us; 
	INPUT_UART_RX <= '0';
    wait for  52 us;
	INPUT_UART_RX <= '1';
	wait for 52 us;
	INPUT_UART_RX <= '0';
    wait for  52 us;
	INPUT_UART_RX <= '1';
	wait for 52 us;
	INPUT_UART_RX <= '0';
    wait for  52 us;
	INPUT_UART_RX <= '1';
	wait for 52 us;
	INPUT_UART_RX <= '0';
    wait for  52 us;
	INPUT_UART_RX <= '1'; -- stop bit
	wait for 52 us;
	
	INPUT_UART_RX <= '0'; -- start bit
    wait for  52 us;
	INPUT_UART_RX <= '1';
	wait for 52 us; 
	INPUT_UART_RX <= '0';
    wait for  52 us;
	INPUT_UART_RX <= '1';
	wait for 52 us;
	INPUT_UART_RX <= '0';
    wait for  52 us;
	INPUT_UART_RX <= '1';
	wait for 52 us;
	INPUT_UART_RX <= '0';
    wait for  52 us;
	INPUT_UART_RX <= '1';
	wait for 52 us;
	INPUT_UART_RX <= '0';
    wait for  52 us;
	INPUT_UART_RX <= '1'; -- stop bit
	
--	end of UART_RX_STIMULUS events
	wait;
end process; -- end of UART_RX_STIMULUS process

CLOCK_CLK : process
begin
	--this process was generated based on formula: 0 0 ns, 1 50 ns -r 100 ns
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

configuration TESTBENCH_FOR_top of top_tb is
	for TB_ARCHITECTURE
		for UUT : top
			use entity work.top(top);
		end for;
	end for;
end TESTBENCH_FOR_top;

