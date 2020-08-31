library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is port(
	clk	:in std_logic;
	PC_in	:in std_logic_vector(31 downto 0); -- PC input
	writePC	:in std_logic; -- write enable for PC_out
	PC_out	:out std_logic_vector(31 downto 0) := X"00000000" -- initial value for PC
	);
end PC;

architecture arc_PC of PC is 
begin
	process (clk) is
	begin
		if (writePC = '1' and clk = '1') then -- write only when enabled and the clock is 1
			--In order to not overflow into memory, we limit the value of PC_out to 60
			if (PC_in >= X"00000040") then 
				PC_out <= X"00000000"; -- write zero to PC when reached end of instructions
			else
				PC_out <= std_logic_vector(unsigned(PC_in)); -- write PC_in to PC_out
			end if;
		end if;
	end process;
end arc_PC;