# Computer Architecture hands-on exercises based on the Nios V soft processors
Hands-on exercises for the Computer Architecture course at the [University of Las Palmas de Gran Canaria (Spain)](https://internacional.ulpgc.es/en/) using Nios V-based soft SoCs and the DE0-Nano board

[Lab 1. RISC-V instruction set architecture and programming of NiosV/m processor](labs/lab1/lab1tutorial.pdf)

[Lab 2. Performance evaluation of the memory hierarchy of a computer and reverse engineering of the data cache memory](labs/lab2/lab2tutorial.pdf)

[Lab 3. Performance evaluation of pipelined processors](labs/lab3/lab3tutorial.pdf)

[Lab 4. Nios V multiprocessor implementation, parallel programming, and performance evaluation](labs/lab4/lab4tutorial.pdf)

[Lab 5. Nios V processor with customized architecture for a software application](labs/lab5/lab5tutorial.pdf)

## Laboratory infrastructure - hardware: <br />
- Terasic DE0-Nano board <br />
- Desktop computer <br />
- USB-A - miniUSB cable <br />

## Laboratory infrastructure - software: <br />
- Windows 10 <br />
- Intel Quartus Prime Standard Edition Design Suite 23.1 <br />

## Folder organization: <br />
[code](code): assembler and C programs <br />
[labs](labs): pdf documents for hands-on exercises <br />
[SoC_configurations](SoC_configurations): binary files to configure the FPGA of a Terasic DE0-Nano board <br />

## Current academic work

2025 winter semester: 171 students enrolled, 7 student groups.

## Lab calendar (30 lab hours, 15 2-hour sessions, 1 lab-session/week)

Lab hours: 30
2-hour sessions: 15
Lab-sesson/week: 1

[Schedule](LabCalendar.md)

<ins>Week 1.</ins> Lab 1: summary, DE0-Nano board, Altera software tools, Nios II instruction set architecture, assembler programming, exercises. Hours: 2 (laboratory) + 2 (homework). Documents: [guide](labs/lab1/lab1tutorial.pdf).

<ins>Week 2.</ins> Lab 1: subroutines, modification of a loaded instruction code, exercises: Fibonacci series, binary multiplication, dot product, binary division. Hours: 2 (laboratory) + 2 (homework). Documents: [guide](labs/lab1/lab1tutorial.pdf).

<ins>Week 3.</ins> Lab 1: test of developed assembly code projects on the DE0-Nano board. Hours: 2 (laboratory) + 2 (homework). Documents: [guide](labs/lab1/lab1tutorial.pdf).

<ins>Week 4.</ins> Lab 1: exam. Hours: 2 (laboratory) + 2 (homework). 

<ins>Week 5.</ins> Lab 2: memory hierarchy and its implementation on the DE0-Nano board. Hours: 2 (laboratory) + 2 (homework). Documents: [guide](labs/lab2/lab2tutorial.pdf).

<ins>Week 6.</ins> Lab 2: cache memory reverse engineering. Hours: 2 (laboratory) + 2 (homework). Documents: [guide](labs/lab2/lab2tutorial.pdf).

<ins>Week 7.</ins> Lab 2: cache memory reverse engineering. Hours: 2 (laboratory) + 2 (homework). Documents: [guide](labs/lab2/lab2tutorial.pdf).

<ins>Week 8.</ins> Lab 2: exam. Hours: 2 (laboratory) + 2 (homework). 

<ins>Week 9.</ins> Lab 3: counting executed instructions and calculating the average CPI (cycles per instruction). Hours: 2 (laboratory) + 2 (homework). Documents: [guide](labs/lab3/lab3tutorial.pdf).

<ins>Week 10.</ins> Lab 3: roofline curves for Nios II/e and Nios II/f  processors. Hours: 2 (laboratory) + 2 (homework). Documents: [guide](labs/lab3/lab3tutorial.pdf).

<ins>Week 11.</ins> Lab 3: performance evaluation of instruction reordering. Hours: 2 (laboratory) + 2 (homework). Documents: [guide](labs/lab3/lab3tutorial.pdf).

<ins>Week 12.</ins> Lab 3: exam. Hours: 2 (laboratory) + 2 (homework). 

<ins>Week 13.</ins> Lab 4: Two tutorials for programming a Nios II/e multiprocessor. Hours: 2 (laboratory) + 2 (homework). 

<ins>Week 14.</ins> Lab 4: Parallel programming of the matrix-vector algorithm and performance evaluation on two Nios V multiprocessors. Hours: 2 (laboratory) + 2 (homework). 

<ins>Week 15.</ins> Lab 4: Parallel programming of the matrix-matrix algorithm and performance evaluation on two Nios V multiprocessors. Hours: 2 (laboratory) + 2 (homework). 

## Topics

Labs are based on principles presented in 30 one-hour lectures during the semester in parallel with the lab sessions. The main topics covered are: methodology for performance evaluation of RISC computers, microarchitecture of pipelined processors and its efficient programming, performance evaluation of cache memories, design and performance evaluation of main memory, static scheduling of instructions, out-of-order instruction execution, microarchitecture and evaluation of superscalar processors, VLIW architectures and microarchitectures, high-performance parallel computing using shared memory multi-core architectures, GPUs, multicomputers and application specific instruction set processors.

## Skills gained by students in this Computer Architecture course

Practical experience on Computer Architecture using real FPGA-based hardware, assembly language programming using a RISC-based instruction set and several bare-metal computer systems, multi-thread programming, code optimization using information from the computer architecture, performance evaluation of processors and multiprocessors, performance evaluation of memory hierarchy including main memory and caches, programming, performance evaluation and customization of the microarchitecture of a general-purpose processor integrated into a System-on-Chip (SoC) or subsystem (SS).

## Professional opportunities that demand these skills across industries

Performance Architect (workload analysis, understand bottlenecks in cores and SoCs), CPU Core Microarchitecture/RTL Engineer (RTL design for sections of the processor pipeline, define the high-level architecture), Platform Hardware and Systems Engineer (development of hardware and systems), System and Solution Architect ((micro)architecture simulation, workloads characterization, C++/Python/Perl programming), GPU Platform Hardware Design Engineer (RTL coding, and simulation for graphics IPs), Platform Solutions Architect (translate requirements and key performance indicators into platform architecture encompassing hardware, software, SoCs, and other components designed to support a variety of systems, solutions, and applications), Platform Validation Engineer (develop verification plans for coherency/ memory/ power management/ security/ domains of pre-silicon SoC/SS), Security Research Engineer (design and implementation of scientific research projects for secure computing, cryptographic algorithms, communication, memory and networking), Silicon Architecture Engineer (logic & circuit design, physical design, validation and debug).

## Nios II

Another [repository](https://github.com/vipl-dbd/ComputerArchitecture_NiosII) includes similar hands-on exercises using the Nios II soft processor that have been used in the training of more than 1,000 computer science undergraduate students for more than 10 years.

## Citation
Benitez, D. (2024). 
Hands-on experience for undergraduate Computer Architecture courses using Nios V-based soft SoCs and real board. 
2024 First Annual Soft RISC-V Systems Workshop.
https://github.com/vipl-dbd/ComputerArchitecture_NiosV/blob/main/benitezSRvSnov24paper.pdf

