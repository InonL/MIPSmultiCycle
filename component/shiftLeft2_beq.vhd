library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shiftLeft2_beq is port(
	input	:in std_logic_vector(31 downto 0); -- 32 bit input
	output	:out std_logic_vector(31 downto 0) := X"00000000" -- 32 bit output
	);
end shiftLeft2_beq;

architecture arc_shiftLeft2_beq of shiftLeft2_beq is 
begin
	output <= input(29 downto 0) & "00"; -- shift left by 2
end arc_shiftLeft2_beq;