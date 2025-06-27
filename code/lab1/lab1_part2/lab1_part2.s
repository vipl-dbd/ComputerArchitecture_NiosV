/********************************************************************************
 * lab1part2.s
 *
 * Example of RISC-V program for NIOS-V/m soft processor
 * Domingo Benitez
 * date: December 2024
********************************************************************************/
	.text					/* executable code follows */
	
	.global	_start
_start:

	/* initialize base addresses of parallel ports */
	la		x15, RESULT		/* x15: point to the start of data section */
	lw		x16, 4(x15)		/* x16: counter, initialized with n */
	addi	x17, x15, 8		/* x17: point to the first number */
	lw		x18, (x17)		/* x18: largest number found */

LOOP:
	addi 	x16, x16, -1	/* Decrement the counter */
	beq 	x16, zero, DONE	/* Finished if r5 is equal to 0 */
	addi 	x17, x17, 4		/* Increment the list pointer */
	lw 		x19, (x17)		/* Get the next number */
	bge 	x18, x19, LOOP	/* Check if larger number found */
	add 	x18, x19, zero	/* Update the largest number found */
	j 		LOOP

DONE:
	sw 		x18, (x15)		/* Store the largest number into RESULT */

STOP:
	j 		STOP			/* Remain here if done */

.data						/* software variables follow */
	
RESULT:
.skip 4						/* Space for the largest number found */

N:
.word 7						/* Number of entries in the list */

NUMBERS:
.word 4, 5, 3, 6, 1, 8, 2	/* Numbers in the list */

.end