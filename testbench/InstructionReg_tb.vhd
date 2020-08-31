library ieee;                                
use ieee.std_logic_1164.all;                 
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity InstructionReg_tb is
end;

architecture arc_InstructionReg_tb of InstructionReg_tb is
	-- tb signals
	signal clk_tb: std_logic := '0'; -- initial value for clock
	signal inputIns_tb: std_logic_vector(31 downto 0);
	signal IRWrite_tb: std_logic;
	signal opcodeOut_tb: std_logic_vector(5 downto 0);
	signal rsOut_tb, rtOut_tb: std_logic_vector(4 downto 0);
	signal instructionOut_tb: std_logic_vector(15 downto 0);
	signal expect:	std_logic_vector(31 downto 0);
	constant T: time := 20 ns; -- period of clock

-- component declaration
component InstructionReg port(
	inputIns	:in std_logic_vector(31 downto 0);
	IRWrite	:in std_logic;
	opcodeOut	:out std_logic_vector(5 downto 0);
	rsOut, rtOut	:out std_logic_vector(4 downto 0);
	instructionOut	:out std_logic_vector(15 downto 0)
	);
end component;

begin

DUT: InstructionReg
	port map(
	-- inputs
	inputIns	=> inputIns_tb,
	IRWrite	=> IRWrite_tb,
	-- outputs
	opcodeOut	=> opcodeOut_tb,
	rsOut	=> rsOut_tb,
	rtOut	=> rtOut_tb,
	instructionOut	=> instructionOut_tb
	);

InstructionReg_stim: process is
	variable output_temp: std_logic_vector(31 downto 0); -- to store outputs temporarily
	variable str_o: line; -- for printing messages
begin
	inputIns_tb <= X"FFFFFFFF"; -- write all ones to IR for test
	IRWrite_tb <= '1'; -- write enable
	wait until rising_edge(clk_tb); -- let DUT update
	expect <= inputIns_tb; -- write updated input to expect signal
	IRWrite_tb <= '0'; -- write disable
	wait until falling_edge(clk_tb);
	output_temp := opcodeOut_tb & rsOut_tb & rtOut_tb & instructionOut_tb; -- concatenate all outputs to single 32 bit temp variable
	if (output_temp /= expect) then -- check variable and expected value for equality
		-- print message
		write(str_o, string'(" Concatenated output does not equal original input"));
		writeline(output, str_o); 
		assert false report time'image(now)
			severity failure; -- in case of failure, simulation stops immediately
	end if;
	assert false report "Test finished with no errors."
	-- print final test message if no errors occured
		severity failure;
end process;

clk_gen: process begin
-- process for clock generation
	clk_tb <= '0';
	wait for T/2;
	clk_tb <= '1';
	wait for T/2;
end process clk_gen;

end architecture arc_InstructionReg_tb;