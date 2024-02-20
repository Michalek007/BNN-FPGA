library IEEE;
use IEEE.STD_LOGIC_1164.all;

package layer_constants is

constant LAYER_INPUT_N_INPUTS: INTEGER := 783;  -- simulation: 2 -- mnist simulation: 783; implementation: --783;

constant LAYER_HIDDEN_N_INPUTS: INTEGER := 49; -- simulation: 7 -- mnist simulation: 49; implementation: --49;

constant LAYER_HIDDEN_N_OUTPUTS: INTEGER := 49; -- simulation: 7 -- mnist simulation: 49; implementation: --49;

constant LAYER_OUTPUT_N_OUTPUTS: INTEGER := 9; -- simulation: 7 -- mnist simulation: 9; implementation: --9;

constant LAYER_HIDDEN_POP_CNT_MAX: INTEGER := 6; -- simulation: 3 -- mnist simulation: 6; implementation: --6;

constant LAYER_OUTPUT_POP_CNT_MAX: INTEGER := 6; -- simulation: 3 -- mnist simulation: 6; implementation: --6;

constant SYS_CLOCK_FREQ: INTEGER := 100_000_000; -- simulation: 100_000_000 -- mnist simulation: 100_000; implementation: --100_000_000;

type INPUT_ARRAY is array (0 to LAYER_INPUT_N_INPUTS) of STD_LOGIC_VECTOR(0 to 7);

end layer_constants;


package body layer_constants is
end layer_constants;