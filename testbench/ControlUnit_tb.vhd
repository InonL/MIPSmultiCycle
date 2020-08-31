library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity ControlUnit_tb is
end entity ControlUnit_tb;

architecture arc_ControlUnit_tb of ControlUnit_tb is
	signal clk_tb: std_logic := '0'; -- initial value for clock
	signal opcode_tb: std_logic_vector(5 downto 0) := "100011"; -- initialized to first opcode value, for testbench
	signal PCSource_tb: std_logic_vector(1 downto 0);
	signal ALUOp_tb: std_logic_vector(1 downto 0);
	signal ALUSrcB_tb: std_logic_vector(1 downto 0);
	signal ALUSrcA_tb: std_logic;
	signal RegWrite_tb: std_logic;
	signal RegDst_tb: std_logic;
	signal PCWriteCond_tb: std_logic;
	signal PCWrite_tb: std_logic;
	signal IorD_tb: std_logic;
	signal MemRead_tb: std_logic;
	signal MemWrite_tb: std_logic;
	signal MemtoReg_tb: std_logic;
	signal IRWrite_tb: std_logic;
	signal Y_tb:	std_logic_vector(3 downto 0);
	constant T: time := 20 ns;
	signal outputs:	std_logic_vector(15 downto 0); -- concatenated outputs of control unit, to compare against expected value
	
type opcodeArray is array (0 to 4) of std_logic_vector(5 downto 0);
	signal opcodeBank:	opcodeArray :=( --  all possible opcodes to cycle through during test
	"100011", "101011", "000000", "000100", "000010");
	
component ControlUnit port(
	clk	:in std_logic;
	opcode	:in std_logic_vector(5 downto 0);
	PCSource	:out std_logic_vector(1 downto 0);
	ALUOp	:out std_logic_vector(1 downto 0);
	ALUSrcB	:out std_logic_vector(1 downto 0); 
	ALUSrcA	:out std_logic;
	RegWrite	:out std_logic;
	RegDst	:out std_logic;
	PCWriteCond	:out std_logic;
	PCWrite	:out std_logic;
	IorD	:out std_logic;
	MemRead	:out std_logic;
	MemWrite	:out std_logic;
	MemtoReg	:out std_logic;
	IRWrite	:out std_logic;
	Y	:out std_logic_vector(3 downto 0)
	);
end component;
begin

DUT : ControlUnit 
	port map(
	-- inputs
	clk         => clk_tb,
	opcode      => opcode_tb,
	-- outputs
	PCSource    => PCSource_tb,
	ALUOp       => ALUOp_tb,
	ALUSrcB     => ALUSrcB_tb,
	ALUSrcA     => ALUSrcA_tb,
	RegWrite    => RegWrite_tb,
	RegDst      => RegDst_tb,
	PCWriteCond => PCWriteCond_tb,
	PCWrite     => PCWrite_tb,
	IorD        => IorD_tb,
	MemRead     => MemRead_tb,
	MemWrite    => MemWrite_tb,
	MemtoReg    => MemtoReg_tb,
	IRWrite     => IRWrite_tb,
	Y	=> Y_tb
	);

	-- concatenating all outputs to simplify comparison between actual outputs to expected value
	outputs <= PCSource_tb & ALUOp_tb & ALUSrcB_tb & ALUSrcA_tb & RegWrite_tb & RegDst_tb & 
		   PCWriteCond_tb & PCWrite_tb & IorD_tb & MemRead_tb & MemWrite_tb & MemtoReg_tb & IRWrite_tb;
				  
ControlUnit_stim: process is
	variable i: integer; -- variables for loops
	variable str_o: line; -- for printing messages
	variable expect: std_logic_vector(15 downto 0); -- expected value of outputs, to compare against actual value for errors
