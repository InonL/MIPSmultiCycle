library ieee;                                
use ieee.std_logic_1164.all;                 
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity ALU_tb is
end entity ALU_tb;

architecture arc_ALU_tb of ALU_tb is
-- internal testbench signals
	constant delay:	TIME := 10 NS;
	-- constant delay to compensate for ALU update time
	signal A_tb: std_logic_vector(31 downto 0) := X"00000001"; -- initializtion for first test
	signal B_tb: std_logic_vector(31 downto 0) := X"00000001"; -- initializtion for first test
	signal result_tb: std_logic_vector(31 downto 0);
	signal ctrl_tb:	std_logic_vector(2 downto 0) := "010"; -- initializtion for first test
	signal zero_tb:	std_logic;
	signal expect:	std_logic_vector(31 downto 0);
	
component ALU -- ALU component declaration
	port (
		A,B	:in std_logic_vector(31 downto 0);
		control	:in std_logic_vector(2 downto 0);
		result	:out std_logic_vector(31 downto 0);
		zero	:out std_logic
		);
end component;

begin

DUT : ALU
	port map(
		-- inputs
		A => A_tb, B => B_tb,
		-- outputs
		control => ctrl_tb, zero => zero_tb, result => result_tb
		);
		
ALU_stim: process is
	variable i, j, k: integer; -- variables in for loops
	variable Avar, Bvar:	signed(31 downto 0) := X"00000001"; 
	-- locally updating variables to prevent delay from result_tb to expect
	-- intialized to same value as A_tb and B_tb, also to compansate for ALU update time
	variable str_o: line;
	-- for printing messages
begin
	for i in 0 to 31 loop -- total length of loop: 48.05 USECS
		A_tb <= std_logic_vector(shift_left(unsigned(std_logic_vector'(X"00000001")),i));
		-- shift left by i for every loop, to check every bit of A
		Avar := shift_left(signed(std_logic_vector'(X"00000001")),i);
		-- same for local variable
		for j in 0 to 31 loop
			B_tb <= std_logic_vector(shift_left(unsigned(std_logic_vector'(X"00000001")),j));
			Bvar := shift_left(signed(std_logic_vector'(X"00000001")),j);
			-- same for B in the inner loop
			for k in 0 to 4 loop
				if k = 0 then -- test for 'add'
					ctrl_tb <= "010";
					-- control value for add
					expect <= std_logic_vector(Avar + Bvar); -- expect is the desired result from DUT
					wait for delay; -- for DUT to update its values
					if (expect /= result_tb) then
						write(str_o, string'("Error - Add")); -- print to screen
						writeline(output, str_o); 
						assert false report time'image(now)
							severity failure; -- in case of failure, simulation stops immediately
					end if;
				elsif k = 1 then -- test for 'sub'
					ctrl_tb <= "110";
					expect <= std_logic_vector(Avar - Bvar);
					wait for delay;
					if (expect /= result_tb) then
						write(str_o, string'("Error - Sub"));
						writeline(output, str_o);
						assert false report time'image(now)
							severity failure;
					end if;
				elsif k = 2 then -- test for 'AND'
					ctrl_tb <= "000";
					expect <= std_logic_vector(Avar AND Bvar);
					wait for delay;
					if (expect /= result_tb) then
						write(str_o, string'("Error - AND"));
						writeline(output, str_o);
						assert false report time'image(now)
							severity failure;
					end if;
				elsif k = 3 then -- test for 'OR'
					ctrl_tb <= "001";
					expect <= std_logic_vector(Avar OR Bvar);
					wait for delay;
					if (expect /= result_tb) then
						write(str_o, string'("Error - OR"));
						writeline(output, str_o);
						assert false report time'image(now)
							severity failure;
					end if;
				elsif k = 4 then -- test for 'SLT'
					ctrl_tb <= "111";
					if ( unsigned(Avar) < unsigned(Bvar) ) then
						expect <= X"00000001";
					else
						expect <= X"00000000";
					end if;
					wait for delay;
					if (expect /= result_tb) then
						write(str_o, string'("Error - SLT"));
						writeline(output, str_o);
						assert false report time'image(now)
							severity failure;
					end if;
				end if;
			end loop;	
		end loop;
	end loop;
	assert false report "Test finished with no errors."
	-- finished test message if no errors occured
		severity failure;
end process ALU_stim;

end architecture arc_ALU_tb;