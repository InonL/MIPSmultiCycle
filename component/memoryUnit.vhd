library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity memoryUnit is port(
	clk	:in std_logic;
	addr :in std_logic_vector(31 downto 0); -- address to be read while memR = '1'
	writeData :in std_logic_vector(31 downto 0); -- data to be written while memW = '1'
	memR, memW	:in std_logic; -- control lines
	memData :out std_logic_vector(31 downto 0) := X"00000000"; -- output data after read
	
	-- writtenWord for checking written memory values
	writtenWord	:out std_logic_vector(31 downto 0) := X"00000000"
	);
end memoryUnit;

architecture arc_memoryUnit of memoryUnit is
	type memory is array (0 to 127) of std_logic_vector(7 downto 0);
	signal mem	:memory :=(
	-- 0 to 63 are instructions, 64 to 127 are memory
	
	-- preset instructions, 4 bytes each
	X"8C", X"08", X"00", X"50", -- lw $8, 20($0)
	X"01", X"00", X"50", X"20", -- add $10,$8,$0
	X"01", X"00", X"58", X"22", -- sub $11,$8,$0
	X"01", X"6A", X"60", X"24", -- and $12,$11,$10
	X"01", X"8B", X"68", X"25", -- or $13,$12,$11
	X"01", X"A0", X"70", X"2A", -- slt $14,$13,$0
	X"11", X"C0", X"00", X"03", -- beq $14,$0,3
	X"00", X"00", X"00", X"00", -- this is skipped over
	X"00", X"00", X"00", X"00", -- this is skipped over
	X"00", X"00", X"00", X"00", -- this is skipped over
	X"08", X"00", X"00", X"0F", -- j 15
	X"00", X"00", X"00", X"00", -- this is skipped over
	X"00", X"00", X"00", X"00", -- this is skipped over
	X"00", X"00", X"00", X"00", -- this is skipped over
	X"00", X"00", X"00", X"00", -- this is skipped over
	X"AC", X"0E", X"00", X"50", -- sw $14, 20($0)
	
	-- preset arbitrary memory values
	X"21", X"35", X"1C", X"78",
	X"DE", X"BC", X"9C", X"CA",
	X"F9", X"38", X"17", X"25",
	X"A7", X"BD", X"0C", X"81",
	X"11", X"52", X"AF", X"78",
	X"A1", X"3C", X"FF", X"3B",
	X"45", X"AC", X"34", X"22",
	X"B3", X"AB", X"14", X"E2",
	X"C1", X"7F", X"5C", X"F3",
	X"5E", X"41", X"BC", X"FD",
	X"5B", X"AE", X"F1", X"E3",
	X"21", X"1F", X"23", X"FA",
	X"EF", X"CA", X"2A", X"D2",
	X"D9", X"1B", X"C2", X"33",
	X"44", X"3F", X"AF", X"12",
	X"B2", X"3C", X"1E", X"FF"
	);

begin
	memAccess: process (addr,writeData,clk) is
	begin
		if (clk = '1') then
			if (memR = '1' and memW = '0') then -- read mode
				-- concatenation in bytes
				memData <= mem(conv_integer(addr)) & mem(conv_integer(addr)+1)
							& mem(conv_integer(addr)+2) & mem(conv_integer(addr)+3);
			elsif (memR = '0' and memW = '1') then -- write mode
				-- chopping up writeData to 4 bytes to fit in four consecutive memory slots
				mem(conv_integer(addr)) <= writeData(31 downto 24);
				mem(conv_integer(addr)+1) <= writeData(23 downto 16);
				mem(conv_integer(addr)+2) <= writeData(15 downto 8);
				mem(conv_integer(addr)+3) <= writeData(7 downto 0);
			else -- if memR and memW aren't coordinated
				memData <= X"00000000"; -- output zeros
			end if;
		end if;
	end process memAccess;
	
	memTest: process(mem) is -- to output written memory cells for comparison
		variable tempAddr: std_logic_vector(31 downto 0); -- to store current address in case it is written
	begin
		tempAddr := addr; -- to save current address
		writtenWord <= mem(conv_integer(tempAddr)) & mem(conv_integer(tempAddr)+1)
						& mem(conv_integer(tempAddr)+2) & mem(conv_integer(tempAddr)+3);
		-- writtenWord is used to see which word was being written for testing purposes
		-- and for checking that sw instruction was executed correctly
	end process memTest;
end arc_memoryUnit;