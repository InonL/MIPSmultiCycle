library ieee;                                
use ieee.std_logic_1164.all;                 
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity MIPSmultiCycle is port(
	clock	:in std_logic; -- clock input
	State :out std_logic_vector(3 downto 0); -- state output
	-- outputs for testing in tb:
	writtenRegBus	:out std_logic_vector(4 downto 0); -- the register that was written at the end of lw/R-type instruction
	writtenRegDataBus	:out std_logic_vector(31 downto 0); -- the data written at said register
	writtenWordBus	:out std_logic_vector(31 downto 0); -- the memory word that was written at the end of lw/R-type instruction
	writtenWordDataBus	:out std_logic_vector(31 downto 0); -- the data written at said register
	PCoutputBus	:out std_logic_vector(31 downto 0) := X"00000000" -- current PC, for branch/ jump validation
	);
end entity MIPSmultiCycle;

architecture arc_MIPSmultiCycle of MIPSmultiCycle is

-- Component Declarations
-------------------------

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
	
	component memoryUnit port(
		clk		:in std_logic;
		addr :in std_logic_vector(31 downto 0);
		writeData :in std_logic_vector(31 downto 0);
		memR, memW	:in std_logic;
		memData :out std_logic_vector(31 downto 0);
		writtenWord	:out std_logic_vector(31 downto 0)
		);
	end component;
	
	component ALU port(
		A,B	:in std_logic_vector(31 downto 0);
		control	:in std_logic_vector(2 downto 0);
		result	:out std_logic_vector(31 downto 0);
		zero	:out std_logic
		);
	end component;
	
	component BOR port(
		readReg1, readReg2	:in std_logic_vector(4 downto 0);
		writeReg	:in std_logic_vector(4 downto 0);
		writeData :in std_logic_vector(31 downto 0);
		regWrite	:in std_logic;
		readData1, readData2 :out std_logic_vector(31 downto 0);
		writtenReg	:out std_logic_vector(31 downto 0)
		);
	end component;
	
	component InstructionReg port(
		inputIns	:in std_logic_vector(31 downto 0);
		IRWrite	:in std_logic;
		opcodeOut	:out std_logic_vector(5 downto 0);
		rsOut, rtOut	:out std_logic_vector(4 downto 0);
		instructionOut	:out std_logic_vector(15 downto 0)
		);
	end component;
	
	component PC port(
		clk	:in std_logic;
		PC_in	:in std_logic_vector(31 downto 0);
		writePC	:in std_logic;
		PC_out	:out std_logic_vector(31 downto 0)
		);
	end component;
	
	component ALUctrl port(
		ALUOp	:in std_logic_vector(1 downto 0);
		funct	:in std_logic_vector(5 downto 0);
		output	:out std_logic_vector(3 downto 0)
		);
	end component;
	
	component Mux4to1_32 port(
		Din0, Din1, Din2, Din3	:in  std_logic_vector(31 downto 0);
		Sel	:in  std_logic_vector(1 downto 0);
		Dout	:out std_logic_vector(31 downto 0)
		);
	end component;
	
	component Mux3to1_32 port(
		Din0, Din1, Din2	:in  std_logic_vector(31 downto 0);
		Sel	:in  std_logic_vector(1 downto 0);
		Dout	:out std_logic_vector(31 downto 0)
		);
	end component;
		
	component Mux2to1_32 port(
		Din0, Din1	:in  std_logic_vector(31 downto 0);
		Sel	:in  std_logic;
		Dout	:out std_logic_vector(31 downto 0)
		);
	end component;
	
	component Mux2to1_5 port(
		Din0, Din1	:in  std_logic_vector(4 downto 0);
		Sel	:in  std_logic;
		Dout	:out std_logic_vector(4 downto 0)
		);
	end component;
	
	component register_32 port(
		clk	:in std_logic;
		input	:in std_logic_vector(31 downto 0); 
		output	:out std_logic_vector(31 downto 0)
		);
	end component;
	
	component signExtend_16to32 port(
		input_16	:in std_logic_vector(15 downto 0);
		output_32	:out std_logic_vector(31 downto 0)
		);
	end component;
	
	component shiftLeft2_jump port(
		input_26	:in std_logic_vector(25 downto 0);
		output_28	:out std_logic_vector(27 downto 0)
		);
	end component;
	
	component shiftLeft2_beq port(
		input	:in std_logic_vector(31 downto 0);
		output	:out std_logic_vector(31 downto 0)
		);
	end component;
	
-- End
---------------------

