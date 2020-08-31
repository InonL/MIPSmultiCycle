library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signExtend_16to32 is port(
	input_16	:in std_logic_vector(15 downto 0); -- 16 bit input
	output_32	:out std_logic_vector(31 downto 0) := X"00000000" -- 32 bit output
	);
end signExtend_16to32;

architecture arc_signExtend_16to32 of signExtend_16to32 is 
begin
	output_32 <= X"0000" & input_16 when input_16(15) = '0' else -- when input is positive
					 X"FFFF" & input_16 when input_16(15) = '1' else -- when input is negative
					 X"00000000";
end arc_signExtend_16to32;