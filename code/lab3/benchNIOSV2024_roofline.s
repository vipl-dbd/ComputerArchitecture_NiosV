/************************************************************* 
* benchNIOSV2024_roofline.s (ver 1.0)
*
* Programa para obtener la curva de limitaciones de prestaciones ALU:
* operacionesALU/segundo versus operacionesALU/byte.
*
* subrutinas: ROOFLINE, ESCRIBIR_JTAG, activaTimer, desactivaTimer, PRINT_JTAG 
*
* ficheros: DIV.s, escribir_jtag.s, roofline.s, BCD.s
*
* OLD: AC - Practica 3
*
* Domingo Benitez, Julio 2024
*
*************************************************************/
.global _start
_start:
	li  	t0, 97			/* codigo ASCII letra 'a' */
	la 		t1, 0x10001000	/* JTAG data register*/
	la   	sp, 0x01FFFFFC	/* inicio de pila */

/* PRINT de un mensaje "TEXTOentrada" */
verTEXTO: 
	la   	a0, TEXTOentrada
	jal  	ra, PRINT

/* esperar por tecla pulsada en el teclado */
LOOP:	
	lw 		t2, 0(t1)		/* lee data register puerto JTAG */
	la 		t3, 0x8000
	and  	t3,  t2, t3		/* extrae el bit 15: RVALID */
	beq   	t3,  zero, LOOP	/* RVALID=0 -> no dato pulsado */
	andi  	a0, t2, 0xFF	/* extrae bits 0..7: DATA, s10: input de ESCRIBIR_JTAG */
	add 	s10, a0, zero
	jal		ra,	ESCRIBIR_JTAG
	bne   	a0, t0, verTEXTO /* si no es la ‘a’ sigue encuestando JTAG */

	la 		a0, TEXTO_nueva_linea
	jal		ra,	PRINT

/* zona de inicializaciones del benchmark */
	la 		t5, tiempoTotal_acumulado
	sw  	zero, 0(t5) 	/* variable t_T: tiempo de ejecución total del benchmark */

/* configura Timer y pone en marcha */
	jal  	ra, activaTimer						

/* marca inicial de tiempo total de ejecución del benchmark */
	jal  	ra, LEER_TIMER_SNAPSHOT 	/* se toma una marca inicial para luego calcular el tiempo total */
	la 		t5, TIEMPO					/* TIEMPO guarda la lectura actual del Timer de los ciclos */
	lw   	t6, 0(t5)
	la 		t5, tiempoTotal_antes 		/* variable t_1: tiempoTotal_antes <- TIEMPO */
	sw   	t6, 0(t5) 					/* se guarda marca de tiempo variable t_1 */

/* rutina kernel */
	jal  	ra,	ROOFLINE				/* kernel de computo */

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
	add		s0, zero, zero				/* s0: valor BCD */
	jal		ra, BCD
	la		t5, CONTADOR_VALOR_BCD 		/* dirección base del contador de intervalos del Timer en formato BCD*/
	sw		s0, 0(t5)

/* print valor BCD, dirección = a0 */
	add 	a0, t5, zero 				/* a0 <-- t5: dir. de CONTADOR_VALOR_BCD */
	jal  	ra,	PRINT_REGISTRO			/* se muestra la medida de prestaciones en terminal */

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
	la 		t0, 0xffffffff 		/* inicializa el Interval_imer con la mayor cuenta ya que se configura para hacer snapshots */
	sh 		t0, 8(t3) 			/* inicializa la media palabra menos significativa del valor inicial del Timer */
	srli  	t0, t0, 16
	sh 		t0, 0xC(t3) 		/* inicializa la media palabra mas significativa del valor inicial del Timer */

	li  	t1, 0b0110 			/* START = 1, CONT = 1, ITO = 0 */
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
	sw  	t3, 12(sp)
	sw  	ra,  8(sp)

	
	la 		t3, 0x10002000 		/* direccion base del Timer  */
	sh 		zero, 4(t3)			/* START = 0, CONT = 0, ITO = 0 */

	lw  	t1,  4(sp)
	lw  	t3, 12(sp)
	lw   	ra,  8(sp)
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
	sw  	t1, 12(sp)
	sw      t3,  8(sp)
	sw  	ra, 16(sp)

	la   	t3, 0x10002000 		/* direccion base del Timer  */
	sw  	zero, 16(t3) 		/* snapshot del Timer: hacemos una foto del contador de ciclos  */
	lw  	t1, 16(t3)			/* 16 bits menos significativos de la cuenta */
	lw  	t0, 20(t3)			/* 16 bits mas significativos de la cuenta */
	slli   	t0, t0, 16			/* desplaza a izquierda los mas significativos para alinear */
	or    	t0, t0, t1			/* se componen los 32 bits de la cuenta */
	la      t3, TIEMPO	
	sw    	t0, 0(t3)			/* se guarda la cuenta en variable TIEMPO */

	lw   	t1, 12(sp)			/* restauramos registros desde pila */
	lw   	t0,  4(sp)
	lw      t3,  8(sp)
	lw   	ra, 16(sp)
	addi  	sp, sp, 16 	

	ret

/* -----------------------------------------------------------
*  Zona de datos
*  -------------------------------------------------------- */	
.data
.align 2

.global TIEMPO
TIEMPO:
.word 4 						/* variable para guardar el valor actual del contador de pulsos del Timer */

.global tiempoTotal_antes
tiempoTotal_antes:
.word 8

.global tiempoTotal_despues
tiempoTotal_despues:
.word 12

.global tiempoTotal_acumulado
tiempoTotal_acumulado:
.word 16

.global CONTADOR_VALOR_BCD
CONTADOR_VALOR_BCD:
.word 0 						/* posicion de memoria que guarda el contador de intervalos del Timer en formato BCD*/

.align 2
TEXTOentrada:
.ascii "\n   "
.asciz "\nAprieta la tecla a para empezar el benchmark en Nios V/m: "

TEXTO_nueva_linea:
.ascii "\n\nContador (clk@50MHz):"


.end