-- Internal Signals
---------------------

	signal PCinput_sig: std_logic_vector(31 downto 0);
	signal PCWriteCond_sig: std_logic;
	signal PCWrite_sig: std_logic;
	signal PCControl_sig: std_logic;
	signal PCoutput_sig: std_logic_vector(31 downto 0);
	signal ALUOut_sig: std_logic_vector(31 downto 0);
	signal IorD_sig: std_logic;
	signal Address_sig: std_logic_vector(31 downto 0);
	signal memRead_sig: std_logic;
	signal memwrite_sig: std_logic;
	signal memData_sig: std_logic_vector(31 downto 0);
	signal IRWrite_sig: std_logic;
	signal opcode_sig: std_logic_vector(5 downto 0);
	signal rs_sig: std_logic_vector(4 downto 0);
	signal rt_sig: std_logic_vector(4 downto 0);
	signal instr_sig: std_logic_vector(15 downto 0);
	signal MDR_sig: std_logic_vector(31 downto 0);
	signal regDst_sig: std_logic;
	signal rd_sig: std_logic_vector(4 downto 0);
	signal memToReg_sig: std_logic;
	signal regWriteData_sig: std_logic_vector(31 downto 0);
	signal regWrite_sig: std_logic;
	signal rsData_sig: std_logic_vector(31 downto 0);
	signal rtData_sig: std_logic_vector(31 downto 0);
	signal signExtend_sig: std_logic_vector(31 downto 0);
	signal AReg_sig: std_logic_vector(31 downto 0);
	signal BReg_sig: std_logic_vector(31 downto 0);
	constant four_32bits: std_logic_vector(31 downto 0) := X"00000004";
	signal shiftLeft2Beq_sig: std_logic_vector(31 downto 0);
	signal ALUSrcA_sig: std_logic;
	signal ALUSrcB_sig: std_logic_vector(1 downto 0);
	signal ALUA_sig: std_logic_vector(31 downto 0);
	signal ALUB_sig: std_logic_vector(31 downto 0);
	signal ALUOp_sig: std_logic_vector(1 downto 0);
	signal ALUControloutput_sig: std_logic_vector(3 downto 0);
	signal shiftLeft2Jump_in: std_logic_vector(25 downto 0);
	signal shiftLeft2Jump_sig: std_logic_vector(27 downto 0);
	signal zero_sig: std_logic;
	signal ALUResult_sig: std_logic_vector(31 downto 0);
	signal PCSource_sig: std_logic_vector(1 downto 0);
	signal PCinD2_sig: std_logic_vector(31 downto 0);

-- End
---------------------
	
begin

