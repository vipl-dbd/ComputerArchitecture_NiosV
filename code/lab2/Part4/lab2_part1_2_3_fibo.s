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
	addi 	sp, sp, -20 	/* reserved memory space for stack */
	sw 		s4, 0(sp) 
	sw 		s5, 4(sp)
	sw 		s6, 8(sp)
	sw 		s7, 12(sp)
	sw 		ra, 16(sp)

	/* la   	a0, TEXTO4 */
	/* jal  	ra, PRINT  */		/* se llama a la rutina PRINT */

	add		s4, zero, zero	/* s4 is a counter */
	la		s5, 65536		/* s5 points to X: 1024, 2048, 4096, 8192, 16384, 32768, 65536 */
	la		s6, V			/* s6 points to V vector */
		
LOOP:
	bge		s4, s5, STOP  	/* loop ends when s5 >= s4 */
	add 	s7, s6, s4		/* next memory address is obtained */
	lb 		zero, 0(s7)		/* V vector is accessed but data is not stored in register file */
	addi	s4, s4, 64		/* P, stride, increments the V pointer: 1,2,4,8,16,32,64	*/
	j		LOOP

STOP:	
	lw 		s4, 0(sp)
	lw 		s5, 4(sp)
	lw 		s6, 8(sp)
	lw 		s7, 12(sp)
	lw 		ra, 16(sp)
	addi 	sp, sp, 20 		/* free stack */

	ret

.data

TEXTO4:
	.asciz "Fibonacci "

.align 2

V:
	.skip	65536				/* Reserved memory space for V vector */

.end
