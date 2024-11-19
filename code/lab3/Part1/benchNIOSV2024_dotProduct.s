/************************************************************* 
* benchNIOSV2024_dotProduct.s (ver 1.0)
*
* Benchmark for Lab Asignment 3 - Part 1
* Multiple iterations of the same dot product of a vector
*
* subrutines: PRODUCTO_ESCALAR, ESCRIBIR_JTAG, activaTimer, desactivaTimer, PRINT_JTAG 
*
* files: DIV.s, escribir_jtag.s, productoEscalar.s, BCD.s
*
* Domingo Benitez, November 2024
*
*************************************************************/
.equ ITER_BENCH,5000 		/* number of kernel iterations */

.global _start
_start:
	li  	t0, 97			/* code for ASCII letter 'a' */
	la 		t1, 0x10001000	/* JTAG data register*/
	la   	sp, 0x08001FFC	/* pointer to stack */

/* PRINT init message "TEXTOentrada" */
verTEXTO: 
	la   	a0, TEXTOentrada
	jal  	ra, PRINT

/* wait for a pressed key */
LOOP:	
	lw 		t2, 0(t1)			/* read data register JTAG port */
	la 		t3, 0x8000
	and  	t3, t2, t3			/* select bit 15: RVALID */
	beq   	t3, zero, LOOP		/* RVALID=0 -> no pressed key */
	andi  	a0, t2, 0xFF		/* extract bits 0..7: DATA, s10: input for ESCRIBIR_JTAG subroutine */

	add 	s10,a0, zero		/* s10 (input for ESCRIBIR_JTAG subroutine) */
	jal		ra,	ESCRIBIR_JTAG	/* show the pressed key on the screen */
	bne   	a0, t0, verTEXTO 	/* if pressed key is not ‘a’ --> goto verTEXTO */

	la 		a0, TEXTO_nueva_linea /* print TEXTO_nueva_linea */
	jal		ra,	PRINT 			/* a0 (input address) */

/* init values for the benchmark */
	la 		t5, tiempoTotal_acumulado
	sw  	zero, 0(t5) 		/* tiempoTotal_acumulado variable: total execution time needed by benchmark */

/* configure and start the Timer  */
	jal  	ra, activaTimer						

/* initial value of total execution time for the benchmark */
	jal  	ra, LEER_TIMER_SNAPSHOT 	/* time snapshot to begin counting clock cycles */
	la 		t5, TIEMPO					/* TIEMPO local variable saves the value provided by the snapshot */
	lw   	t6, 0(t5)
	la 		t5, tiempoTotal_antes 		/* pointer to tiempoTotal_antes variable: tiempoTotal_antes <- TIEMPO */
	sw   	t6, 0(t5) 					/* tiempoTotal_antes local variable is saved */

/* this loop iterates the kernel several times */
	add		s5, zero, zero				/* iteration counter: i */
	li 		s4, ITER_BENCH 				/* maximum number of iterations  */
	la 		s6, NiterRealizadas 		/* addres memory for saving the number of performed iterations */

secuencia: 

/* rutina kernel */
	jal  	ra,	PRODUCTO_ESCALAR		/* kernel de computo */

	addi 	s5, s5, 1					/* i++ */
	bne  	s5, s4, secuencia  			/* end of loop, s4=ITER_BENCH */

	sw  	s5, 0(s6)					/* i is saved in memory */	

/* marca final de tiempo total de una ejecución del benchmark */
	jal  	ra,	LEER_TIMER_SNAPSHOT 	/* accede al Timer para leer el numero de ciclos actuales */
	la 		t5, TIEMPO					/* variable : TIEMPO guarda la lectura de ciclos del Timer */
	lw   	t6, 0(t5)
	la 		t5, tiempoTotal_despues 	/* variable t_2: tiempoTotal_despues <- TIEMPO */
	sw   	t6, 0(t5)
	la 		t5, tiempoTotal_antes
	lw     	t4, 0(t5)
	sub  	t6, t4, t6					/* tiempoTotal_despues = tiempoTotal_antes - tiempoTotal_despues, el cambio de signo de los operandos es porque Timer empieza a contar desde FFFFFFFF y luego se va reduciendo y sub los considera valores negativos */
	la 		t5, tiempoTotal_acumulado
	sw  	t6, 0(t5) 					/* variable t_T, t6: tiempoTotal_despues = t_2 - t_1 */

