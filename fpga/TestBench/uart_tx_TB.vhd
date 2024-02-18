library ieee;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity uart_tx_tb is
end uart_tx_tb;

architecture TB_ARCHITECTURE of uart_tx_tb is
	-- Component declaration of the tested unit
	component uart_tx
	port(
		DATA_ACTIVE : in STD_LOGIC;
		CLK : in STD_LOGIC;
		UART_TX : out STD_LOGIC;
		RESET : in STD_LOGIC;
		UART_DATA : in STD_LOGIC_VECTOR(0 to 7);
		DATA_VALID : out STD_LOGIC
	);
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal DATA_ACTIVE : STD_LOGIC;
	signal CLK : STD_LOGIC;
	signal RESET : STD_LOGIC;
	signal UART_DATA : STD_LOGIC_VECTOR(0 to 7);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal UART_TX1 : STD_LOGIC;
	signal DATA_VALID : STD_LOGIC;

	-- Add your code here ...
	signal END_SIM: BOOLEAN:=FALSE;

begin

	-- Unit Under Test port map
	UUT : uart_tx
		port map (
			DATA_ACTIVE => DATA_ACTIVE,
			CLK => CLK,
			UART_TX => UART_TX1,
			RESET => RESET,
			UART_DATA => UART_DATA,
			DATA_VALID => DATA_VALID
		);

	-- Add your stimulus here ...
	
STIMULUS: process
begin  -- of stimulus process
--wait for <time to next event>; -- <current time>

	RESET <= '0';
    wait for 10 ns; --75 ns
	RESET <= '1';
    wait for 10 ns; --150 ns
	RESET <= '0';
	wait for 1500 us;
	END_SIM <= TRUE;
--	end of stimulus events
	wait;
end process; -- end of stimulus process

DATA_ACTIVE_STIMULUS: process
begin  -- of DATA_ACTIVE process
--wait for <time to next event>; -- <current time>

	DATA_ACTIVE <= '0';
    wait for 10 ns; --100 ns
	DATA_ACTIVE <= '1';
--	end of load_stimulus events
	wait;
end process; -- end of DATA_ACTIVE process

UART_DATA_STIMULUS: process
begin  -- of UART_DATA process
--wait for <time to next event>; -- <current time>

	UART_DATA <= "01010101";
	wait for 750 us;
	UART_DATA <= "01010101";
--	end of UART_DATA events
	wait;
end process; -- end of UART_DATA process

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

configuration TESTBENCH_FOR_uart_tx of uart_tx_tb is
	for TB_ARCHITECTURE
		for UUT : uart_tx
			use entity work.uart_tx(uart_tx);
		end for;
	end for;
end TESTBENCH_FOR_uart_tx;

