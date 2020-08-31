library ieee;                                
use ieee.std_logic_1164.all;                 
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity BOR_tb is
end;

architecture arc_BOR_tb of BOR_tb is
	constant delay:	TIME := 10 NS; -- constant delay to compensate for BOR update time
	-- tb signals
	signal readReg1_tb: std_logic_vector(4 downto 0) := "00000";
	signal readReg2_tb: std_logic_vector(4 downto 0) := "00000";
	signal writeReg_tb: std_logic_vector(4 downto 0);
	signal writeData_tb: std_logic_vector(31 downto 0);
	signal regWrite_tb: std_logic;
	signal readData1_tb, readData2_tb: std_logic_vector(31 downto 0) ;
	signal expect:	std_logic_vector(31 downto 0); -- test signal

-- component declaration
component BOR port(
	-- inputs
	readReg1, readReg2	:in std_logic_vector(4 downto 0);
	writeReg	:in std_logic_vector(4 downto 0);
	writeData :in std_logic_vector(31 downto 0);
	regWrite	:in std_logic;
	-- output
	readData1, readData2 :out std_logic_vector(31 downto 0);
	-- for testing, not used in this tb
	writtenReg	:out std_logic_vector(31 downto 0)
	);
end component;

begin

DUT : BOR 
	port map(
	-- inputs
	readReg1  => readReg1_tb,
	readReg2  => readReg2_tb,
	writeReg  => writeReg_tb,
	writeData => writeData_tb,
	regWrite  => regWrite_tb,
	-- outputs
	readData1 => readData1_tb,
	readData2 => readData2_tb 
	);

BOR_stim: process is
	variable i, j, k: integer; -- variables for loops
	variable str_o: line; -- for printing messages
begin
	regWrite_tb <= '1'; -- first we check write
	writeData_tb <= X"FFFFFFFF"; -- writing all ones
	-- loop for writing into every register
	for i in 0 to 31 loop
		writeReg_tb <= std_logic_vector(0 + to_unsigned(i,5));
		wait for delay;
	end loop;
	
	-- now we read every register to see that it contains written data (except $zero)
	regWrite_tb <= '0'; -- to enable read
	expect <= X"FFFFFFFF"; -- to check against written values
	wait for delay;
	-- this loop checks readData1 output
	for j in 0 to 31 loop
		readReg1_tb <= std_logic_vector(0 + to_unsigned(j,5));
		wait for delay;
		if readReg1_tb = "00000" then -- $zero check
			if readData1_tb /= X"00000000" then
				write(str_o, string'(" readData1 - $zero value does not equal 0")); -- print error
				writeline(output, str_o); 
				assert false report time'image(now)
					severity failure; -- in case of failure, simulation stops immediately
			end if;
		elsif (readData1_tb /= expect) then -- every register except $zero
			write(str_o, string'(" readData1 - register data not equal to written data"));
			writeline(output, str_o); 
			assert false report time'image(now)
				severity failure;
		end if;
	end loop;
	
	-- this loop checks readData2 output
	for k in 0 to 31 loop
		readReg2_tb <= std_logic_vector(0 + to_unsigned(k,5));
		wait for delay;
		if readReg2_tb = "00000" then
			if readData2_tb /= X"00000000" then
				write(str_o, string'(" readData2 - $zero value does not equal 0"));
				writeline(output, str_o); 
				assert false report time'image(now)
					severity failure;
			end if;
		elsif (readData2_tb /= expect) then
			write(str_o, string'(" readData2 - register data not equal to written data"));
			writeline(output, str_o);
			assert false report time'image(now)
				severity failure;
		end if;
	end loop;
	assert false report "Test finished with no errors."
	-- print final test message if no errors occured
		severity failure;
			
end process BOR_stim;

end architecture arc_BOR_tb;