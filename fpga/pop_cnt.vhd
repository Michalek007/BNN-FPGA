-------------------------------------------------------------------------------
--
-- Title       : pop_cnt
-- Design      : neural_network
-- Author      : Micha³ Nizio³
-- Company     : AGH
--
-------------------------------------------------------------------------------
--
-- Description : Population count 
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {pop_cnt} architecture {pop_cnt}}

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

entity pop_cnt is
	 generic (
		 N_INPUTS : integer := 2;
		 N_OUTPUTS : integer := 1
	 ); 
	 port(
		 INPUT : in STD_LOGIC_VECTOR(0 to N_INPUTS);
		 OUTPUT : out STD_LOGIC_VECTOR(0 to N_OUTPUTS)
	     );
end pop_cnt;

--}} End of automatically maintained section

architecture pop_cnt of pop_cnt is
begin
		process(INPUT)
		variable vpopcnt: STD_LOGIC_VECTOR(0 to N_OUTPUTS);
		begin
			vpopcnt := (others => '0');
			l_popcnt : for k in 0 to N_INPUTS loop
				vpopcnt := vpopcnt + INPUT(k);
			end loop l_popcnt;
			OUTPUT <= vpopcnt;
		end process;

end pop_cnt;
