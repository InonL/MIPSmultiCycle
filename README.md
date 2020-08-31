# MIPSmultiCycle
A MIPS multi-cycle implementation (out of many) in VHDL.

This implementation supports only the following instructions:
  * Memory-related: lw, sw
  * R-type: add, sub, and, or, slt
  * Branch (beq) and Jump (j)

The internal components are in the component directory, and testbenches for the more complex and substantial components (including one for the complete processor) are located in the testbench directory.

The instruction memory and data memory are contained in the same array, inside the same component. Overflow of the PC from the instruction memory to the data memory is prevented using a simple if statement in the PC component.

### On modifying the instruction sequence
Currently, the instruction sequence loaded into the memory is pretty nonsensical in order to keep the testing process simple. If you wish to change the instruction sequence to something more sensible, **you can do so by changing lines 25-40 in the memoryUnit file.** 

Take care, however, that the testbench for the complete processor is very basic and highly specific, and will almost definitely **not work** properly if you choose to change the instruction sequence.
