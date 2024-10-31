# makefile
# Provide a *.elf file with RISC-V ISA for soft processors Nios V/m or Nios V/g using assembler source code
# $ "make help" for showing options
#
# Domingo Benitez
# November 2024
#
PROCESSOR= 	NiosVg # options: NiosVm, NiosVg
MAIN_MEM=	SDRAM  # options: SDRAM, SRAM

ROOT	= 	lab2_part1_2_3_main
SRC		=	$(ROOT).s
OBJ 	=	$(SRC).obj
OBJfiles= 	$(OBJ) excepcionTimer.s.obj escribir_jtag.s.obj contador.s.obj DIV.s.obj BCD.s.obj lab2_part1_2_3_fibo.s.obj
EXE		=	$(ROOT).elf
HEX 	= 	$(ROOT).hex
AS		= 	riscv32-unknown-elf-as.exe 
LD		= 	riscv32-unknown-elf-ld.exe 
RP		= 	niosv-stack-report 
DUMP	= 	riscv32-unknown-elf-objdump 
COPY	=	riscv32-unknown-elf-objcopy
STACK	= 	--defsym __alt_stack_pointer=0x08001F00 	\
			--defsym __alt_stack_base=0x08002000
HEAP	= 	--defsym __alt_heap_limit=0x8002000 		\
			--defsym __alt_heap_start=0x8002000

ifeq ($(MAIN_MEM),SDRAM)
# LINKfile for implementing Main Memory using SDRAM
LINKfile=	linker_SDRAM.x 
else
# LINKfile for implementing Main Memory using on-chip SRAM memory
LINKfile=	linker_SRAM.x 
endif

F_LD 	=	-g -T $(LINKfile) -nostdlib -e _start 		\
			-u _start $(STACK) $(HEAP) $(SYMBOLS)

all 		: 	## Compile and link the main programa and subroutines.
all 		: 	$(OBJfiles)
	$(LD) $(F_LD) -o $(EXE) $(OBJfiles) 
	$(RP) -p riscv32-unknown-elf- $(EXE)
	$(DUMP) -Sdtx $(EXE) > $(EXE).objdump
	$(COPY) -O binary $(EXE) $(HEX)

$(OBJ)		: $(SRC)
	$(AS) $(SRC) -alsg -o $(OBJ) > $(SRC).log

excepcionTimer.s.obj : excepcionTimer.s
	$(AS) excepcionTimer.s -alsg -o excepcionTimer.s.obj > excepcionTimer.s.log

escribir_jtag.s.obj : escribir_jtag.s
	$(AS) escribir_jtag.s -alsg -o escribir_jtag.s.obj > escribir_jtag.s.log

contador.s.obj : contador.s
	$(AS) contador.s -alsg -o contador.s.obj > contador.s.log

DIV.s.obj 	: DIV.s
	$(AS) DIV.s -alsg -o DIV.s.obj > DIV.s.log

BCD.s.obj 	: BCD.s
	$(AS) BCD.s -alsg -o BCD.s.obj > BCD.s.log

lab2_part1_2_3_fibo.s.obj 	: lab2_part1_2_3_fibo.s
	$(AS) lab2_part1_2_3_fibo.s -alsg -o lab2_part1_2_3_fibo.s.obj > lab2_part1_2_3_fibo.s.log

download	:       ## Initialice program into main memory: SDRAM or on-chip SRAM of DE0-Nano board
	niosv-download.exe -r -g $(EXE)

configure	:       ## Configure FPGA of DE0-Nano.
ifeq ($(PROCESSOR),NiosVm)
# configuration for Nios V/m on DE0-Nano board
	quartus_pgm -c 1 -m JTAG -o "p;C:/altera/12.1sp1/University_Program/NiosII_Computer_Systems/DE0-Nano/DE0-Nano_Basic_Computer_NiosVm_conSDRAM/verilog/DE0_Nano_Basic_Computer_22jul24.sof@1"
else
# configuration for Nios V/g on DE0-Nano board
	quartus_pgm -c 1 -m JTAG -o "p;C:/altera/12.1sp1/University_Program/NiosII_Computer_Systems/DE0-Nano/DE0-Nano_Basic_Computer_NiosVg_conSDRAM/verilog/DE0_Nano_Basic_Computer_23jul24.sof@1"
endif

clean		:       ## Clean obj, objdump, log and hex files.
	rm $(EXE) *.obj *.objdump *.log *.hex

help		:       ## Shows this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'