-------------------------------------------------------------------------------
--
-- Title       : uart_tx
-- Design      : uart
-- Author      : Micha³ Nizio³
-- Company     : AGH
--
-------------------------------------------------------------------------------
--
-- Description : UART transmitter 
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {uart_tx} architecture {uart_tx}}

library IEEE;
use IEEE.std_logic_1164.all;
use work.layer_constants.all;

entity uart_tx is
	 port(
		 DATA_ACTIVE : in STD_LOGIC;
		 CLK : in STD_LOGIC;
		 UART_TX : out STD_LOGIC;
		 RESET : in STD_LOGIC;
		 UART_DATA : in STD_LOGIC_VECTOR(0 to 7);
		 DATA_VALID : out STD_LOGIC
	     );
end uart_tx;

--}} End of automatically maintained section

architecture uart_tx of uart_tx is

	constant CLOCK: INTEGER := SYS_CLOCK_FREQ;
	
	type transmit_type is (IDLE, START_BIT, SEND, WAIT_ONE_CLK);
	signal transmit_mode : transmit_type := IDLE;
	
	signal BIT_COUNT: INTEGER;
	signal CLK_COUNT: INTEGER;
	signal CLK_PER_BIT_X: INTEGER;
	signal CLK_PER_BIT: INTEGER;
	signal SHIFT_REG: STD_LOGIC_VECTOR (7 downto 0);

begin
	CLK_PER_BIT_X <= CLOCK / 19200;
	CLK_PER_BIT <= CLK_PER_BIT_X - 2; -- clock cycles per one bit

	 process_uart_tx: process (CLK)
	  begin
		if RESET = '1' then
			-- when reset sets tx_type as IDLE default values for variables and set output as high
			transmit_mode <= IDLE;
			BIT_COUNT <= 0;
			CLK_COUNT <= 0;
			UART_TX <= '1';
			DATA_VALID <= '0';
		
		elsif CLK'event and CLK = '1' then
		 case transmit_mode is
			 
			when IDLE => -- when IDLE set output as high, when DATA_ACTIVE start transmission (START_BIT) 
				UART_TX <= '1';
				BIT_COUNT <= 0;
				CLK_COUNT <= 0;
				DATA_VALID <= '0';

				if DATA_ACTIVE = '1' and BIT_COUNT < 9 then
					transmit_mode<= START_BIT;
				else
					transmit_mode <= IDLE;
				end if;
			
			when START_BIT =>
				UART_TX <= '0'; -- start bit 0
				SHIFT_REG <= UART_DATA;
				
				transmit_mode <= WAIT_ONE_CLK;
			 
			 
			when WAIT_ONE_CLK => -- increment CLK_COUNT, WAIT_ONE_CLK until CLK_COUNT equals CLK_PER_BIT then SEND
				CLK_COUNT <= CLK_COUNT + 1;
				if CLK_COUNT = CLK_PER_BIT then
					transmit_mode <= SEND;
				elsif CLK_COUNT < CLK_PER_BIT then
					transmit_mode <= WAIT_ONE_CLK;
				end if;
			 	
			 
			when SEND => 
				CLK_COUNT <= 0;
				if BIT_COUNT < 8 then
					UART_TX <= SHIFT_REG(BIT_COUNT);
				else
					UART_TX <= '1'; -- stop bit
					DATA_VALID <= '1';
				end if;

				BIT_COUNT <= BIT_COUNT + 1;
				if BIT_COUNT = 9 then
					transmit_mode <= IDLE;
				elsif BIT_COUNT < 9 then
					transmit_mode <= WAIT_ONE_CLK;
				end if;
			
			when others =>
				null; 
		 	
			end case;	 
		 end if;
	 end process process_uart_tx;
	 
end uart_tx;
