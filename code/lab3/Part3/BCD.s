/********************************************************************************
* BCD.s
*
* Subrutines: BCD, BCD_LONG; translate binary format into BCD 
*
* Callee: lab2_part1_2_3_JTAG.s
* Subrutine: DIV (DIV.s)
*
* Domingo Benitez, November 2024
********************************************************************************/

.text

/*
* BCD
* input : tp = binary value
* output: s0 = BCD
*/
.global BCD
BCD:
	addi sp, sp, -24 	/* reserva de memoria en el Stack */
	sw 	 tp,   4(sp)
	sw 	 t0,   8(sp)
	sw 	 t1,  12(sp)
	sw 	 a0,  16(sp)
	sw 	 ra,  20(sp) 	/* por posible llamada anidada */
	sw 	 gp,  24(sp)

	beq  tp, zero, END	/* si binario == 0 goto END */

	addi t0, zero, 10 	/* t0 = 10 para dividir BCD */

	add  t1, zero, zero	/* i = 0 */
	add  a0, zero, zero	/* a0 = 0 */

LOOP2:	
	bgeu zero, tp, END  /* while valor unsigned binario > 0 */

	jal	 ra, DIV		/* llama a division con tp = dividendo, t0 = divisor (10); devuelve gp= cociente, s0= resto */
	sll  s0, s0, t1		/* desplaza el resto 4 bits a la izquierda excepto el primer dígito */
	or   a0, a0, s0 	/* coloca el digito en a0 */
	addi t1, t1, 4		/* actualiza t1 += 4 */

	blt gp, t0, END 	/* si cociente(gp) < 10 goto END */
	add tp, gp, zero	/* tp = cociente anterior */

	j 	LOOP2			/* si cociente >= 10 goto LOOP2 */

END:	
	sll gp, gp, t1		/* desplaza el cociente final varios 4 bits a la izquierda */
	or  a0, a0, gp 		/* coloca el digito en a0 */
	add s0, a0, zero 	/* pone el resultado en el registro de salida s0 */

	lw   tp,   4(sp)
	lw   t0,   8(sp)
	lw   t1,  12(sp)
	lw   a0,  16(sp)
	lw   ra,  20(sp)
	lw   gp,  24(sp)
	addi sp, sp, 24 	/* libera el stack reservado */

	ret

/*
* BCD_LONG
* input : tp= binary value
* output: s0 (LSB), s1 (MSB) = BCD
*/
.global BCD_LONG
BCD_LONG:
	addi sp, sp, -32 	/* reserva de memoria en el Stack */
	sw 	 tp,   4(sp)
	sw 	 t0,   8(sp)
	sw 	 t1,  12(sp)
	sw 	 a0,  16(sp)
	sw 	 ra,  20(sp) 	/* por posible llamada anidada */
	sw 	 gp,  24(sp)
	sw 	 a1,  28(sp)
	sw 	 t2,  32(sp)

	beq  tp, zero, END_LONG	/* si binario == 0 goto END_LONG */

	addi t0, zero, 10 	/* t0 = 10 para dividir BCD */
	addi t3, zero, 32 	/* t3 = 32 para seleccionar LSB o MSB */

	add  t1, zero, zero	/* i = 0 */
	add  t2, zero, zero	/* j = 0 */
	add  a0, zero, zero	/* a0 = 0 LSB */
	add  a1, zero, zero	/* a1 = 0 MSB */

LOOP2_LONG:	
	bgeu zero, tp, END_LONG  /* while valor unsigned binario > 0 */

/* LOOP2_LONG ¿aquí? */
	jal	 ra, DIV		/* llama division: tp = dividendo, t0 = divisor (10); devuelve gp= cociente, s0= resto */

	blt t1, t3, LSB2	/* if i(t1) >= 33 */
	sll	 s0, s0, t2 	/* desplaza el resto 4 bits a la izquierda excepto el primer dígito del MSB */
	or 	 a1, a1, s0		/* coloca el digito "resto" en un nible de a1 (MSB) */
	addi t2, t2, 4 		/* actualiza t2 += 4, j+=4 */
	j LESS_10

LSB2:					/* else: i(t1) < 33 */
	sll  s0, s0, t1		/* desplaza el resto 4 bits a la izquierda excepto el primer dígito del LSB */
	or   a0, a0, s0 	/* coloca el digito "resto" en un nible de a0 (LSB) */
	addi t1, t1, 4		/* actualiza t1 += 4, i+=4 */

LESS_10:
	blt gp, t0, END_LONG /* si cociente(gp) < 10(tp) --> goto END_LONG */
					
	add tp, gp, zero	/* else: tp = cociente anterior */
	j 	LOOP2_LONG		/* else: si cociente >= 10 goto LOOP2_LONG */

END_LONG:	
	blt t1, t3, LSB		/* if i(t1) >= 33 */
	sll gp, gp, t2		/* desplaza el cociente final varios 4 bits a la izquierda */
	or  a1, a1, gp 		/* coloca el digito en a1 */
	j   OUT

LSB: 					/* else */
	sll gp, gp, t1		/* desplaza el cociente final varios 4 bits a la izquierda */
	or  a0, a0, gp 		/* coloca el digito en a0 */

OUT:
	add s1, a1, zero 	/* pone el resultado en el registro de salida s1 MSB */
	add s0, a0, zero 	/* pone el resultado en el registro de salida s0 LSB */

	lw   tp,   4(sp)
	lw   t0,   8(sp)
	lw   t1,  12(sp)
	lw   a0,  16(sp)
	lw   ra,  20(sp)
	lw   gp,  24(sp)
	lw   a1,  28(sp)
	lw   t2,  32(sp)
	addi sp, sp, 32 	/* libera el stack reservado */

	ret


.end