-- Component Instances
----------------------
	
	Control : ControlUnit
	port map(
		-- inputs
		clk	=> clock,
		opcode	=> opcode_sig, -- from IR
		
		-- outputs
		PCSource	=> PCSource_sig, -- connects to PCinMUX
		ALUOp => ALUOp_sig, -- connects to ALUctrl
		ALUSrcB	=> ALUSrcB_sig, -- connects to ALUBMUX
		ALUSrcA	=> ALUSrcA_sig, -- connects to ALUAMUX
		RegWrite	=> regWrite_sig, -- connects to BOR
		RegDst	=> regDst_sig, -- connects to regDstMUX
		PCWriteCond	=> PCWriteCond_sig,
		PCWrite	=> PCWrite_sig, -- connects to PC
		IorD	=> IorD_sig, -- to IorDMUX
		MemRead	=> memRead_sig, -- to memory
		MemWrite	=> memwrite_sig, -- to memory
		MemtoReg	=> memToReg_sig, -- to memToRegMUX
		IRWrite => IRWrite_sig, -- to IR
		Y => State -- to output for testing
	);
	
	ALUnit : ALU
	port map(
		-- inputs
		A	=> ALUA_sig, -- from ALUAMUX
		B	=> ALUB_sig, -- from ALUBMUX
		control	=> ALUControloutput_sig(2 downto 0), -- from ALUctrl
		-- outputs
		result	=> ALUResult_sig, -- to ALUOut register
		zero	=> zero_sig
	);
	
	memoryUnitInst : memoryUnit 
	port map(
		-- inputs
		clk => clock,
		addr => Address_sig, -- from IorDMUX
		writeData => BReg_sig, -- from B register
		memR => memRead_sig, -- from control unit
		memW => memWrite_sig, -- from control unit
		-- outputs
		memData => memData_sig, -- to IR and MDR
		writtenWord => writtenWordDataBus -- to output for testing
	);
	
	Registers : BOR
	port map(
		-- inputs
		readReg1 => rs_sig, -- from IR
		readReg2	=> rt_sig, -- from IR
		writeReg	=> rd_sig, -- from regDstMUX
		writeData	=> regWriteData_sig, -- from memToRegMUX
		regWrite	=> regWrite_sig, -- from control unit
		-- outputs
		readData1	=> rsData_sig, -- to A register
		readData2	=> rtData_sig, -- to B register
		writtenReg => writtenRegDataBus -- to output for testing
	);
	
	IR : InstructionReg
	port map(
		-- inputs
		inputIns	=> memData_sig, -- from instruction memory
		IRWrite	=> IRWrite_sig, -- from control unit
		-- outputs
		opcodeOut => opcode_sig, -- to control unit
		rsOut	=> rs_sig, -- to BOR
		rtOut	=> rt_sig, -- to BOR
		instructionOut	=> instr_sig -- to regDstMUX, shiftLeft2_jump, signExtend, and ALUctrl
	);
	
	PCInst : PC 
	port map(
		-- inputs
		clk => clock,
		PC_in => PCinput_sig, -- from PCinMUX
		writePC => PCControl_sig, -- from control unit
		-- output
		PC_out => PCoutput_sig -- to IorDMUX
	);
	
	ALUControl : ALUctrl
	port map(
		-- inputs
		ALUOp	=> ALUOp_sig, -- from control unit
		funct	=> instr_sig(5 downto 0), -- from IR
		-- output
		output	=> ALUControloutput_sig -- to ALU
	);
	
	ALUAMUX : Mux2to1_32
	port map(
		-- inputs
		Din0	=> PCoutput_sig, -- from PC
		Din1	=> AReg_sig, -- from A register
		Sel	=> ALUSrcA_sig, -- from control unit
		-- output
		Dout	=> ALUA_sig -- to ALU
	);
	
	ALUBMUX : Mux4to1_32
	port map(
		-- inputs
		Din0	=> BReg_sig, -- from B register
		Din1	=> four_32bits, -- constant 4
		Din2	=> signExtend_sig, -- from signExtend
		Din3	=> shiftLeft2Beq_sig, -- from shiftLeft2_beq
		Sel	=> ALUSrcB_sig, -- from control unit
		-- output
		Dout	=> ALUB_sig -- to ALU
	);
	
	IorDMUX : Mux2to1_32
	port map(
		-- inputs
		Din0	=> PCoutput_sig, -- from PC
		Din1 => ALUOut_sig, -- from ALUOut register
		Sel => IorD_sig, -- from control unit
		-- output
		Dout => Address_sig -- to memory
	);
	
	memToRegMUX : Mux2to1_32
	port map(
		-- inputs
		Din0	=> ALUOut_sig, -- from ALUOut register
		Din1 => MDR_sig, -- from MDR
		Sel => memToReg_sig, -- from control unit
		-- output
		Dout => regWriteData_sig -- to BOR
	);
	
	regDstMUX : Mux2to1_5
	port map(
		-- inputs
		Din0	=> rt_sig, -- from IR
		Din1 => instr_sig(15 downto 11), -- from IR
		Sel => regDst_sig, -- from control unit
		-- output
		Dout => rd_sig -- to BOR
	);
	
	PCinMUX : Mux3to1_32
	port map(
		-- inputs
		Din0	=> ALUResult_sig, -- from ALU
		Din1	=> ALUOut_sig, -- from ALUOut register
		Din2	=> PCinD2_sig, -- from shiftLeft2_jump
		Sel	=> PCSource_sig, -- from control unit
		-- output
		Dout	=> PCinput_sig -- to PC
	);
	
	MDR : register_32
	port map(
		-- inputs
		clk	=> clock,
		input	=> memData_sig, -- from memory
		-- output
		output	=> MDR_sig -- to memToRegMUX
	);
	
	AReg : register_32
	port map(
		-- inputs
		clk	=> clock,
		input	=> rsData_sig, -- from BOR
		-- output
		output	=> AReg_sig -- to ALUAMUX
	);
	
	BReg : register_32
	port map(
		-- inputs
		clk	=> clock,
		input	=> rtData_sig, -- from BOR
		-- output
		output	=> BReg_sig -- to ALUBMUX
	);
	
	ALUOutReg : register_32
	port map(
		-- inputs
		clk	=> clock,
		input	=> ALUResult_sig, -- from ALU
		-- output
		output	=> ALUOut_sig -- to PCinMUX, memToRegMUX, and IorDMUX
	);
	
	signExtend : signExtend_16to32
	port map(
		input_16	=> instr_sig, -- from IR
		output_32	=> signExtend_sig -- to ALUBMUX and shiftLeft2_beq
	);
	
	shiftLeft2Jump : shiftLeft2_jump
	port map(
		input_26	=> shiftLeft2Jump_in, -- from IR
		output_28	=> shiftLeft2Jump_sig -- to PCinMUX
	);
	
	shiftLeft2Beq : shiftLeft2_beq
	port map(
		input	=> signExtend_sig, -- from signExtend
		output => shiftLeft2Beq_sig -- to ALUBMUX
	);
	
	PCControl_sig <= (zero_sig AND PCWriteCond_sig) OR (PCWrite_sig); -- PC write logic
	shiftLeft2Jump_in <= rs_sig & rt_sig & instr_sig; -- making shiftLeft2Jump input from rs, rt, and instruction fields
	PCinD2_sig <= PCoutput_sig(31 downto 28) & shiftLeft2Jump_sig; -- making PCinMUX D2 from 4 msb's of PCout, and the result of shiftLeft2Jump
	PCoutputBus <= PCoutput_sig; -- connecting PC output to external bus for testing in tb
	writtenRegBus <= rd_sig; -- written Reg output for tb
	writtenWordBus <= Address_sig; -- written word output for tb
	
end arc_MIPSmultiCycle;
