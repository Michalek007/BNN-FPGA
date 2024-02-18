-------------------------------------------------------------------------------
--
-- Title       : uart_rx
-- Design      : uart
-- Author      : Micha³ Nizio³
-- Company     : AGH
--
-------------------------------------------------------------------------------
--
-- File        : C:\My_Designs\MN\neural_network\uart\src\uart_rx.vhd
-- Generated   : Wed Jan 17 13:24:20 2024
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.22
--
-------------------------------------------------------------------------------
--
-- Description : UART receiver 
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {uart_rx} architecture {uart_rx}}

library IEEE;
use IEEE.std_logic_1164.all;

entity uart_rx is
	 port(
		 UART_RX : in STD_LOGIC;
		 CLK : in STD_LOGIC;
		 RESET : in STD_LOGIC;
		 UART_DATA : out STD_LOGIC_VECTOR(0 to 7);
		 DATA_VALID: out STD_LOGIC
	     );
end uart_rx;

--}} End of automatically maintained section

architecture uart_rx of uart_rx is

constant CLOCK: INTEGER := 100_000; -- mnist simulation: 100_000; implementation: --100_000_000;

type receive_type is ( IDLE, START, WAIT_OAH, GET_BIT, WAIT_ONE, STOP);
signal receive_mode: receive_type;

signal BIT_COUNT: INTEGER;
signal CLK_COUNT: INTEGER;
signal CLK_PER_OAH_X: INTEGER;
signal CLK_PER_OAH_BIT: INTEGER;
signal CLK_PER_BIT_X: INTEGER;
signal CLK_PER_BIT: INTEGER;
signal SHIFT_REG: STD_LOGIC_VECTOR (7 downto 0);
signal START_CNT: INTEGER;



begin

	CLK_PER_BIT_X <= CLOCK / 19200;
	CLK_PER_BIT <= CLK_PER_BIT_X - 2; -- clock cycles per one bit
	
	CLK_PER_OAH_X <= CLOCK / 19200 + CLOCK/(19200*2);
	CLK_PER_OAH_BIT <= CLK_PER_OAH_X - 5; -- clock cycles per one and half bit
	
	process_uart_rx: process (CLK)
	begin
		if RESET = '1' then
		receive_mode <= IDLE;
		-- Set reset or default values for outputs, signals and variables
		UART_DATA <= (others => '0');
		BIT_COUNT <= 0;
		CLK_COUNT <= 0;
		START_CNT <= 0;
		DATA_VALID <= '0';
		elsif CLK'event and CLK = '1' then
			-- Set default values for outputs, signals and variables
			case receive_mode is
				when IDLE =>
					BIT_COUNT <= 0;
					CLK_COUNT <= 0;
					START_CNT <= 0;
					DATA_VALID <= '0';
					if UART_RX = '1' then
						receive_mode <= IDLE;
					elsif UART_RX = '0' then
						receive_mode <= START;
					end if;
				
				when START =>
					START_CNT<=START_CNT+1;
					if UART_RX= '0' and START_CNT < 3 then
						receive_mode <= START;
					elsif UART_RX = '0' and START_CNT = 3 then
						receive_mode <= WAIT_OAH;
					elsif UART_RX = '1' then
						receive_mode <= IDLE;
					end if;
				
				when WAIT_OAH =>
					CLK_COUNT <= CLK_COUNT + 1;
					if CLK_COUNT < CLK_PER_OAH_BIT then
						receive_mode <= WAIT_OAH;
					elsif CLK_COUNT = CLK_PER_OAH_BIT then
						receive_mode <= GET_BIT;
					end if;
				
				when GET_BIT =>
					CLK_COUNT <= 0;
					if BIT_COUNT < 8 then
						SHIFT_REG(BIT_COUNT) <= UART_RX;
					end if;
					BIT_COUNT <= BIT_COUNT + 1;
					receive_mode <= WAIT_ONE;
				
				when WAIT_ONE =>
					CLK_COUNT <= CLK_COUNT + 1;
					if BIT_COUNT < 9 and CLK_COUNT = CLK_PER_BIT then
						receive_mode <= GET_BIT;
					elsif BIT_COUNT = 9 then
						receive_mode <= STOP;
					elsif BIT_COUNT < 9 and CLK_COUNT < CLK_PER_BIT then
						receive_mode <= WAIT_ONE;
					end if;
				
				when STOP =>
					UART_DATA <= SHIFT_REG;
					DATA_VALID <= '1';
					receive_mode <= IDLE;
				
				when others =>
					null;
			end case;
		end if;
		
	end process;

end uart_rx;
