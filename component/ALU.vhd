library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is port(
	A :in std_logic_vector(31 downto 0);
	B :in std_logic_vector(31 downto 0);
	control	:in std_logic_vector(2 downto 0); -- in MIPS, 3 bits of ALU ctrl unit
	result :out std_logic_vector(31 downto 0) := X"00000000";
	zero	:out std_logic := '0'
	);
end ALU;

architecture arc_ALU of ALU is
signal temp	:signed(31 downto 0);
begin
	process (a,b,control) is
	begin
		case control is
			when "010" =>
				temp <= signed(A) + signed(B); -- add
			when "110" =>
				temp <= signed(A) - signed(B); -- sub
			when "000" =>
				temp <= signed(A AND B); -- and
			when "001" =>
				temp <= signed(A OR B); -- or
			when "111" => 
				if ( unsigned(A) < unsigned(B) ) then -- slt (if A < B, temp = "1", else temp = "0")
					temp <= X"00000001";
				else 
					temp <= X"00000000";
				end if; 
			when others =>
				temp <= signed(A) + signed(B); -- add by default
		end case;
	end process;
	
	zero <= '1' when (temp = X"00000000") else '0';
	result <= std_logic_vector(temp);
	
end arc_ALU;