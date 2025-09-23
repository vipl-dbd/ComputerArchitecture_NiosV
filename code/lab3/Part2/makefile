#
# makefile
# compile and link of the *.elf file using RISC-V ISA for the Nios V soft processor
# Domingo Benitez
# June 2024
#

ROOT	= 	benchNIOSV2024_roofline
SRC		=	$(ROOT).s
OBJ 	=	$(SRC).obj
OBJfiles= 	$(OBJ) roofline.s.obj escribir_jtag.s.obj DIV.s.obj BCD.s.obj
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
F_LD 	=	-g -T ../practica1_bsp/linker.x -nostdlib -e _start 		\
			-u _start $(STACK) $(HEAP)

all 		: 	## Compila y linka el programa principal y subrutinas.
all 		: 	$(OBJfiles)
	$(LD) $(F_LD) -o $(EXE) $(OBJfiles) 
	$(RP) -p riscv32-unknown-elf- $(EXE)
	$(DUMP) -Sdtx $(EXE) > $(EXE).objdump
	$(COPY) -O binary $(EXE) $(HEX)

$(OBJ)		: $(SRC)
	$(AS) $(SRC) -alsg -o $(OBJ) > $(SRC).log

escribir_jtag.s.obj : escribir_jtag.s
	$(AS) escribir_jtag.s -alsg -o escribir_jtag.s.obj > escribir_jtag.s.log

roofline.s.obj : roofline.s
	$(AS) roofline.s -alsg -o roofline.s.obj > roofline.s.log

DIV.s.obj 	: DIV.s
	$(AS) DIV.s -alsg -o DIV.s.obj > DIV.s.log

BCD.s.obj 	: BCD.s
	$(AS) BCD.s -alsg -o BCD.s.obj > BCD.s.log

download	:       ## Inicializa el programa en memoria de la FPGA de la placa DE0-Nano.
	niosv-download.exe -r -g $(EXE)

configure	:       ## Configura la placa DE0-Nano.
	quartus_pgm -c 1 -m JTAG -o "p;../../../../DE0_Nano_Basic_Computer.sof@1"
#	quartus_pgm -c 1 -m JTAG -o "p;C:/altera/12.1sp1/University_Program/NiosII_Computer_Systems/DE0-Nano/DE0-Nano_Basic_Computer_NiosVg/verilog/DE0_Nano_Basic_Computer.sof@1"

clean		:       ## Borra varios ficheros de compilacion.
	rm $(EXE) *.obj *.objdump *.log *.hex

help		:       ## Muestra este help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'