library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity ControlUnit is port(
	clk	:in std_logic;
	opcode	:in std_logic_vector(5 downto 0); -- opcode from instruction
	
	-- the various control lines, initialized to state 0 values
	PCSource	:out std_logic_vector(1 downto 0) := "00"; -- choose between: PC + 4, ALUOut, jump
	ALUOp	:out std_logic_vector(1 downto 0) := "00"; -- choose between: add, sub, function in R-type instruction
	ALUSrcB	:out std_logic_vector(1 downto 0) := "01"; -- choose between: rt, constant 4, offset of lw/sw, branch address
	ALUSrcA	:out std_logic := '0'; -- '0' is PC, '1' is rs
	RegWrite	:out std_logic := '0'; -- '1' for write enable to registers
	RegDst	:out std_logic := '0'; -- '1' to write in rd, '0' to write in rt
	PCWriteCond	:out std_logic := '0'; -- '1' is Write to PC, if ALU Zero output = '1'
	PCWrite	:out std_logic := '1'; -- '1' is write to PC, '0' disables write
	IorD	:out std_logic := '0'; -- '0' is read instruction from memory, '1' is read data from memory
	MemRead	:out std_logic := '1'; -- '1' determines if memory is to be read in current clock cycle
	MemWrite	:out std_logic := '0'; -- '1' determines if data will be written to memory
	MemtoReg	:out std_logic := '0'; -- '1' for writing data from memory, '0' for writing ALU result
	IRWrite	:out std_logic := '1'; -- '1' enables write to IR
	
	-- current state output bus for testing, initialized to state 0
	Y	:out std_logic_vector(3 downto 0) := "0000" 
	);
end ControlUnit;

architecture arc_ControlUnit of ControlUnit is 
	type state_type is (S0,S1,S2,S3,S4,S5,S6,S7,S8,S9); -- defined type for state
	signal CS	:state_type := (S0); -- current state signal, initialized to S0 (state zero)
