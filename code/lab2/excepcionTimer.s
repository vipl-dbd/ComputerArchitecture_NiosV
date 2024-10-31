/* 
Programa: excepcionTimer.s

Descripción: rutine de manejo de interrupciones para el controlador timer con Nios-V/m

Subrutinas: excepcionTimer.s escribir_jtag.s contador.s DIV.s BCD.s

Referencia: Basic Computer System for the Altera DE0-Nano Board

OLD: Práctica 2 Ejercicio 7, Estructura de Computadores, EII, fichero: excepciones.s 

Domingo Benítez
Julio 2024 
*/

/* 
Sección Exceptions: es ubicada en la zona especificada para ello por la descripción de la CPU 
Mediante "ax" se indica que la sección es "allocatable" y "executable" 
*/

.section .exceptions, "ax"

/* variables globales declaradas en el programa principal mainTimer.s */
.extern CONTADOR_VALOR
.extern CONTADOR_VALOR_BCD

.global _manejador_interrupciones
_manejador_interrupciones:

	/* los registros usados se guardan en la pila */
	addi sp, sp, -24
	sw   s2,   4(sp)
	sw   s3,   8(sp)
	sw   a0,  12(sp)
	sw   t3,  16(sp)
	sw   ra,  20(sp)
	sw   t5,  24(sp)

	/* 
	cargar interrupciones pendientes, 
	Nios II: ctl4=ipending, reg. control bit 4: rdctl et, ctl4

	Referencias:
	- Nios® V Processor Reference Manual Updated for Intel® Quartus® Prime Design Suite: 23.1, pp.12,21,24
	- The RISC-V Instruction Set Manual Volume I: Unprivileged ISA, sec. 7.1 CSRRW: Atomic Read/Write CSR 
	- RISC-V ASSEMBLY LANGUAGE Programmer Manual Part I, pp.27, reg MIE

	Nios V: mip[31:16]/Platform interrupt-pending field | Platform interrupt-pending bit for 16 hardware interrupts

	se lee Machine interrupt pending (mip), reg. control; usamos reg. temporal: t3
	*/
	csrr 	t3, mip 

	/* Interval_timer del SoC */
	la 		s2, 0x10002000		/* puerto base del Timer del SoC */

	/*li 		s3, 0b1001*/	/* STOP=0, START=0, CONT=0, ITO=0*/
	/*li 		s3, 0b0001*/	/* STOP=0, START=0, CONT=0, ITO=0*/
	/*sh 		s3, 4(s2)*/		/* se inicializa el bit-0 del registro "status" del Interval_timer del SoC */

	li 		s3, 0b0				/* se resetea el Interval_timer del SoC: TO=0 */
	sh 		s3, 0(s2)			/* se inicializa el bit-0 del registro "status" del Interval_timer del SoC */


	/*la  	s2, 0x00000000*/  	/* se desactiva sensibilidad de Nios-V/m a IRQ-1 Interval_timer, mie[17]=0 */
	/*csrw	mie, s2 */			/* mie: Machine interrupt-enable register */ 
	/*csrw 	mstatus, s2	*/		/* bit 3 de reg. control mstatus (mstatus.MIE), activa interrupciones en Nios V/m desde Timer */


	/* comprobar la interrupción del Interval_timer del SoC (interrupción prioritaria) */
	la 		t5, 0x00020000 		/* mascara en bit 17, IRQ-1 pending */
	and 	s2, t3, t5 			/* extrae bit 17 de reg.control MIP, Machine Int.Pending */

	beq 	s2, zero, FIN		/* salta a FIN si no detecta IRQ del Interval_timer del SoC */

	/* PRINT de un mensaje "TEXTO" */
	/*
	la   	a0, TEXTO
	jal  	ra, PRINT
	*/
	
	/* PRINT de un mensaje "TEXTO2" si detecta interrupción */
	/*
	la   	a0, TEXTO2
	jal  	ra, PRINT
	*/

	/* se llama a subrutina CONTADOR para aumentar en 1 las variables externas */
	jal  	ra, CONTADOR

	/* se llama a la rutina PRINT */
	/*la   	a0, TEXTO4
	jal  	ra, PRINT*/

	/* se llama a la rutina PRINT_REGISTRO */
	/*la   	a0, CONTADOR_VALOR_BCD
	jal  	ra, PRINT_REGISTRO*/

	/* se llama a la rutina PRINT */
	/*la   	a0, TEXTO5
	jal  	ra, PRINT*/

	/* poner en marcha el timer y habilitar que puede emitir interrupciones */
	/*li 		s3, 0b0111	*/	/* STOP=0, START=0, CONT=0, ITO=0*/
	/*sh 		s3, 4(s2)	*/
	/*li 		s3, 0b0111	*/	/* STOP=0, START=0, CONT=0, ITO=0*/
	/*sh 		s3, 4(s2) 	*/
	/*j 		FIN*/

FIN:
	lw   s2,   4(sp)
	lw   s3,   8(sp)
	lw   a0,  12(sp)
	lw   t3,  16(sp)
	lw   ra,  20(sp)
	lw   t5,  24(sp)
	addi sp, sp, 24

	/* Original Nios-II: eret, retorno de rutina de excepciones */
	/*jr		t4*/			/* retorno a  la dir. con instruccion que se interrumpio */
	mret

.data

TEXTO:
.asciz "\nEstoy en el Timer-rutinaExcepciones\n"
TEXTO2:
.asciz "\nHe detectado que se ha activado la IRQ del Timer-SoC\n"
TEXTO4:
.asciz "rutinaExcepciones Valor BCD: "
TEXTO5:
.asciz "\n\n"

.end
