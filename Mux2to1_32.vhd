library ieee;
use ieee.std_logic_1164.all;

entity Mux2to1_32 is port(
	Din0, Din1	:in  std_logic_vector(31 downto 0); -- 2 input buses of 32 bits
	Sel	:in  std_logic; -- control input of 1 bit
	Dout	:out std_logic_vector(31 downto 0) := X"00000000"-- 1 output bus of 32 bits
	);
end Mux2to1_32;

architecture arc_Mux2to1_32 of Mux2to1_32 is
begin
	with Sel select
		Dout <= Din0 when '0',
				  Din1 when '1',
				  X"00000000" when others;
end arc_Mux2to1_32;
