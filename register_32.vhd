library IEEE;
use ieee.std_logic_1164.all;

entity register_32 is port(
	clk	:in std_logic;
	input	:in std_logic_vector(31 downto 0); 
	output	:out std_logic_vector(31 downto 0) := X"00000000"
	);
end register_32;

architecture arc_register_32 of register_32 is 
begin
	process (clk) is
	begin
		if rising_edge(clk) then
			output <= input;
		end if;
	end process;
end arc_register_32;