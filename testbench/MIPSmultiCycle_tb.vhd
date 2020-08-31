library ieee;                                
use ieee.std_logic_1164.all;                 
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity MIPSmultiCycle_tb is
end entity MIPSmultiCycle_tb;

architecture arc_MIPSmultiCycle_tb of MIPSmultiCycle_tb is
	
	component MIPSmultiCycle port(
		clock	:in std_logic;
		State :out std_logic_vector(3 downto 0);
		writtenRegBus	:out std_logic_vector(4 downto 0);
		writtenRegDataBus	:out std_logic_vector(31 downto 0);
		writtenWordBus	:out std_logic_vector(31 downto 0);
		writtenWordDataBus	:out std_logic_vector(31 downto 0);
		PCoutputBus	:out std_logic_vector(31 downto 0)
		);
	end component;

	signal clock_tb: std_logic := '0'; -- initial value for clock
	signal State_tb: std_logic_vector(3 downto 0); -- for checking of states
	signal writtenRegBus_tb	:std_logic_vector(4 downto 0);
	signal writtenRegDataBus_tb	:std_logic_vector(31 downto 0);
	signal writtenWordBus_tb	:std_logic_vector(31 downto 0);
	signal writtenWordDataBus_tb	:std_logic_vector(31 downto 0);
	signal PCoutputBus_tb:	std_logic_vector(31 downto 0) := X"00000000"; -- initial value of PC
	constant T: time := 20 ns; -- clock cycle is 20 nsecs
	
begin

	DUT : MIPSmultiCycle 
		port map(
		-- input
		clock	=> clock_tb,
		-- outputs
		State	=> State_tb,
		writtenRegBus	=> writtenRegBus_tb,
		writtenRegDataBus	=> writtenRegDataBus_tb,
		writtenWordBus => writtenWordBus_tb,
		writtenWordDataBus => writtenWordDataBus_tb,
		PCoutputBus => PCoutputBus_tb
		);
	
	MIPSmultiCycle_stim: process is
		variable str_o: line; -- for printing messages
	begin
		-- First, we check that PC is 0
		if (PCoutputBus_tb /= X"00000000") then
			write(str_o, string'(" PC error - Does not equal 0"));
			writeline(output, str_o); 
			assert false report time'image(now)
				severity failure; -- in case of failure, simulation stops immediately
		end if;
		wait for 4*T; -- wait for 4 clock cycles - number of remaining clock cycles for lw
		-- now we check that the expected value was written to $8 (as the first instruction in memory)
		if (writtenRegBus_tb /= "01000") then -- register check
			write(str_o, string'(" writtenReg error - does not equal expected register"));
			writeline(output, str_o); 
			assert false report time'image(now)
				severity failure;
		elsif (writtenRegDataBus_tb /= X"1152AF78") then -- data check against expected value
			write(str_o, string'(" writtenRegData error - does not equal expected value"));
			writeline(output, str_o); 
			assert false report time'image(now)
				severity failure;
		end if;
		wait for 4*T; -- wait for 4 more clock cycles to reach state 7 for R-type instruction
		-- same check as before, only for $10
		if (writtenRegBus_tb /= "01010") then
			write(str_o, string'(" writtenReg error - does not equal expected register"));
			writeline(output, str_o); 
			assert false report time'image(now)
				severity failure;
		elsif (writtenRegDataBus_tb /= X"1152AF78") then
			write(str_o, string'(" writtenRegData error - does not equal expected value"));
			writeline(output, str_o); 
			assert false report time'image(now)
				severity failure;
		end if;
		wait for 4*T; -- another R-type instruction
		-- same check as before, only for $11
		if (writtenRegBus_tb /= "01011") then
			write(str_o, string'(" writtenReg error - does not equal expected register"));
			writeline(output, str_o); 
			assert false report time'image(now)
				severity failure;
		elsif (writtenRegDataBus_tb /= X"1152AF78") then
			write(str_o, string'(" writtenRegData error - does not equal expected value"));
			writeline(output, str_o); 
			assert false report time'image(now)
				severity failure;
		end if;
		wait for 4*T; -- another R-type instruction
		-- same check as before, only for $12
		if (writtenRegBus_tb /= "01100") then
			write(str_o, string'(" writtenReg error - does not equal expected register"));
			writeline(output, str_o); 
			assert false report time'image(now)
				severity failure;
		elsif (writtenRegDataBus_tb /= X"1152AF78") then
			write(str_o, string'(" writtenRegData error - does not equal expected value"));
			writeline(output, str_o); 
			assert false report time'image(now)
				severity failure;
		end if;
		wait for 4*T; -- another R-type instruction
		-- same check as before, only for $13
		if (writtenRegBus_tb /= "01101") then
			write(str_o, string'(" writtenReg error - does not equal expected register"));
			writeline(output, str_o); 
			assert false report time'image(now)
				severity failure;
		elsif (writtenRegDataBus_tb /= X"1152AF78") then
			write(str_o, string'(" writtenRegData error - does not equal expected value"));
			writeline(output, str_o); 
			assert false report time'image(now)
				severity failure;
		end if;
		wait for 4*T; -- another R-type instruction
		-- same check as before, only for $14
		if (writtenRegBus_tb /= "01110") then
			write(str_o, string'(" writtenReg error - does not equal expected register"));
			writeline(output, str_o); 
			assert false report time'image(now)
				severity failure;
		elsif (writtenRegDataBus_tb /= X"00000000") then
			write(str_o, string'(" writtenRegData error - does not equal expected value"));
			writeline(output, str_o); 
			assert false report time'image(now)
				severity failure;
		end if;
		wait for 4*T; -- wait for state 0 of jump instruction
		-- now we check if PC was changed according to branch
		if (PCoutputBus_tb /= X"00000028") then
			write(str_o, string'(" PC error - does not equal expected value"));
			writeline(output, str_o); 
			assert false report time'image(now)
				severity failure;
		end if;
		wait for 3*T; -- wait for state 0 of sw instruction
		-- now we check if PC was changed according to jump
		if (PCoutputBus_tb /= X"0000003C") then
			write(str_o, string'(" PC error - does not equal expected value"));
			writeline(output, str_o); 
			assert false report time'image(now)
				severity failure;
		end if;
		wait for 3*T; -- wait for state 0 after finishing sw instruction
		-- now we check if the expected value has been written to the expected memory word
		if (writtenWordBus_tb /= X"00000050") then
			write(str_o, string'(" writtenWord error - does not equal expected memory word"));
			writeline(output, str_o); 
			assert false report time'image(now)
				severity failure;
		elsif (writtenWordDataBus_tb /= X"00000000") then
			write(str_o, string'(" writtenWordData error - does not equal expected value"));
			writeline(output, str_o); 
			assert false report time'image(now)
				severity failure;
		end if;
		-- print final test message if no errors occured
		assert false report "Test finished with no errors."
			severity failure;
	end process MIPSmultiCycle_stim;
	
	clock_gen: process begin
	-- process for clock generation
		clock_tb <= '0';
		wait for T/2;
		clock_tb <= '1';
		wait for T/2;
	end process clock_gen;

end architecture arc_MIPSmultiCycle_tb;