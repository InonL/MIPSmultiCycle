library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shiftLeft2_jump is port(
	input_26	:in std_logic_vector(25 downto 0); -- 26 bit input - lower part of jump instruction
	output_28	:out std_logic_vector(27 downto 0) := X"0000000" -- 28 bit output - input multiplied by 4
	);
end shiftLeft2_jump;

architecture arc_shiftLeft2_jump of shiftLeft2_jump is 
begin
	output_28 <= "00" & input_26(23 downto 0) & "00" when input_26(25) = '0' else -- shift left by 2 and sign extend 2 when input is positive
					 X"0000000";
end arc_shiftLeft2_jump;