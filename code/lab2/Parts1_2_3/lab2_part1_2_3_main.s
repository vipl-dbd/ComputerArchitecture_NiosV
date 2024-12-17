/* 
Programa: lab2_part1_2_3_main.s

Descripción: benchmark Fibonacci + measure of time using timer

Subrutinas: excepcionTimer.s escribir_jtag.s contador.s DIV.s BCD.s


Domingo Benitez
July 2024
*/

/* Programa principal */
.equ ITERATIONS, 1000000

.text

/* variables globales para el contador de intervalos medidos por el Interval_timer */
.global CONTADOR_VALOR 		/* valor en formato binario */
.global CONTADOR_VALOR_BCD	/* valor en formato BCD */

.global _start
_start:

	/* inicializar puntero de pila: ultima direccion palabra en on-chip memory */
	la   sp, 0x08001FFC

	/* mtvec, se inicializa el reg. CSR Machine Trap-Vector Base-Add. Reg. con el puntero de memoria
	donde empieza la rutina de excepciones; hay que hacerlo porque NiosV/g lo pone a 0x0900 0000 (CAMBIADO!) 
	*/
	/*li 		s2, 0x08000000 */					/* direccion inicial exceptions en on-chip SRAM */
	li 		s2, 0x0 					/* direccion inicial exceptions en SDRAM */
	csrw 	mtvec, s2 

	/* 
	Habilitar interrupciones del procesador Nios-V/m
	Nios II: movi r2, 0b011 -- habilita IRQ0 e IRQ1 en NIOS II 
	Nios II: wrctl ienable, r2 
	Referencias Nios V:
	- Nios® V Processor Reference Manual Updated for Intel® Quartus® Prime Design Suite: 23.1, pp.12
		mie[31:16]/Platform interrupt-enable field | Platform interrupt-enable bit for 16 hardware
		interrupts
	- Platform Designer, DE0_Nano_Basic_Computer.qpf > nios_system.qsys: IRQ-0 (JTAG_UART), IRQ-1 (Interval_timer)

	Nios V, mie: Machine interrupt-enable register
	se activa sensibilidad de Nios-V/m a IRQ-1 Interval_timer, mie[17]=1
	pseudoinstruccion: CSRW csr, rs1 <-- CSRRW x0, csr, rs1
	*/

	la  	s2, 0x00020000  	
	csrw	mie, s2 			  

	/* 
	Activa interrupciones en Nios V/m desde Timer 
	Nios II, wrctl status, r2 
	Referencias:
	- The RISC-V Instruction Set Manual Volume I: Unprivileged ISA, sec. 7.1 CSRRW: Atomic Read/Write CSR 
	- https://stackoverflow.com/questions/59524849/setting-the-mstatus-register-for-risc-v 
	- RISC-V ASSEMBLY LANGUAGE Programmer Manual Part I, https://shakti.org.in/docs/risc-v-asm-manual.pdf
	- Nios® V Processor Reference Manual Updated for Intel® Quartus® Prime Design Suite: 23.1, pp.12
		mstatus | mstatus[3]/Machine Interrupt-Enable (MIE) field | Global interrupt-enable bit for machine mode
	
	Nios V, mstatus: Machine status register, mstatus.MIE=mstatus[3]
	pseudoinstruccion: CSRW csr, rs1 <-- CSRRW x0, csr, rs1 
	bit 3 de reg. control mstatus (mstatus.MIE), activa interrupciones en Nios V/m desde Timer-SoC
	*/
	csrsi 	mstatus, 8		

	/* inicializar Interval_timer del SoC, no del Nios-V/m, puerto base: 0x10002000 */
	la 		s2, 0x10002000		

	/* counter start value: 1/(50 MHz) x (0x3F00000, 0d15728640)= 1321,20 ms, 32 bits, se divide en 2 half-word (16 bits): 0x03F0 (MSB), 0x0000 (LSB) */
	la 		s3, 0x3F00000		

	sh 		s3, 8(s2)			/* se guarda la half-word menos significativa en 0x10002008 */
	srli 	s3, s3, 16			/* se desplaza a la derecha 16 bits */
	sh 		s3, 0xC(s2)			/* se guarda la half-word mas significativa en 0x1000200c */

	/* poner en marcha el Interval_timer del SoC y habilitar que puede emitir interrupciones */
	li 		s3, 0b0111			/* STOP=0, START=1, CONT=1, ITO=1*/
	sh 		s3, 4(s2)

	/* el programa principal muestra un mensaje por la terminal */

	/* PRINT de un mensaje "TEXTO_MAIN" */
	la   	a0, TEXTO_MAIN
	jal  	ra, PRINT

/*********/
	la 		a4, ITERATIONS	 	/* inicializa contador iteraciones LOOP, cada una ejecuta un bucle Fibonacci */
	addi  	s2, zero, 0 		/* inicializa el contador de intervalos del programa "s2" */

LOOP:	
	beq   a4, zero, END 		/* se ejecuta el bucle Fibonacci */

	jal   ra,  FIBONACCI
	addi  a4, a4, -1
	j     LOOP

END:	

	li 		s3, 0b0000			/* Desactiva interrupciones en Timer: STOP=0, START=0, CONT=0, ITO=0*/
	sh 		s3, 4(s2)

	la  	s2, 0x0  	
	csrw	mie, s2 			  

	csrsi 	mstatus, 0		

	la   	a0, TEXTO4
	jal  	ra, PRINT 			/* se llama a la rutina PRINT */

	la   	a0, CONTADOR_VALOR_BCD
	jal  	ra, PRINT_REGISTRO	/* se muestra el número de intervalos de 33 ms en el terminal de AMP */

	la   	a0, TEXTO5
	jal  	ra, PRINT 			/* se llama a la rutina PRINT */

/**********/

IDLE:	
	j 		IDLE

.data

TEXTO_MAIN:
.asciz "\nI am at lab2_part1 with NiosV/m ... running ..."

TEXTO4:
.asciz "\n\nTime: "

TEXTO5:
.asciz " 33-ms intervals\n\nEnd of program\n"

/* IMPORTANTE: el espacio de memoria que ocupa el texto NO ES potencia de 2 y las variables siguientes estarían desalineadas al entorno de palabra; por eso se incluye una directiva de alineación ".aling 2" que alinea a entornos de palabra con direcciones terminadas en: 0,4,8,C; esto fue la solución a que no me funcionaba lw de una constante en memoria CONTADOR_VALOR */

.align 2

CONTADOR_VALOR:
.word 0 		/* posicion de memoria que guarda el contador de intervalos del Timer */
CONTADOR_VALOR_BCD:
.word 0 		/* posicion de memoria que guarda el contador de intervalos del Timer en formato BCD*/

.end
