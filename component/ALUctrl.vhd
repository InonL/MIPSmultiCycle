library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALUctrl is port(
	ALUOp	:in std_logic_vector(1 downto 0); -- 2 bit from control FSM
	funct	:in std_logic_vector(5 downto 0); -- lower 6 bits of instruction - specifies ALU operation for R-type
	output	:out std_logic_vector(3 downto 0) := "0000"-- 4 bit output into ALU
	);
end ALUctrl;

architecture arc_ALUctrl of ALUctrl is 
begin
	-- logic functions of each output bit
	output(3) <= '0';
	output(2) <= ALUOp(0) OR (ALUOp(1) AND funct(1));
	output(1) <= ALUOp(1) NAND funct(2);
	output(0) <= ALUOp(1) AND (funct(3) OR funct(0));
		
end arc_ALUctrl;