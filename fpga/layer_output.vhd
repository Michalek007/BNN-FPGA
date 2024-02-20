-------------------------------------------------------------------------------
--
-- Title       : layer_output
-- Design      : neural_network
-- Author      : Micha³ Nizio³
-- Company     : AGH
--
-------------------------------------------------------------------------------
--
-- Description : Output layer of BNN  
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {layer_output} architecture {layer_output}}

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;
use work.layer_constants.all;


entity layer_output is
	generic (
		 N_INPUTS : integer := LAYER_HIDDEN_N_OUTPUTS;
		 N_OUTPUTS : integer := LAYER_OUTPUT_N_OUTPUTS;
		 POP_CNT_MAX : integer := LAYER_OUTPUT_POP_CNT_MAX 
		);
	 port(
		 INPUT : in STD_LOGIC_VECTOR(0 to N_INPUTS);
		 OUTPUT : out STD_LOGIC_VECTOR(0 to 7)
	     );
end layer_output;

--}} End of automatically maintained section

architecture layer_output of layer_output is


component pop_cnt
	generic (
		N_INPUTS : integer := N_INPUTS;
		N_OUTPUTS : integer := POP_CNT_MAX
	); 
	port(
		INPUT: in STD_LOGIC_VECTOR(0 to N_INPUTS);
		OUTPUT: out STD_LOGIC_VECTOR(0 to N_OUTPUTS)
	);
end component;

function f_factorial (x : integer) return integer is

   variable n : integer;
   variable output : integer;
   begin
      n := 1;
	  output := 1;
      while (n < x + 1) loop
		 output := output * n;
         n := n + 1;
      end loop;
      return output;
end function;

function f_exp (x : integer) return integer is

   variable n : integer;
   variable ex : integer;
   begin
      n := 0;
	  ex := 0;
      while (n < 10) loop
		 ex := ex + (x ** n / f_factorial(n) );
         n := n + 1;
      end loop;
      return ex;
end function;

type SOFTMAX_ARRAY is array (0 to N_OUTPUTS) of INTEGER;

function f_sum (x : SOFTMAX_ARRAY) return integer is

   variable n : integer;
   variable sum : integer;
   begin
      n := 0;
	  sum := 0;
      while (n < N_OUTPUTS+1) loop
		 sum := sum + x(n);
         n := n + 1;
      end loop;
      return sum;
end function;

function f_argmax (x : SOFTMAX_ARRAY) return integer is

   variable n : integer;
   variable max_value : integer;
   variable max_value_index : integer;
   begin
      n := 0;
	  max_value := 0;
	  max_value_index := 0;
      while (n < N_OUTPUTS+1) loop
		  if (max_value > x(n)) then
			max_value := x(n);
		    max_value_index := n; 
		  end if;
         n := n + 1;
      end loop;
      return max_value_index;
end function;

type WEIGHTS_ARRAY is array (0 to N_OUTPUTS) of STD_LOGIC_VECTOR(0 to N_INPUTS);
type POP_CNT_ARRAY is array (0 to N_OUTPUTS) of STD_LOGIC_VECTOR(0 to POP_CNT_MAX);

signal W: WEIGHTS_ARRAY;
signal W_XOR_INPUT : WEIGHTS_ARRAY := (others => (others => '0')); 
signal POP_COUNTER : POP_CNT_ARRAY := (others => (others => '0')); 
signal SOFTMAX_EXP : SOFTMAX_ARRAY;
signal SOFTMAX_SUM : INTEGER := 1; 
signal SOFTMAX: SOFTMAX_ARRAY; 

begin

--	--	simulation
--	W(0) <= "11111111";
--	W(1) <= "11111111";
--	W(2) <= "11111111";
--	W(3) <= "11111111";
--	W(4) <= "11111111";
--	W(5) <= "11111111";
--	W(6) <= "11111111"; 
--	W(7) <= "11111111";

--	--	mnist simulation & implementation
W(0)<="00101111100110111011010011001000000110100011001111";
W(1)<="10100101100110000011000000000010101010011011011111";
W(2)<="00100100101110111011000000001000000010010111011111";
W(3)<="10100101101110100011011000001000000110010111011011";
W(4)<="10100111101110111010001000001000100010111111011111";
W(5)<="00110111101110100011010000001000001010110111001011";
W(6)<="00101101101110110011001000001000100000110011001111";
W(7)<="10101101101110101011010010001000101100011111001111";
W(8)<="10001111101110010011001000001000001110010011011111";
W(9)<="00101110101110101011011001001000101100111111011111";

	W_XOR_INPUT_i:
	for i in 0 to N_OUTPUTS generate  
	begin
		W_XOR_INPUT(i) <= not (W(i) xor INPUT);
	end generate;

	POP_CNT_i:
	for i in 0 to N_OUTPUTS generate
	begin
		pc: pop_cnt port map (INPUT=>W_XOR_INPUT(i), OUTPUT=>POP_COUNTER(i));
	end generate;	
		
	SOFTMAX_EXP_i:
	for i in 0 to N_OUTPUTS generate
	begin
		SOFTMAX_EXP(i) <= f_exp(to_integer(unsigned(POP_COUNTER(i))));
	end generate;
	
	SOFTMAX_SUM <= f_sum(SOFTMAX_EXP);
	
	SOFTMAX_i:
	for i in 0 to N_OUTPUTS generate
	begin
		SOFTMAX(i) <= SOFTMAX_EXP(i) * 100 / SOFTMAX_SUM when SOFTMAX_SUM > 0 else 0; 
	end generate;

	OUTPUT <= STD_LOGIC_VECTOR(to_unsigned(f_argmax(SOFTMAX), OUTPUT'length));

end layer_output;
