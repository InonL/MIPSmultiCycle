library ieee;                                
use ieee.std_logic_1164.all;                 
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity memoryUnit_tb is
end entity memoryUnit_tb;

architecture arc_memoryUnit_tb of memoryUnit_tb is
	signal clk_tb: std_logic := '0'; -- initial value for clock
	signal addr_tb: std_logic_vector(31 downto 0) := X"00000000"; -- first address
	signal writeData_tb: std_logic_vector(31 downto 0) := X"FFFFFFFF"; -- data to be written
	signal memR_tb: std_logic := '1'; -- read will be done first
	signal memW_tb: std_logic := '0';
	signal memData_tb: std_logic_vector(31 downto 0) := X"8C080050"; -- initial value to prevent failure during first loop run
	signal expect: std_logic_vector(31 downto 0) := X"8C080050"; -- initial value to prevent failure during first loop run
	constant T: time := 20 ns; 
	
type memory is array (0 to 127) of std_logic_vector(7 downto 0);
	signal mem_tb	:memory :=(
	-- memory the same as in the DUT, for testing of outputs
	
	-- instruction memory
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
	
	-- data memory - arbitrary values, identical to DUT memory
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
	
component memoryUnit port(
	-- inputs
  	clk	:in std_logic;
  	addr :in std_logic_vector(31 downto 0);
  	writeData :in std_logic_vector(31 downto 0);
  	memR, memW	:in std_logic;
	-- output
  	memData :out std_logic_vector(31 downto 0);
	-- for testing, not used in this tb
	writtenWord	:out std_logic_vector(31 downto 0) 
  	);
end component;

begin

DUT : memoryUnit 
	port map(
	-- inputs
	clk       => clk_tb,
	addr      => addr_tb,
	writeData => writeData_tb,
	memR      => memR_tb,
	memW      => memW_tb,
	-- output
	memData   => memData_tb
	);

memoryUnit_stim: process is
	variable i, j, k: integer; -- variables for loops
	variable str_o: line; -- for printing messages
begin
	for i in 0 to 31 loop
		wait until falling_edge(clk_tb); -- in order to update while DUT isn't active
		addr_tb <= std_logic_vector(0 + to_unsigned(4*i, 32));
		wait until rising_edge(clk_tb); -- wait for DUT to be active
		expect <= mem_tb(0 + i*4) & mem_tb(1 + i*4) & mem_tb(2 + i*4) & mem_tb(3 + i*4);
		if (expect /= memData_tb) then
		-- report if output data does not equal to control memory
			write(str_o, string'(" memData error - does not equal to expected value"));
			writeline(output, str_o); 
			assert false report time'image(now)
				severity failure; -- in case of failure, simulation stops immediately
		end if;
	end loop;
	wait until falling_edge(clk_tb); -- to update memR and memW 
	memR_tb <= '0';
	memW_tb <= '1';
	wait until rising_edge(clk_tb); -- to let DUT be updated
	expect <= X"00000000"; -- reset expect back to 0
	for j in 0 to 31 loop
		wait until falling_edge(clk_tb); -- update addr_tb value while DUT not active
		addr_tb <= std_logic_vector(0 + to_unsigned(4*j, 32));
		wait until rising_edge(clk_tb); -- wait for DUT
	end loop;

	wait until falling_edge(clk_tb);
	memR_tb <= '1';
	memW_tb <= '0';
	expect <= X"FFFFFFFF"; -- data to be read after it was written in the previous loop
	for k in 0 to 31 loop
	-- same as first loop
		wait until rising_edge(clk_tb);
		addr_tb <= std_logic_vector(0 + to_unsigned(4*k, 32));
		wait until falling_edge(clk_tb);
		if (expect /= memData_tb) then -- only now, expect equals to data written during second loop
			write(str_o, string'(" memWrite error - Written data not equal to expected value"));
			writeline(output, str_o); 
			assert false report time'image(now)
				severity failure; -- in case of failure, simulation stops immediately
		end if;
	end loop;
	assert false report "Test finished with no errors."
	-- print final test message if no errors occured
		severity failure;
end process memoryUnit_stim;

clk_gen: process begin
-- process for clock generation
	clk_tb <= '0';
	wait for T/2;
	clk_tb <= '1';
	wait for T/2;
end process clk_gen;

end architecture arc_memoryUnit_tb;