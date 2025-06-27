# makefile
# For lab 1 Part II
# Example of RISC-V program for NIOS-V/m soft processor
# December 2024

ROOT	= 	lab1_part2
SRC		=	$(ROOT).s
OBJ 	=	$(SRC).obj
OBJfiles= 	$(OBJ) 
EXE		=	$(ROOT).elf
HEX 	= 	$(ROOT).hex
AS		= 	riscv32-unknown-elf-as.exe 
LD		= 	riscv32-unknown-elf-ld.exe 
RP		= 	niosv-stack-report.exe
DUMP	= 	riscv32-unknown-elf-objdump.exe 
COPY	=	riscv32-unknown-elf-objcopy.exe
STACK	= 	--defsym __alt_stack_pointer=0x08001F00 	\
			--defsym __alt_stack_base=0x08002000
HEAP	= 	--defsym __alt_heap_limit=0x8002000 		\
			--defsym __alt_heap_start=0x8002000 
F_LD 	=	-g -T ../practica1_bsp/linker.x -nostdlib -e _start 		\
			-u _start $(STACK) $(HEAP)

all 		: 	## Compile and link main program and subroutines.
all 		: 	$(OBJfiles)
	$(LD) $(F_LD) -o $(EXE) $(OBJfiles) 
	$(RP) -p riscv32-unknown-elf- $(EXE)
	$(DUMP) -Sdtx $(EXE) > $(EXE).objdump
	$(COPY) -O binary $(EXE) $(HEX)

$(OBJ)		: $(SRC)
	$(AS) $(SRC) -alsg -o $(OBJ) > $(SRC).log

download	:       ## Download the *.elf file into the main memory of the soft computer configured in the DE0-Nano board
	niosv-download.exe -r -g $(EXE)

configure	:       ## Configure the FPGA of the DE0-Nano board.
	quartus_pgm.exe -c 1 -m JTAG -o "p;../../../../DE0_Nano_Basic_Computer.sof@1"
	# quartus_pgm.exe -c 1 -m JTAG -o "p;C:/altera/12.1sp1/University_Program/NiosII_Computer_Systems/DE0-Nano/DE0-Nano_Basic_Computer_NiosVg/verilog/DE0_Nano_Basic_Computer.sof@1"

clean		:       ## Clean compilation files.
	rm $(EXE) *.obj *.objdump *.log *.hex

help		:       ## Shows this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'