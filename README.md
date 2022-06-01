# RAT Microcontroller

The RAT MCU is a basic computer that written in VHDL and run on the Basys 3 FPGA development board. Programs are written in assembly and converted to prog_rom.vhd files via the RAT Assembler. The MCU Architecture is displayed below.

![alt text](https://github.com/joey-bednar/RAT-MCU/blob/main/rat_diagram.jpg?raw=true)

## File Descriptions

alu.vhd: Arithmetic Logic Unit used to perform operations on binary numbers.

asm.txt: Assembly file that contains the program to be run.

basys.xdc: Constraints file to interface with Basys 3 development board.

clk_div2_buf.vhd: Clock divider to allow for a fast clock and a slow clock signal.

Counter.vhd: Can count up, reset to zero, or be set to a specific number.

cu.vhd: Control unit (FSM)

flags.vhd: Implements the flags in the MCU

mcu.vhd: Connects all modules together

pc.vhd: Program counter that keeps track of which instruction is next.

prog_rom.vhd: The compiled assembly code is converted to a VHDL file containin all instructions in bit format.

RegisterFile.vhd: Dual port RAM

sim.vhd: Simulation of MCU signals

sp.vhd: Stack pointer

s_ram: Scratch RAM 256x10

timer_counter.vhd: Separate from MCU, only used for this specific program

wrapper.vhd: Container for the entire RAT MCU
