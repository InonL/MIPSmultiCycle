library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity InstructionReg is port(
	inputIns	:in std_logic_vector(31 downto 0); -- input instruction
	IRWrite	:in std_logic; -- write enable
	opcodeOut	:out std_logic_vector(5 downto 0) := "000000"; -- Opcode output into control unit
	rsOut, rtOut	:out std_logic_vector(4 downto 0) := "00000"; -- rs and rt output
	instructionOut	:out std_logic_vector(15 downto 0) := X"0000"-- instruction out
	);
end InstructionReg;

architecture arc_InstructionReg of InstructionReg is 
begin
	process (inputIns) is
	begin
		if IRWrite = '1' then -- write to instructionReg on rising edge
			-- concatenate input into desired outputs
			opcodeOut <= inputIns(31 downto 26); 
			rsOut <= inputIns(25 downto 21);
			rtOut <= inputIns(20 downto 16);
			instructionOut <= inputIns(15 downto 0);
		end if;
	end process;
end arc_InstructionReg;