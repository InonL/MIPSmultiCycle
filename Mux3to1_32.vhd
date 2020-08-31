library ieee;
use ieee.std_logic_1164.all;

entity Mux3to1_32 is port(
	Din0, Din1, Din2	:in  std_logic_vector(31 downto 0); -- 3 input buses of 32 bits
	Sel	:in  std_logic_vector(1 downto 0); -- control input of 2 bits
	Dout	:out std_logic_vector(31 downto 0) := X"00000000" -- 1 output bus of 32 bits
	);
end Mux3to1_32;

architecture arc_Mux3to1_32 of Mux3to1_32 is
begin
	with Sel select
		Dout <= Din0 when "00",
				  Din1 when "01",
				  Din2 when "10",
				  X"00000000" when others;
end arc_Mux3to1_32;