/* salida de la prueba del benchmark */
	jal  	ra,	desactivaTimer			/* paramos el Timer */

/* BCD */
/* Se guarda el valor del contador en formato BCD */
/* argumentos: tp (input)= valor binario, s0 (output)= valor BCD */
	add		tp, t6, zero				/* tp <-- t6: valor binario (tiempoTotal_despues) */
	add		s0, zero, zero				/* s0: valor BCD LSB */
	add		s1, zero, zero				/* s1: valor BCD MSB */
	jal		ra, BCD_LONG
	la		t5, CONTADOR_VALOR_BCD_LONG	/* dirección base del contador de intervalos del Timer en formato 											BCD_LONG 8-byte*/
	sw		s0, 0(t5)
	sw		s1, 4(t5)

/* print valor BCD LONG 64-bit, input (dirección inicial variable long 64-bit) = a0 */
	add 	a0, t5, zero 				/* a0 <-- t5: dir. de CONTADOR_VALOR_BCD_LONG+0 */
	jal  	ra,	PRINT_REGISTRO_LONG		/* se muestra la medida de prestaciones en terminal */

/* print iterations */
	la 		a0, TEXTO_num_iter
	jal		ra,	PRINT

/* print número iteraciones realizadas */
	la 		a0, NiterRealizadas 
	jal  	ra,	PRINT_REGISTRO_BINARIO

/* print counters */
/*
	la 		a0, TEXTO_counter
	jal		ra,	PRINT

	la 		a0, tiempoTotal_antes 
	jal  	ra,	PRINT_REGISTRO_BINARIO

	la 		a0, TEXTO_counter
	jal		ra,	PRINT

	la 		a0, tiempoTotal_despues 
	jal  	ra,	PRINT_REGISTRO_BINARIO
*/

/* print BYE */
	la 		a0, BYE
	jal		ra,	PRINT

FIN:
	j 		FIN							/* fin de la prueba */


/* -----------------------------------------------------------
* subrutina: activaTimer
*
* Configura el Interval_timer de SoC para que cuente pulsos de reloj
*
* Parametros entrada: ninguno
*
* Parametros salida:  ninguno
*  ------------------------------------------------------------*/

activaTimer:
	addi  	sp, sp, -16			/* guardamos registros en pila */
	sw   	ra, 16(sp)
	sw 		t0, 12(sp)
	sw  	t1,  8(sp)
	sw  	t3,  4(sp)

/* configuracion del Timer */
	la 		t3, 0x10002000 		/* direccion base del Timer */
	la 		t0, 0xffffffff 		/* inicializa el Interval_timer con la mayor cuenta ya que se configura para hacer snapshots */
	sh 		t0, 8(t3) 			/* inicializa la media palabra menos significativa del valor inicial del Timer */
	srli  	t0, t0, 16
	sh 		t0, 0xC(t3) 		/* inicializa la media palabra mas significativa del valor inicial del Timer */

	/* li  	t1, 0b0110 */ 			/* START = 1, CONT = 1, ITO = 0 */
	li  	t1, 0b0100 			/* START = 1, CONT = 0, ITO = 0 */
	sh 		t1, 4(t3)			/* configuracion del Timer sin interrupciones */

	lw  	t0, 12(sp)			/* restauramos registros desde pila */
	lw  	t1,  8(sp)
	lw  	t3,  4(sp)
	lw      ra, 16(sp)
	addi  	sp, sp, 16		

	ret

