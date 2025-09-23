/************************************************************* 
* file: roofline.s
*
* Kernel for the benchNiosV2024_roofline benchmark
*
* Domingo Benitez
* July 2024
*************************************************************/

.equ Niter,1000			/* numero de iteraciones del bucle principal de este kernel */
.equ NiterInternas,2000 /* 1,5,20,47,400,500; numero iteraciones de un bucle anidado, 
								   se modifica para dar mas o menos porcentaje de instrucciones 
								   de salto al numero total de instrucciones */

.global ROOFLINE
ROOFLINE:

		addi     sp, sp, -24    /* 6 registros --> pila, 24 dir */

   	sw       ra,  0(sp)
   	sw       t2,  4(sp)
   	sw       t4,  8(sp)
   	sw       t5, 12(sp)
   	sw       t1, 16(sp)
   	sw       t6, 20(sp)

		la 		t2, A 	    	/* t2: puntero a variable A */
		la 		t4, N
		lw 		t4, 0(t4)   	/* t4 = Niter, numero de iteraciones a realizar */
		add		t6, zero, zero /* contador de iteraciones realizadas = 0 */

/* BUCLE GLOBAL, se realiza Niter veces */
LOOP: 	

/* Begin: ZONA 1 de accesos a memoria */
		lw 		t5, 0(t2)   	/* carga A */

/* 3 cargas que se pueden activar o desactivar para variar la relacion op/byte 
   Cada ldw accede a 4 bytes */
/*
		lw 		t5, 0(t2)   
		lw 		t5, 0(t2)   
		lw 		t5, 0(t2)   
*/
/* End: ZONA 1 de accesos a memoria */

/* Begin: ZONA 2 de operaciones ALU */
		add 	t5, t5, t5  		/* suma con dependencia de datos con ldw t5, 0(t2) */

/* 44 add que se pueden activar o desactivar parcialmente para dar variar la relacion op/byte */
		add 	t5, t5, t5  
		add 	t5, t5, t5

		add 	t5, t5, t5
		add 	t5, t5, t5

		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5

		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5

		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5

		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5

		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5

		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5

		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5

		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5

		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
		add 	t5, t5, t5
/*
*/
/* End: ZONA 2 de operaciones ALU */

/* 2 instrucciones mas de tipo ALU, nunca se desactivan */
		addi 	t6, t6, 1   		/* contador_iteraciones_realizadas++ */
		addi 	t4, t4, -1  		/* Niter-- */

/* Begin: ZONA 3 de bucle interno para forzar la ejecucion de multiples saltos */
/* NiterInternas= 1,5,20,47,400,500 */
		addi	t1, zero, NiterInternas 

bucleInterno:
		add 	t5, t5, t5  
		addi	t1, t1, -1
		bgt	t1, zero, bucleInterno
/*
*/
/* End: ZONA 3 de bucle interno para forzar la ejecucion de multiples saltos */

/* Fin del bucle  LOOP */
		blt 	zero, t4, LOOP	 


/* guarda Niter iteraciones realizadas en variable ITERACIONES para la */
/* comprobación de la ejecucion correcta */
	la 		t4, ITERACIONES
	sw  		t6, 0(t4) 			/* variable t_T: tiempo de ejecución total del benchmark */

/* recuperar los registros de la pila y retornar */
	lw  	  ra,  0(sp)
	lw  	  t2,  4(sp)
	lw  	  t4,  8(sp)
	lw  	  t5, 12(sp)
	lw  	  t1, 16(sp)
	lw  	  t6, 20(sp)

	addi 	  sp, sp, 24

	ret
 
.data
.align 2

/*.org 0x5000*/
N: 
.word Niter 						/* numero de iteraciones del bucle principal del kernel mem-computo */

A: 
.word 5 								/* variable A */

/*.org 0x5040*/
ITERACIONES:
.skip 4

.end