begin

	with CS select -- decode current state to binary number
		Y <= "0000" when S0,
			  "0001" when S1,
			  "0010" when S2,
			  "0011" when S3,
			  "0100" when S4,
			  "0101" when S5,
			  "0110" when S6,
			  "0111" when S7,
			  "1000" when S8,
			  "1001" when S9,
			  "0000" when others;

	combinationalLogic: process(CS) is
	begin
		case CS is
			when S0 => -- fetch
				PCSource <= "00";
				ALUOp <= "00"; 
				ALUSrcB <= "01";
				ALUSrcA <= '0';
				RegWrite <= '0';
				RegDst <= '0';
				PCWriteCond <= '0';
				PCWrite <= '1';
				IorD <= '0'; 
				MemRead <= '1';
				MemWrite	<= '0';
				MemtoReg <= '0';
				IRWrite <= '1';
			when S1 => -- decode
				PCSource <= "00";
				ALUOp <= "00"; 
				ALUSrcB <= "11";
				ALUSrcA <= '0';
				RegWrite <= '0';
				RegDst <= '0'; 
				PCWriteCond <= '0';
				PCWrite <= '0';
				IorD <= '0'; 
				MemRead <= '0';
				MemWrite	<= '0';
				MemtoReg <= '0';
				IRWrite <= '0';
			when S2 => -- memory address computation
				PCSource <= "00";
				ALUOp <= "00";
				ALUSrcB <= "10";
				ALUSrcA <= '1';
				RegWrite <= '0';
				RegDst <= '0';
				PCWriteCond <= '0';
				PCWrite <= '0';
				IorD <= '0';
				MemRead <= '0';
				MemWrite	<= '0';
				MemtoReg <= '0';
				IRWrite <= '0';
			when S3 => -- memory access - lw
				PCSource <= "00";
				ALUOp <= "00";
				ALUSrcB <= "00";
				ALUSrcA <= '0';
				RegWrite <= '0';
				RegDst <= '0';
				PCWriteCond <= '0';
				PCWrite <= '0';
				IorD <= '1';
				MemRead <= '1';
				MemWrite	<= '0';
				MemtoReg <= '0';
				IRWrite <= '0';
			when S4 => -- memory read completion step
				PCSource <= "00";
				ALUOp <= "00";
				ALUSrcB <= "00";
				ALUSrcA <= '0';
				RegWrite <= '1';
				RegDst <= '0';
				PCWriteCond <= '0';
				PCWrite <= '0';
				IorD <= '0';
				MemRead <= '0';
				MemWrite	<= '0';
				MemtoReg <= '1';
				IRWrite <= '0';
			when S5 => -- memory access - sw
				PCSource <= "00";
				ALUOp <= "00"; 
				ALUSrcB <= "00";
				ALUSrcA <= '0';
				RegWrite <= '0';
				RegDst <= '0';
				PCWriteCond <= '0';
				PCWrite <= '0';
				IorD <= '1';
				MemRead <= '0';
				MemWrite	<= '1';
				MemtoReg <= '0';
				IRWrite <= '0';
			when S6 => -- execution of R-type instructions
				PCSource <= "00";
				ALUOp <= "10";
				ALUSrcB <= "00";
				ALUSrcA <= '1';
				RegWrite <= '0';
				RegDst <= '0';
				PCWriteCond <= '0';
				PCWrite <= '0';
				IorD <= '0';
				MemRead <= '0';
				MemWrite	<= '0';
				MemtoReg <= '0';
				IRWrite <= '0';
			when S7 => -- R-type completion
				PCSource <= "00";
				ALUOp <= "00";
				ALUSrcB <= "00";
				ALUSrcA <= '0';
				RegWrite <= '1';
				RegDst <= '1';
				PCWriteCond <= '0';
				PCWrite <= '0';
				IorD <= '0';
				MemRead <= '0';
				MemWrite	<= '0';
				MemtoReg <= '0';
				IRWrite <= '0';
			when S8 => -- branch completion
				PCSource <= "01";
				ALUOp <= "01";
				ALUSrcB <= "00";
				ALUSrcA <= '1';
				RegWrite <= '0';
				RegDst <= '0';
				PCWriteCond <= '1';
				PCWrite <= '0';
				IorD <= '0';
				MemRead <= '0';
				MemWrite	<= '0';
				MemtoReg <= '0';
				IRWrite <= '0';
			when S9 => -- jump completion
				PCSource <= "10";
				ALUOp <= "00";
				ALUSrcB <= "00";
				ALUSrcA <= '0';
				RegWrite <= '0';
				RegDst <= '0';
				PCWriteCond <= '0';
				PCWrite <= '1';
				IorD <= '0';
				MemRead <= '0';
				MemWrite	<= '0';
				MemtoReg <= '0';
				IRWrite <= '0';
		end case;
	end process combinationalLogic;
	
	sequentialLogic: process(clk) is
	begin
		if rising_edge(clk) then
			if CS = S0 then -- fetch
				CS <= S1;
			elsif CS = S1 then -- decode
				if opcode = "100011" then -- lw
					CS <= S2;
				elsif opcode = "101011" then -- sw
					CS <= S2;
				elsif opcode = "000000" then -- R type instructions
					CS <= S6;
				elsif opcode = "000100" then -- branch
					CS <= S8;
				elsif opcode = "000010" then -- jump
					CS <= S9;
				else
					CS <= S1;
				end if;
			elsif CS = S2 then -- memory address computation
				if opcode = "100011" then -- lw
					CS <= S3;
				elsif opcode = "101011" then -- sw
					CS <= S5;
				else
					CS <= S2;
				end if;	
			elsif CS = S3 then -- memory access for lw
				CS <= S4;
			elsif CS = S4 then -- memory read completion step
				CS <= S0;
			elsif CS = S5 then -- memory access for sw
				CS <= S0;
			elsif CS = S6 then -- ALU execution
				CS <= S7;
			elsif CS = S7 then -- R-type completion
				CS <= S0;
			elsif CS = S8 then -- branch completion
				CS <= S0;
			elsif CS = S9 then -- jump completion
				CS <= S0;
			end if;
		end if;
	end process sequentialLogic;
			  
end arc_ControlUnit;