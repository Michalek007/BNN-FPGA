-------------------------------------------------------------------------------
--
-- Title       : top
-- Design      : uart
-- Author      : Michal
-- Company     : AGH
--
-------------------------------------------------------------------------------
--
-- File        : C:\Users\Public\Projects\MyDesigns\uart\src\top.vhd
-- Generated   : Wed Feb  7 00:44:37 2024
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.22
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {top} architecture {top}}

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;
use work.layer_constants.all;


entity top is
	 port(
		 INPUT_UART_RX : in STD_LOGIC;
		 CLK : in STD_LOGIC;
		 RESET : in STD_LOGIC;
		 OUTPUT : out STD_LOGIC_VECTOR(0 to 7);
		 OUTPUT_UART_TX : out STD_LOGIC
	     );
end top;

--}} End of automatically maintained section

architecture top of top is

component uart_rx
	port(
		UART_RX : in STD_LOGIC;
		CLK : in STD_LOGIC;
		RESET : in STD_LOGIC;
		UART_DATA : out STD_LOGIC_VECTOR(0 to 7); 
		DATA_VALID : out STD_LOGIC
	);
end component;

component uart_tx
	port(
		UART_TX : out STD_LOGIC;
		CLK : in STD_LOGIC;
		RESET : in STD_LOGIC;
		UART_DATA : in STD_LOGIC_VECTOR(0 to 7); 
		DATA_ACTIVE : in STD_LOGIC;
		DATA_VALID : out STD_LOGIC
	);
end component;

component layer
	port(
		INPUT: INPUT_ARRAY;
		OUTPUT: out STD_LOGIC_VECTOR(0 to LAYER_HIDDEN_N_INPUTS) 
	);
end component;

component layer_hidden
	port(
		INPUT: in STD_LOGIC_VECTOR(0 to LAYER_HIDDEN_N_INPUTS);
		OUTPUT: out STD_LOGIC_VECTOR(0 to LAYER_HIDDEN_N_OUTPUTS) 
	);
end component;

component layer_output
	port(
		INPUT: in STD_LOGIC_VECTOR(0 to LAYER_HIDDEN_N_OUTPUTS);
		OUTPUT: out STD_LOGIC_VECTOR(0 to 7) 
	);
end component;

-- uart rx
signal UART_DATA : STD_LOGIC_VECTOR(0 to 7);
signal DATA_VALID : STD_LOGIC;

-- uart tx
signal OUTPUT_UART_DATA : STD_LOGIC_VECTOR(0 to 7);
signal DATA_ACTIVE : STD_LOGIC;
signal DATA_VALID_TX : STD_LOGIC;

-- collecting data
signal COUNTER : UNSIGNED(0 to 1) := (others => '0');
signal BUFFER_FULL: STD_LOGIC := '0';
signal INPUT_BUFFER: INPUT_ARRAY := (others => (others => '0')); 

-- layers
signal LAYER_INPUT: INPUT_ARRAY := (others => (others => '0')); 
signal LAYER_H_INPUT: STD_LOGIC_VECTOR(0 to LAYER_HIDDEN_N_INPUTS) := (others => '0'); 
signal LAYER_H_OUTPUT: STD_LOGIC_VECTOR(0 to LAYER_HIDDEN_N_OUTPUTS) := (others => '0'); 
signal LAYER_O_OUTPUT: STD_LOGIC_VECTOR(0 to 7) := (others => '0'); 

begin

U1 : uart_rx
  port map(
       UART_RX => INPUT_UART_RX,
	   CLK => CLK,
       RESET => RESET,
	   UART_DATA => UART_DATA,
	   DATA_VALID => DATA_VALID
	   
  );
  
U2 : uart_tx
  port map(
       UART_TX => OUTPUT_UART_TX,
	   CLK => CLK,
       RESET => RESET,
	   UART_DATA => OUTPUT_UART_DATA,
	   DATA_ACTIVE => DATA_ACTIVE,
	   DATA_VALID => DATA_VALID_TX
	   
  );

U3 : layer
port map(
   INPUT => LAYER_INPUT,
   OUTPUT => LAYER_H_INPUT
);

U4 : layer_hidden
port map(
   INPUT => LAYER_H_INPUT,
   OUTPUT => LAYER_H_OUTPUT
);

U5 : layer_output
port map(
   INPUT => LAYER_H_OUTPUT,
   OUTPUT => LAYER_O_OUTPUT
);
 
  process (RESET, DATA_VALID, COUNTER, DATA_VALID_TX)
  begin
	  if RESET = '1' then
		 COUNTER <= (others => '0');

		 input_buffer_loop : for k in 0 to LAYER_INPUT_N_INPUTS loop
			INPUT_BUFFER(k) <= (others => '0'); 
		 end loop input_buffer_loop;

		 BUFFER_FULL <= '0';
	  
	  elsif DATA_VALID'event and DATA_VALID = '1' then
		 INPUT_BUFFER(to_integer(COUNTER)) <= UART_DATA;
	     COUNTER <= COUNTER + 1;
	  
	  end if;

	  if COUNTER = LAYER_INPUT_N_INPUTS + 1 then
		 BUFFER_FULL <= '1';

		 --OUTPUT_UART_DATA <= INPUT_BUFFER(1);
		 DATA_ACTIVE <= '1';
		 
		 COUNTER <= (others => '0');
		 layer_input_loop : for k in 0 to LAYER_INPUT_N_INPUTS loop
			 LAYER_INPUT(k) <= INPUT_BUFFER(k);
		 end loop layer_input_loop;			 
				 
	  end if;
	  
	  if DATA_VALID_TX = '1' then -- if data sent disable sending
		 DATA_ACTIVE <= '0';
	  end if;
	  
  end process;
  
  OUTPUT_UART_DATA <= INPUT_BUFFER(1); -- INPUT_BUFFER(1)
  OUTPUT <= LAYER_O_OUTPUT; 
  
end top;