/* -----------------------------------------------------------
* subrutina: desactivaTimer
*
* Desconfigura el Timer de DE2 
*
* Parametros entrada: ninguno
*
* Parametros salida:  ninguno
*  --------------------------------------------------------------*/

desactivaTimer:
	addi 	sp, sp, -12			/* registros en pila */
	sw  	t1,  4(sp)
	sw  	ra,  8(sp)
	sw  	t3, 12(sp)

	
	la 		t3, 0x10002000 		/* direccion base del Timer  */
	sh 		zero, 4(t3)			/* START = 0, CONT = 0, ITO = 0 */

	lw  	t1,  4(sp)
	lw   	ra,  8(sp)
	lw  	t3, 12(sp)
	addi  	sp, sp, 12			/* restauramos registros desde pila */

	ret

/* -----------------------------------------------------------
* rutina: LEER_TIMER_SNAPSHOT
*
* Lee el registro de ciclos del Timer haciendo snapshot.
*
* Parametros entrada: ninguno
*
* Parametros de salida: TIEMPO, variable global
*
*  ------------------------------------------------------------*/

.global LEER_TIMER_SNAPSHOT
LEER_TIMER_SNAPSHOT:
	addi 	sp, sp, -16 		/* guardamos registros en pila */
	sw  	t0,  4(sp)
	sw      t3,  8(sp)
	sw  	t1, 12(sp)
	sw  	ra, 16(sp)

	la   	t3, 0x10002000 		/* direccion base del Timer  */
	sw  	zero, 16(t3) 		/* snapshot del Timer: hacemos una foto del contador de ciclos  */
	lw  	t1, 16(t3)			/* 16 bits menos significativos de la cuenta */
	lw  	t0, 20(t3)			/* 16 bits mas significativos de la cuenta */
	slli   	t0, t0, 16			/* desplaza a izquierda los mas significativos para alinear */
	or    	t0, t0, t1			/* se componen los 32 bits de la cuenta */
	la      t3, TIEMPO	
	sw    	t0, 0(t3)			/* se guarda la cuenta en variable TIEMPO */

	lw   	t0,  4(sp)
	lw      t3,  8(sp)
	lw   	t1, 12(sp)			/* restauramos registros desde pila */
	lw   	ra, 16(sp)
	addi  	sp, sp, 16 	

	ret

/* -----------------------------------------------------------
*  Zona de datos
*  -------------------------------------------------------- */	
/*.data*/
.align 2

.global TIEMPO
TIEMPO:
.word 0 						/* variable para guardar el valor actual del contador de pulsos del Timer */

.align 2
.global tiempoTotal_antes
tiempoTotal_antes:
.word 0

.align 2
.global tiempoTotal_despues
tiempoTotal_despues:
.word 0

.align 2
.global tiempoTotal_acumulado
tiempoTotal_acumulado:
.word 0

.align 2
.global CONTADOR_VALOR_BCD
CONTADOR_VALOR_BCD:
.skip 4 						/* posicion memoria que guarda contador de intervalos del Timer en formato BCD 4-byte */

.align 2
.global CONTADOR_VALOR_BCD_LONG
CONTADOR_VALOR_BCD_LONG:
.skip 8 						/* posicion memoria que guarda contador de intervalos del Timer en formato BCD_LONG 8-byte*/

.align 2
.global NiterRealizadas
NiterRealizadas:
.word 0 		/* numero iteraciones del bucle donde el CODEC estas saturado */

.align 2
TEXTOentrada:
.asciz "\nPress key a to start the benchmark: "

.align 2
TEXTO_nueva_linea:
.asciz "\n... running ...\n Cycle counter (clk@50MHz): "

.align 2
TEXTO_num_iter:
.asciz "\n Number of iterations done: "

.align 2
TEXTO_counter:
.asciz "\nContador: "

.align 2
BYE:
.asciz "\nBYE! \n"

.end
