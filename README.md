# MIPSmultiCycle
A MIPS multi-cycle implementation in VHDL.

This implementation supports the following instructions:
  * Memory-related: lw, sw
  * R-type: add, sub, and, or, slt
  * Branch (beq) and Jump (j)

The internal components are in the component directory, and testbenches for the more complex and substantial components (including one for the complete processor) are located in the testbench directory.

To keep things simple, The memory length is 16 words for instructions, and 16 words for data.
The instruction memory and data memory are contained in the same array, inside the same component.
Increasing / decreasing the memory size is possible by changing the RAM logic inside the memoryUnit file.

Overflow of the PC from the instruction memory to the data memory is prevented using a simple if statement in the PC component.

### Modifying the instruction sequence
Currently, the instruction sequence loaded into memory is pretty nonsensical in order to keep the testing process simple. If you wish to change the instruction sequence to something more sensible, **you can do so by changing lines 25-40 in the memoryUnit file.** 

### Disclaimer
This project is not intended for commercial use in any way, and as such, should not be held to the same standards. The code written in this project was not tested in real time and was not programmed onto an FPGA for use, Therefore there is no guarantee it will actually perform as planned in practice. The code was written in my free time, in order to learn the fundamentals of VHDL.
