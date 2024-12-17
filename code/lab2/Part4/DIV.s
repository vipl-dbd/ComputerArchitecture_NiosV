/********************************************************************************
* lab2_part1_2_3_div.s
*
* División entera para el NIOS II que se requiere cuando el procesador no dispone 
* del hardware de un divisor
*
* Referencia: http://stackoverflow.com/questions/938038/assembly-mod-algorithm-on-processor-with-no-division-operator
*
* Llamada desde: lab2_part1_2_3_JTAG.s
*
* argumentos: r4= dividendo, r5= divisor
* resultados: r2= resto, r3= cociente
*
* argumentos: tp= dividendo, t0= divisor
* resultados: s0= resto(r2), gp= cociente
*
********************************************************************************/

.text

.global DIV
DIV:
	addi sp, sp, -16 	/* reservar espacio en el Stack */
	sw 	 t2,  4(sp)
	sw 	 a0,  8(sp)
	sw 	 a1, 12(sp)
	sw 	 t1, 16(sp)

	beq  t0, zero, END	/* si divisor == 0 goto END */

EMPIEZA:
	add  s0, tp, zero	/* resto = dividendo */
	add  t1, t0, zero	/* t1 = next_multiple = divisor */
	add  gp, zero, zero	/* cociente = 0 */

LOOP:	
	add  t2, t1, zero	/* t2 = multiple = next_multiple */
	slli t1, t2, 1		/* next_multiple = left_shift(multiple,1) */
	
	sub  a0, s0, t1		/* a0 = resto - next_multiple */
	sub  a1, t1, t2		/* a1 = next_multiple - multiple */

	blt  a0, zero, LOOP2  	/* si a0 < 0 goto LOOP2 */
	bge  a1, zero, LOOP   	/* si a1 > 0 goto LOOP */
	
LOOP2:	
	blt  t2, t0, END    	/* while divisor(t0) <= multiple(t2) */
	slli gp, gp, 1	   		/* cociente << 1 */
	blt  s0, t2, DESPLAZA 	/* si multiple(t2) <= resto(s0) */
	sub  s0, s0, t2			/* then resto = resto - multiple */
	addi gp, gp, 1			/* cociente += 1 */

DESPLAZA:
	srli t2, t2, 1			/* multiple = right_shift(multiple, 1) */
	j 	 LOOP2

END:	
	lw 	 t2,  4(sp)
	lw 	 a0,  8(sp)
	lw 	 a1, 12(sp)
	lw 	 t1, 16(sp)
	addi sp, sp, 16 		/* libera el stack reservado */

	ret
.end
