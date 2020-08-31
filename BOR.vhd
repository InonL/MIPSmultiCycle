library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity BOR is port(
	readReg1, readReg2	:in std_logic_vector(4 downto 0); -- registers to be read - 1 is rs, 2 is rt
	writeReg	:in std_logic_vector(4 downto 0); -- register to be written to - rd
	writeData :in std_logic_vector(31 downto 0); -- data to be written to rd
	regWrite	:in std_logic; -- control line - '0' for read, '1' for write
	readData1, readData2 :out std_logic_vector(31 downto 0) := X"00000000"; -- data stored in rs and rt
	
	-- writtenReg for checking written register values
	writtenReg	:out std_logic_vector(31 downto 0) := X"00000000"
	);
end BOR;

architecture arc_BOR of BOR is 
	type reg_file is array (0 to 31) of std_logic_vector(31 downto 0);
	signal registers	:reg_file; -- 32 registers of 32 bit length
begin
	process (readReg1, readReg2, writeReg, writeData) is
	begin
			case regWrite is 
				when '0' => -- read case
					if readReg1 = "00000" then -- $zero always equals 0
						readData1 <= X"00000000";
					else
						readData1 <= registers(conv_integer(readReg1)); 
					end if;
					
					if readReg2 = "00000" then
						readData2 <= X"00000000";
					else
						readData2 <= registers(conv_integer(readReg2));
					end if;
					
				when '1' => -- write case
					if writeReg = "00000" then -- $zero write protection
						registers(conv_integer(writeReg)) <= X"00000000";
					else 
						registers(conv_integer(writeReg)) <= writeData;
					end if;
					readData1 <= (others => '0'); 
					readData2 <= (others => '0');
					
				when others => -- in case of other signals in regWrite
					readData1 <= (others => '0');
					readData2 <= (others => '0');
					
			end case;
	end process;
	
	regTest: process(registers) is -- to output written register for comparison
		variable tempReg: std_logic_vector(4 downto 0); -- to store register number in case it is written
	begin
		tempReg := writeReg; -- to save current register number
		writtenReg <= registers(conv_integer(tempReg));
		-- writtenReg is used to see which register was being written for testing purposes
		-- and for checking that lw and R-type instructions were executed correctly
	end process regTest;
	
end arc_BOR;