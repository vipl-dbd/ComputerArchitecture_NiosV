/********************************************************************************
* lab2_part1_2_3_BCD.s
*
* Subrutina: transforma código binario en BCD 
*
* LLamada desde: lab2_part1_2_3_JTAG.s
* Subrutina: DIV (lab2_part1_2_3_DIV.s)
*
* argumentos: r4= valor binario
* resultados: r2= valor BCD
*
* argumentos: tp= valor binario
* resultados: s0= valor BCD
********************************************************************************/

.text

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

	jal	 ra, DIV		/* llama a division con tp = dividendo, t0 = divisor; devuelve gp= cociente, s0= resto */
	sll  s0, s0, t1		/* desplaza el resultado 4 bits a la izquierda excepto el primer número */
	or   a0, a0, s0 	/* acumula el resultado en a0 */
	addi t1, t1, 4		/* actualiza t1 += 4 */

	blt gp, t0, END 	/* si cociente(gp) < 10 goto END */
	add tp, gp, zero	/* tp = cociente anterior */

	j 	LOOP2			/* si cociente >= 10 goto LOOP2 */

END:	
	sll gp, gp, t1		/* desplaza el cociente final varios 4 bits a la izquierda */
	or  a0, a0, gp 		/* acumula el resultado en a0 */
	add s0, a0, zero 	/* pone el resultado en el registro de salida s0 */

	lw   tp,   4(sp)
	lw   t0,   8(sp)
	lw   t1,  12(sp)
	lw   a0,  16(sp)
	lw   ra,  20(sp)
	lw   gp,  24(sp)
	addi sp, sp, 24 	/* libera el stack reservado */

	ret
.end
