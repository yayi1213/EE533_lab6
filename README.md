# EE533 Lab 6: ARM CPU Implementation

## Project Description

This project implements a pipelined ARM CPU in Verilog for EE533 Lab 6. The CPU supports basic ARM instructions and includes a testbench to verify functionality.

## Files

- `ARM_CPU_done.v`: Completed ARM CPU module with pipelined architecture (ID, EX, MEM, WB stages) and external memory interface.
- `ARM_CPU_MT4.v`: Multi-threaded version of the ARM CPU (4 threads).
- `tb_Lab06_1.v`: Testbench for the ARM CPU, including memory initialization, register setup, and simulation monitoring.
- `README.md`: This file.

## Simulation Instructions

### Using Icarus Verilog (iverilog)

1. Compile the design and testbench:
   ```
   iverilog -o arm_cpu_tb ARM_CPU_done.v tb_Lab06_1.v
   ```

2. Run the simulation:
   ```
   vvp arm_cpu_tb
   ```

3. View waveforms (if using GTKWave):
   ```
   gtkwave wave.vcd
   ```

### Using ModelSim

1. Create a new project or use the command line.

2. Compile the Verilog files:
   ```
   vlog ARM_CPU_done.v tb_Lab06_1.v
   ```

3. Run the simulation:
   ```
   vsim -c tb_ARM_CPU -do "run -all; quit"
   ```

4. For GUI mode:
   ```
   vsim tb_ARM_CPU
   ```

## Requirements

- Verilog simulator (Icarus Verilog, ModelSim, etc.)

## Notes

- The testbench initializes instruction memory with machine code, data memory with sample data, and monitors register and memory changes.
- The CPU implements ARM instruction set with conditional execution.
- External memory interface allows for larger memory spaces.