begin
	for i in 0 to 4 loop
		expect := "0000010000101001"; -- expected state 0 control outputs vector
		wait until rising_edge(clk_tb); -- wait for DUT to update
		if (Y_tb /= "0000") then -- if state is not 0
			write(str_o, string'(" State 0 error - does not equal to expected state"));
			writeline(output, str_o); 
			assert false report time'image(now)
				severity failure; -- in case of failure, simulation stops immediately
		elsif (outputs /= expect) then -- if control outputs vector is not equal to expected value
			write(str_o, string'(" State 0 control outputs error - not equal to expected values"));
			writeline(output, str_o); 
			assert false report time'image(now)
				severity failure; -- in case of failure, simulation stops immediately
		end if;

		wait until falling_edge(clk_tb); -- wait for DUT to update, falling edge in order not to miss State 1
		expect := "0000110000000000"; -- expected state 1 control outputs vector
		if (Y_tb /= "0001") then -- if state is not 1
			write(str_o, string'(" State 1 error - does not equal to expected state"));
			writeline(output, str_o); 
			assert false report time'image(now)
				severity failure;
		elsif (outputs /= expect) then -- etc
			write(str_o, string'(" State 1 control outputs error - not equal to expected values"));
			writeline(output, str_o); 
			assert false report time'image(now)
				severity failure;
		end if;

		opcode_tb <= opcodeBank(i); -- cycle through every possible opcode
		wait until rising_edge(clk_tb); -- for opcode_tb to be updated within DUT
		case opcode_tb is
				when "100011"|"101011" => -- load/store word, state 2
					expect := "0000101000000000"; -- expected state 2 control outputs vector
					wait until rising_edge(clk_tb); -- wait for DUT to update
					if (Y_tb /= "0010") then -- if state is not 2
						write(str_o, string'(" State 2 error - does not equal to expected state"));
						writeline(output, str_o); 
						assert false report time'image(now)
							severity failure;
					elsif (outputs /= expect) then -- etc
						write(str_o, string'(" State 2 control outputs error - not equal to expected values"));
						writeline(output, str_o); 
						assert false report time'image(now)
							severity failure;
					end if;
					wait until rising_edge(clk_tb); -- wait for state 3
					if opcode_tb = "100011" then -- load word, state 3
						expect := "0000000000011000"; -- expected state 3 control outputs vector
						if (Y_tb /= "0011") then -- if state is not 3
							write(str_o, string'(" State 3 error - does not equal to expected state"));
							writeline(output, str_o); 
							assert false report time'image(now)
								severity failure;
						elsif (outputs /= expect) then -- etc
							write(str_o, string'(" State 3 control outputs error - not equal to expected values"));
							writeline(output, str_o); 
							assert false report time'image(now)
								severity failure;
						end if;
						wait until rising_edge(clk_tb); -- wait for state 4 
						expect := "0000000100000010"; -- expected state 4 control outputs vector
						if (Y_tb /= "0100") then -- if state is not 4
							write(str_o, string'(" State 4 error - does not equal to expected state"));
							writeline(output, str_o); 
							assert false report time'image(now)
								severity failure;
						elsif (outputs /= expect) then -- etc
							write(str_o, string'(" State 4 control outputs error - not equal to expected values"));
							writeline(output, str_o); 
							assert false report time'image(now)
								severity failure;
						end if;
					elsif opcode_tb = "101011" then -- store word, state 5
						expect := "0000000000010100"; -- expected state 5 control outputs vector
						if (Y_tb /= "0101") then -- if state is not 5
							write(str_o, string'(" State 5 error - does not equal to expected state"));
							writeline(output, str_o); 
							assert false report time'image(now)
								severity failure;
						elsif (outputs /= expect) then -- etc
							write(str_o, string'(" State 5 control outputs error - not equal to expected values"));
							writeline(output, str_o); 
							assert false report time'image(now)
								severity failure;
						end if;
					end if;
						
				when "000000" => -- R-type, state 6
					expect := "0010001000000000"; -- expected state 6 control outputs vector
					wait until rising_edge(clk_tb); -- wait for DUT to update to state 6
					if (Y_tb /= "0110") then -- if state is not 6
						write(str_o, string'(" State 6 error - does not equal to expected state"));
						writeline(output, str_o); 
						assert false report time'image(now)
							severity failure;
					elsif (outputs /= expect) then -- etc
						write(str_o, string'(" State 6 control outputs error - not equal to expected values"));
						writeline(output, str_o); 
						assert false report time'image(now)
							severity failure;
					end if;
					wait until rising_edge(clk_tb); -- wait for update to state 7
					expect := "0000000110000000"; -- expected state 7 control outputs vector
					if (Y_tb /= "0111") then -- if state is not 7
						write(str_o, string'(" State 7 error - does not equal to expected state"));
						writeline(output, str_o); 
						assert false report time'image(now)
							severity failure;
					elsif (outputs /= expect) then -- etc
						write(str_o, string'(" State 7 control outputs error - not equal to expected values"));
						writeline(output, str_o); 
						assert false report time'image(now)
							severity failure;
					end if;
					
				when "000100" => -- branch, state 8
					expect := "0101001001000000"; -- expected state 8 control outputs vector
					wait until rising_edge(clk_tb); -- wait for update to state 8
					if (Y_tb /= "1000") then -- if state is not 8
						write(str_o, string'(" State 8 error - does not equal to expected state"));
						writeline(output, str_o); 
						assert false report time'image(now)
							severity failure;
					elsif (outputs /= expect) then -- etc
						write(str_o, string'(" State 8 control outputs error - not equal to expected values"));
						writeline(output, str_o); 
						assert false report time'image(now)
							severity failure;
					end if;
				when "000010" => -- jump, state 9
					expect := "1000000000100000"; -- expected state 9 control outputs vector
					wait until rising_edge(clk_tb); -- wait for update to state 9
					if (Y_tb /= "1001") then -- if state is not 9
						write(str_o, string'(" State 9 error - does not equal to expected state"));
						writeline(output, str_o); 
						assert false report time'image(now)
							severity failure;
					elsif (outputs /= expect) then -- etc
						write(str_o, string'(" State 9 control outputs error - not equal to expected values"));
						writeline(output, str_o); 
						assert false report time'image(now)
							severity failure;
					end if;
				when others =>
					write(str_o, string'(" opcode error - unexpected value"));
					writeline(output, str_o); 
					assert false report time'image(now)
						severity failure;
		end case;
		
	end loop;
	
	-- final check that the control unit came back to state 0, same procedure as before
	expect := "0000010000101001";
		wait until rising_edge(clk_tb);
		if (Y_tb /= "0000") then 
			write(str_o, string'(" State 0 error - does not equal to expected state"));
			writeline(output, str_o); 
			assert false report time'image(now)
				severity failure;
		elsif (outputs /= expect) then
			write(str_o, string'(" State 0 control outputs error - not equal to expected values"));
			writeline(output, str_o); 
			assert false report time'image(now)
				severity failure;
		end if;
		
	-- print final test message if no errors occured
	assert false report "Test finished with no errors."
		severity failure;
		
end process ControlUnit_stim;

-- process for clock generation
clk_gen: process begin
	clk_tb <= '0';
	wait for T/2;
	clk_tb <= '1';
	wait for T/2;
end process clk_gen;

end architecture arc_ControlUnit_tb;