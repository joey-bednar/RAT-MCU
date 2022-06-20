# RAT Microcontroller

The RAT MCU is a microcontrollerthat written in VHDL and run on the Basys 3 FPGA development board. The RAT MCU architecture is displayed below. Programs are written in assembly and converted to prog_rom.vhd files via the RAT Assembler. More information is found in the [RAT Assembler Manual](https://github.com/joey-bednar/RAT-MCU/blob/main/FRCD_RAT_Assembler_Manual%20-%203_12.pdf). 

![alt text](https://github.com/joey-bednar/RAT-MCU/blob/main/rat_diagram.jpg?raw=true)

## Test Program

The current asm.txt and corresponding prog_rom.vhd files contain a program that increments the 7-segment display attached to the Basys 3 board. The display will count up until it reaches the maximum value of 49. Pressing a button on the board triggers an interrupt which resets the counter to zero.

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
