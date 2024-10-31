/* 
Programa: contador.s
*/

.extern CONTADOR_VALOR
.extern CONTADOR_VALOR_BCD

/* Programa llamado cuando el timer interrumpe */
.global CONTADOR
CONTADOR:
	/* guardar registros en la pila */
	addi 	sp, sp, -28
	sw 		ra,  4(sp)
	sw 		t5,  8(sp)
	sw 		t6, 12(sp)
	sw 		t3, 16(sp)
	sw 		tp, 20(sp)
	sw 		s0, 24(sp)
	sw 		a0, 28(sp)

	/* Se incrementa la variable CONTADOR */
	la		t5, CONTADOR_VALOR 	/* dirección base del contador de intervalos del Timer */
	lw 		t3, 0(t5) 
	addi 	t3, t3, 1  			/* suma el contador de intervalos Timer */
	sw 		t3, 0(t5) 

	/* Se guarda el valor del contador en formato BCD */
	/* argumentos: tp= valor binario, s0= valor BCD */
	add		tp, t3, zero
	add		s0, zero, zero
	jal		ra, BCD
	la		t5, CONTADOR_VALOR_BCD 	/* dirección base del contador de intervalos del Timer en formato BCD*/
	sw		s0, 0(t5)

	/*
	la   	a0, TEXTO3
	jal  	ra, PRINT
	*/

	/* recuperar registros de la pila */
	lw 		ra, 4(sp)
	lw 		t5, 8(sp)
	lw 		t6, 12(sp)
	lw 		t3, 16(sp)
	lw 		tp, 20(sp)
	lw 		s0, 24(sp)
	lw 		a0, 28(sp)
	addi 	sp, sp, 28

	ret

.data
TEXTO3:
.asciz "\nSe modifica Contador y Contador_BCD\n"

.end
