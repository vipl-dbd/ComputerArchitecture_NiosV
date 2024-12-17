/********************************************************************************
* lab2_part1_2_3_fibo.s
*
* Subrutina: Ejecuta el cómputo de la Serie Fibonacci para 8 números
*
* LLamada desde: lab2_part1_2_3_main.s
*
********************************************************************************/

.text
.global FIBONACCI
FIBONACCI:
	addi 	sp, sp, -32 	/* reserva de espacio para el Stack */
	sw 		s4, 0(sp) 
	sw 		s5, 4(sp)
	sw 		s6, 8(sp)
	sw 		s7, 12(sp)
	sw 		s8, 16(sp)
	sw 		s9, 20(sp)
	sw 		a0, 24(sp)
	sw 		ra, 28(sp)

	/* la   	a0, TEXTO4 */
	/* jal  	ra, PRINT  */		/* se llama a la rutina PRINT */

	la		s4, N			/* r4 apunta N */
	lw		s5, (s4)		/* r5 es el contador inicializado con N */
	addi	s6, s4, 4		/* r6 apunta al primer números Fibonacci */
 	lw		s7, (s6)		/* r7 contiene el primer número Fibonacci */
	addi	s6, s4, 8		/* r6 apunta al primer números Fibonacci */
 	lw		s8, (s6)		/* r7 contiene el segundo número Fibonacci */
	addi	s6, s4, 0x0C	/* r6 apunta al primer número Fibonacci resultado */
	sw		s7, (s6)		/* Guarda el primer número Fibonacci */
	addi	s6, s4, 0x10	/* r6 apunta al segundo número Fibonacci resultado */
	sw		s8, (s6)		/* Guarda el segundo número Fibonacci  */
	addi	s5, s5, -2		/* Decrementa el contador en 2 números ya guardados */
		
LOOP:
	beq		s5, zero, STOP  	/* Termina cuando r5 = 0 */
	addi	s5, s5, -1		/* Decrement the counter */
	addi	s6, s6, 4		/* Increment the list pointer	*/
	add		s9, s7, s8		/* suma dos número precedentes */
	sw		s9, (s6)		/* guarda el resultado */
	addi	s7, s8, 0
	addi	s8, s9, 0
	j		LOOP

STOP:	
	lw 		s4, 0(sp)
	lw 		s5, 4(sp)
	lw 		s6, 8(sp)
	lw 		s7, 12(sp)
	lw 		s8, 16(sp)
	lw 		s9, 20(sp)
	lw 		a0, 24(sp)
	lw 		ra, 28(sp)
	addi 	sp, sp, 32 		/* libera el stack reservado */

	ret

.data

TEXTO4:
	.asciz "Fibonacci "

.align 2

N:
	.word 8					/* Números Fibonacci */
NUMBERS:	
	.word	0, 1			/* Primeros 2 números */
RESULT:
	.skip	32				/* Espacio para 8 números de 4 bytes */

.end
