/********************************************************************************
* Program: escribir_jtag.s
*
* Sends strings through the JTAG inteerface.
*
* Domingo Benitez
* November 2024
********************************************************************************/

/* Programa principal */
.text

/* ESCRIBIR_JTAG
   Subrutina que escribe el caracter en la terminal 
   s10 (input) = caracter a procesar 
 */
.global ESCRIBIR_JTAG
ESCRIBIR_JTAG:
	/* los registros usados se guardan en la pila */
	addi sp, sp, -24
	sw   s3,   4(sp)
	sw   s4,   8(sp)
	sw   s5,  12(sp)
	sw   s2,  16(sp)
	sw   s10, 20(sp)
	sw   t0,  24(sp)
	
	/* Puerto JTAG-UART */
	la   s2, 0x10001000		/* direccion base de controlador puerto JTAG_UART */
	
	/* comprobar si hay espacio para escribir */
	/* andhi r3, r3, 0xffff -- se seleccionan los 16 bits más significativos */
	la   t0, 0xFFFF0000

LEE_DATA:	
	/* leer el registro de control del puerto JTAG-UART, dirección: 4(s2) */
	lw   s3, 4(s2)				
	and  s3, s3, t0

	beq s3, zero, LEE_DATA 		/* reg. control [16..31]: ¿WSPACE=0? SI: salta a LEE_DATA, NO: escribe dato en FIFO */
	/*beq s3, zero, FIN */ 		/* reg. control [16..31]: ¿WSPACE=0? */
	
	/* modificar mayúsculas en minúsculas */
	li   s4, 65
	li   s5, 91
	blt  s10, s4, NOMAY 		/* ASCII<65d -> la letra no es mayúscula; salta a NOMAY */
	bge  s10, s5, NOMAY 		/* ASCII>90d -> la letra no es mayúscula; salta a NOMAY */
	/* si llega aquí -> la letra SI es mayúscula; sumando 0x20 se convierte en mayúscula */
	addi s10, s10, 0x20 
	j    WRT

	/* modificar minúsculas en mayúsculas */
NOMAY:	
	li   s4, 97 
	li   s5, 123
	blt  s10, s4, WRT 		/* ASCII<97d -> la letra no es minuscula ni mayuscula; salta a WRT */
	bge  s10, s5, WRT 		/* ASCII>122d -> la letra no es minuscula ni mayuscula; salta a WRT */
	/* si llega aqui -> la letra SI es minuscula; restando 0x20 se convierte en minuscula */
	addi s10, s10, -0x20

	/* enviar al Terminal el caracter escribiendo en controlador JTAG-UART */
WRT:	
	sw   s10, 0(s2)

	/* recuperar los registros de la pila y retornar */
FIN:	
	lw   s3,   4(sp)
	lw   s4,   8(sp)
	lw   s5,  12(sp)
	lw   s2,  16(sp)
	lw   s10, 20(sp)
	lw   t0,  24(sp)
	addi sp, sp, 24
	ret

/* PRINT
   subrutina: PRINT(a0 = direccion_TEXTO)
   a0 (input)
   muestra mensaje almacenado a partir de dirección "direccion_TEXTO"
*/
.global PRINT							
PRINT:									
	addi 	sp, sp, -16
	sw 		s10,  4(sp)
	sw 		ra,   8(sp)
	sw 		t2,  12(sp)
	sw 		t3,  16(sp)

	mv   	t2, a0				/* se copia la dirección del primer byte de la cadena texto */

BUCLE_PRINT:
	lb   	s10, 0(t2) 			/* carga 1 bytes desde dirección de la cadena de caracteres */
	beq  	s10, zero, SALIDA_PRINT	/* si lee un 0, significa que ha llegado al final de la cadena y sale bucle*/
	jal  	ra, ESCRIBIR_JTAG 	/* subrutina que muestra el byte por JTAG-UART */
	addi 	t2, t2, 1 			/* dirección del siguiente byte del PRINT */
	j    	BUCLE_PRINT			/* cierra el bucle */
SALIDA_PRINT:
	lw 		s10,  4(sp)
	lw 		ra,   8(sp)
	lw 		t2,  12(sp)
	lw 		t3,  16(sp)
	addi 	sp, sp, 16
	ret 						/* salida rutina PRINT */


/* PRINT_REGISTRO (a0 = direccion cuyo valor se muestra)
   a0 (input): dirección
   Subrutina: carga una palabra de memoria en formato BCD y lo muestra mensaje por JTAG en una terminal 
*/

