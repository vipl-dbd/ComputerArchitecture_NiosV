/************************************************************* 
* bypassing.s
*
* Performance evaluation of Nios V soft processors when instruction reordering is employed
*
* Domingo Benitez
* November 2024
*************************************************************/

.equ Niter,1000				/* number of internal iterations for the LOOP zone */

.global BYPASSING
BYPASSING:
	addi	sp, sp, -20		/* stack for 5 registers */

   	sw      ra, 0(sp)
	sw 	  	s2, 4(sp)
	sw 	  	s4, 8(sp)
	sw 	  	s6, 12(sp)
	sw 	  	s7, 16(sp)

	la 		s2, A 	    	/* s2: pointer to A variable */
	la 		s4, N
	lw 		s4, 0(s4)   	/* s4: iteration counter */
	add		s7, zero, zero	/* Niter=0 */

LOOP: 	
	lw 		s6, 0(s2)   	/* load A variable */

/* ZONE: data dependence */
	/*add 	s6, s6, s6 */ 	/* addition WITH data dependence to lw s6, 0(s2) */
	add 	s6, s4, s4  	/* addition WITHOUT data dependence to lw s6, 0(s2) */

/* 2 more ALU instructions, they must not be commented */
	addi 	s7, s7,  1   	/* Niter++ */
	addi 	s4, s4, -1   	/* N-- */

	bne 	s4, zero, LOOP

	la 		s4, ITERACIONES	/* point to memory */
	sw  	s7, 0(s4) 		/* save number of completed iterations in memory */

/* recuperar los registros de la pila y retornar */
	lw  	  ra, 0(sp)
	lw  	  s2, 4(sp)
	lw  	  s4, 8(sp)
	lw  	  s6, 12(sp)
	lw  	  s7, 16(sp)

	addi 	  sp, sp, 20

	ret
 

/* .org 0x5000 */
N: 
.word Niter 				/* number of iterations */
A: 
.word 5 					/* A variable */

/* .org 0x5040 */
ITERACIONES:
.skip 4


.end
