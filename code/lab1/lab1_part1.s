/********************************************************************************
 * This program demonstrates use of parallel ports in the DE0-Nano Basic Computer
 *
 * It performs the following: 
 * 	1. displays a rotating pattern on the green LEDG
 * 	2. if KEY[1] is pressed, uses the SW switches as the pattern

 * Adapted to Nios V
 * by Domingo Benitez
 * date: May 2024
********************************************************************************/
	.text		/* executable code follows */
	.global	_start
_start:

	/* initialize base addresses of parallel ports */
	la	x16, 0x10000010		/* green LED base address */
	la	x15, 0x10000040		/* SW slider switch base address */
	la	x17, 0x10000050		/* pushbutton KEY base address */
	la	x19, LEDG_bits
	lw	x6, 0(x19)		/* load pattern for LEDG lights */

DO_DISPLAY:
	lw	x4, 0(x15)		/* load slider (DIP) switches */

	lw	x5, 0(x17)		/* load pushbuttons */
	beq	x5, x0, NO_BUTTON	
	mv	x6, x4			/* use SW (DIP switch) values on LEDG */

	add     a0, zero, x4
	add     a1, zero, 8
	jal     ra, rotl 
	add     x4, a0, zero

	or	x6, x6, x4	

	add     a0, zero, x4
	add     a1, zero, 8
	jal     ra, rotl 
	add     x4, a0, zero

	or	x6, x6, x4

	add     a0, zero, x4
	add     a1, zero, 8
	jal     ra, rotl 
	add     x4, a0, zero

	or	x6, x6, x4				

WAIT:
	lw 	x5, 0(x17)		/* load pushbuttons */
	bne	x5, x0, WAIT		/* wait for button release */

NO_BUTTON:
	sw	x6, 0(x16)		/* store to LEDG */

	add     a0, zero, x6
	add     a1, zero, 1
	jal     ra, rotl 
	add     x6, a0, zero

	li  	x7, 150000		/* delay counter */
DELAY:	
	addi	x7, x7, -1
	bne	x7, x0, DELAY	

	j   	DO_DISPLAY

rotl:
    sll  a2,   a0, a1
    sub  a4, zero, a1
    srl  a3,   a0, a4
    or   a0,   a2, a3
    ret

/********************************************************************************/
	.data				/* data follows */

LEDG_bits:
	.word 0x0F0F0F0F

	.end