.global PRINT_REGISTRO				
PRINT_REGISTRO:						
	addi 	sp, sp, -20
	sw 		s10,  4(sp)
	sw 		ra,   8(sp)
	sw 		t2,  12(sp)
	sw 		t3,  16(sp)
	sw 		t4,  20(sp)

	lw   	t2, 0(a0)				/* se carga en registro t2 el valor binario a convertir en BCD */

	addi   	t3, zero, 8				/* contador de 8 nibles BCD */
	addi   	t4, zero, 10			/* valor=10 para saber si el caracter es número o letra */
	

BUCLE_PRINT_REGISTRO:
	beq  	t3,  zero, SALIDA_PRINT_REGISTRO	/* si llega 0, significa que ha llegado al final de la cadena */
	srli	s10, t2,  28			/* desplaza el valor 28b dcha para seleccionar el nible más significativo */
	andi 	s10, s10, 0xF 			/* extrae el nible más significativo del registro t2, ahora menos sig. de s10 */

	bge 	s10, t4, LETRA
	addi  	s10, s10, 0x30			/* suma 0x30: BCD (0..9) -> ASCII */ 
	j 		OUTPUT
LETRA:
	addi  	s10, s10, 0x37			/* suma 0x37: BCD (A..F) -> ASCII */ 

OUTPUT:	
	jal  	ra,  ESCRIBIR_JTAG 		/* subrutina que muestra el byte por JTAG-UART */
	addi   	t3,  t3,  -1			/* contador de nible -- */
	slli   	t2,  t2,   4			/* siguiente nible BCD */
	j    	BUCLE_PRINT_REGISTRO	/* cierra el bucle */


SALIDA_PRINT_REGISTRO:
	lw 		s10,  4(sp)
	lw 		ra,   8(sp)
	lw 		t2,  12(sp)
	lw 		t3,  16(sp)
	lw 		t4,  20(sp)
	addi 	sp, sp, 20
	ret 							/* salida rutina PRINT */


/* PRINT_REGISTRO_BINARIO (a0 = direccion cuyo valor guardado en formato binaria se muestra en BCD)
   a0 (input): dirección
   Subrutina: carga una palabra de memoria en BINARIO y lo muestra por JTAG en una terminal en formato BCD 
*/
.global PRINT_REGISTRO_BINARIO				
PRINT_REGISTRO_BINARIO:
	addi 		sp, sp, -20
	sw 		t5,  4(sp)
	sw 		ra,   8(sp)
	sw 		tp,  12(sp)
	sw 		s0,  16(sp)
	sw 		a0,  20(sp)

	lw		t5, 0(a0) 					/* (a0) = valor binario */
	add	tp, t5, zero				/* tp <-- t5: valor binario (iterations) */
	add	s0, zero, zero				/* s0: valor BCD de salida */
	jal	ra, BCD						/* inputs: s0, tp */
	la		t5, dummyPrint 			/* dirección base del contador de intervalos del Timer en formato BCD*/
	sw		s0, 0(t5)					/* BCD value saved */
	add 	a0, t5, zero 				/* a0 <-- t5: dir. de Niteraciones */
	jal  	ra, PRINT_REGISTRO		/* se muestra la medida de num iteraciones en terminal */

	lw 		t5,   4(sp)
	lw 		ra,   8(sp)
	lw 		tp,  12(sp)
	lw 		s0,  16(sp)
	lw 		a0,  20(sp)
	addi 		sp,  sp, 20

	ret

/* PRINT_REGISTRO_LONG (a0 = dirección inicial donde se encuentra una palabra de 64 bits)
   a0 (input): dirección
   Subrutina: carga una doble-palabra de memoria en formato BCD y lo muestra mensaje por JTAG en una terminal 
*/

.global PRINT_REGISTRO_LONG				
PRINT_REGISTRO_LONG:
	addi 		sp, sp, -8
	sw 		t5,  4(sp)
	sw 		ra,  8(sp)

	add 		a0, t5, 4 					/* a0 <-- t5+4: dir. de CONTADOR_VALOR_BCD_LONG+4 		*/
	jal  		ra, PRINT_REGISTRO		/* se muestra la medida de prestaciones en terminal 	*/
	add 		a0, t5, zero 				/* a0 <-- t5: dir. de CONTADOR_VALOR_BCD_LONG+0 		*/
	jal  		ra, PRINT_REGISTRO		/* se muestra la medida de prestaciones en terminal 	*/

	lw 		t5,  4(sp)
	lw 		ra,  8(sp)
	addi 		sp,  sp, 8

	ret

/* .data */
dummyPrint:
.word 0


.end 
