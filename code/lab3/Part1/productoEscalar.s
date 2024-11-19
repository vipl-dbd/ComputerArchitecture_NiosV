/********************************************************************************
* file: productoEscalar.s, Arquitectura de Computadores, EII 
*
* Dot product for two vectors.
* RISC-V assemble instructions.
* Subroutine: MULTIPLICA
*
* Domingo Benitez, November 2024
*/

/* subroutine: MULTIPLICA */

MULTIPLICA:
/* Binary multiplication algorithm for Nios V */
/* s6: multiplicand, s7: multiplicator, result: s8 */

/* Stack */
	sw 		ra, 0(sp)
	addi 	sp, sp, -4
	sw 		s5, 0(sp)
	addi 	sp, sp, -4
	sw 		s4, 0(sp)
	addi 	sp, sp, -4
	sw 		s9, 0(sp)
	addi 	sp, sp, -4

/* Preamble */
	addi 	s5, zero, 0x1 	/* mask */
	addi 	s4, zero, 32  	/* bit counter */
	addi 	s8, zero, 0   	/* multiplication result */

loopMUL:
	and 	s9, s7, s5   	/* get least significat bit for the multiplicator  */
	beq 	s9, zero, salida 
	add 	s8, s8, s6
salida:
	addi 	s4, s4, -1   		/* Decrement the counter */
	slli 	s6, s6, 1   		/* shift multiplicand to the left */
	beq 	s6, zero, vuelve 	/* exit */
	srli 	s7, s7, 1   		/* shift multiplicator to the right */
	beq 	s7, zero, vuelve 	/* exit */
	/* Nios II: bgt 	s4, zero, loopMUL 	 Loop again if not finished */
	blt 	zero, s4, loopMUL 	/* Loop again if not finished */

vuelve:
/* Restore registers from stack and retun from subroutine */
	addi 	sp, sp, 4
	lw 		s9, 0(sp)
	addi 	sp, sp, 4
	lw 		s4, 0(sp)
	addi 	sp, sp, 4
	lw 		s5, 0(sp)
	addi 	sp, sp, 4
	lw 		ra, 0(sp)

	ret

/* subrutina: PRODUCTO_ESCALAR */

.global PRODUCTO_ESCALAR
PRODUCTO_ESCALAR:

/* Stack */
	addi  sp, sp, -32	/* 8 registers --> stack, 32 addresses */
	sw 	  s2, 4(sp)
	sw 	  s3, 8(sp)
	sw 	  s4, 12(sp)
	sw 	  s5, 16(sp)
	sw 	  s6, 20(sp)
	sw 	  s7, 24(sp)
	sw 	  s8, 28(sp)
	sw 	  ra, 32(sp)

/* Preamble */
	la 	s2, AVECTOR 	/* s2: pointer to vector A */
	la 	s3, BVECTOR 	/* s3: pointer to vector B */
	la 	s4, N
	lw 	s4, 0(s4)   	/* s4: iteration counter */
	add s5, zero, zero  /* s5: accumulator for the product */

/* LOOP begin */
LOOP: 	
	lw 	s6, 0(s2)   	/* load one element of vector A */
	lw 	s7, 0(s3)   	/* load one element of vector B */

	jal	ra, MULTIPLICA 	/* call multiplication for NIOS V/m */

	add 	s5, s5, s8 	 /* add to acumulator */
	addi 	s2, s2, 4  	 /* increment pointer to vector A */
	addi 	s3, s3, 4  	 /* increment pointer to vector B */
	addi 	s4, s4, -1   /* decrement iteration counter */
	blt   zero, s4, LOOP /* branch to LOOP */
/* LOOP end */

/* Prolog */
	la 		s4, DOT_PRODUCT
	sw  	s5, 0(s4) 	/* save result in memory */

FIN:	
/* recover register states and return to main program */
	lw  	  s2, 4(sp)
	lw  	  s3, 8(sp)
	lw  	  s4, 12(sp)
	lw  	  s5, 16(sp)
	lw  	  s6, 20(sp)
	lw  	  s7, 24(sp)
	lw  	  s8, 28(sp)
	lw  	  ra, 32(sp)

	addi 	  sp, sp, 32

	ret
 
/*.org 0x5000 */
/*.data*/
N: 
/* .word 6  Specify the number of elements */
.word 6 /* Specify the number of elements */
AVECTOR: 
.word 5, 3, -6, 19, 8, 12 /* Specify the elements of vector A */
BVECTOR: 
.word 2, 14,-3, 2, -5, 36 /* Specify the elements of vector B */
DOT_PRODUCT:
.word 0


.end

