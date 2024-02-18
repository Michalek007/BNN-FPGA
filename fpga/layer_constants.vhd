library IEEE;
use IEEE.STD_LOGIC_1164.all;

package layer_constants is

constant LAYER_INPUT_N_INPUTS: INTEGER := 783;  -- simulation: 2

constant LAYER_HIDDEN_N_INPUTS: INTEGER := 49; -- simulation: 7

constant LAYER_HIDDEN_N_OUTPUTS: INTEGER := 49; -- simulation: 7

constant LAYER_OUTPUT_N_OUTPUTS: INTEGER := 9; -- simulation: 7

constant LAYER_HIDDEN_POP_CNT_MAX: INTEGER := 6; -- simulation: 3

constant LAYER_OUTPUT_POP_CNT_MAX: INTEGER := 6; -- simulation: 3

type INPUT_ARRAY is array (0 to LAYER_INPUT_N_INPUTS) of STD_LOGIC_VECTOR(0 to 7);

end layer_constants;


package body layer_constants is
end layer_constants;