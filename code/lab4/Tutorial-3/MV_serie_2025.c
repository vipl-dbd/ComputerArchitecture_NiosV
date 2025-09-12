//
// Lab 4 - version: julio 2025
//
// Multiplicacion Matriz x Vector, y = A . x
// Version Secuencial
// Tipo multiprocesador: 2 x Nios V/g
// SOF file: C:\altera\24.1std\quartus\qdesigns\misProyectos\DE0-Nano_Basic_Computer_NiosVm_conSDRAM_dualCore_Q24\verilog\DE0_Nano_Basic_Computer.sof
// Tipo procesador: Nios V/g, nombre: intel_niosv_g_0
//
#include <stdio.h>
#include <altera_avalon_mutex.h>		// para controlador exclusion mutua
#include <system.h>
#include "sys/alt_stdio.h" 			// para alt_putstr
// Timer, incluir el timestamp en BSP: boton dcho en BSP folder, Nios2 > BSP editor > cambiar system timer y timestamp timer
#include <sys/alt_timestamp.h>

// Zona de memoria compartida para matriz A y vectores x, y
volatile int * A	= (int *) 0x100000; 	// 16x16x4=1KiB: 0x100000 - 0x1003FF
volatile int * x 	= (int *) 0x100400; 	// 16x1 x4=64 B: 0x100400 - 0x10043F
volatile int * y	= (int *) 0x100800; 	// 16x1 x4=64 B: 0x100800 - 0x10083F

#define m 16 					// numero de columnas de las matrices
#define n 16 					// numero de filas de las matrices

int rank = 0; 					// hilo maestro para nucleo= CPU

// Las siguientes constantes se encuentran definidas en fichero system.h
#define tipoNiosV   ALT_CPU_ARCHITECTURE 				// "m" (Nios V/n), "g" (Nios V/g)
#define nombreNiosV ALT_CPU_NAME 						// "intel_niosv_m_0" (nucleo 1), "intel_niosv_m_1" (nucleo 2)
#define size_dCache ALT_CPU_DCACHE_SIZE				// tamanyo de la dCache

int iteraciones 	= 0x0;

void dataInit(void){
	unsigned int i=0, j=0, i1=0;
   alt_printf("\nInicializa Matriz y Vector\n");
   for (i=0; i<n; i++){
		   x[i] = i;
		   y[i] = 0;
		   
	}
   for (i=0; i<n; i++){
   		for(j=0; j<m; j++){
	   		i1 = i * m + j;
		      A[i1] = j;
		   }
	}
}

// dataPrint : Inicializa zona memoria compartida
// ini_printf=1: printf de valores A, x, y
// ini_printf=2: printf de direcciones A, x, y
int dataPrint(int ini_printf){
   int i=0, j=0;
   if (ini_printf == 1){
	   alt_printf("\nPRINTF VALORES\n");
   }
   else if (ini_printf == 2){
	   alt_printf("\nPRINTF DIRECCIONES\n");
   }
   for (i=0; i<n; ++i){
	   if (ini_printf == 1){
		   printf("y[%2i]= %i"   , i, y[i]);
		   printf("\tx[%2i]= %2i", i, x[i]);
		   printf("\tA[%2i]= "   , i);
	   }
	   else if (ini_printf == 2){
		   alt_printf("y[%x]= 0x%x"  , i, (unsigned int) &y[i]);
		   alt_printf("\tx[%x]= 0x%x", i, (unsigned int) &x[i]);
		   alt_printf("\tA[%x][]= "  , i);
	   }
	   for(j=0; j<m; j++){
		   if (ini_printf == 1){
		      printf("%i ", A[i*m+j]);
		   }
		   else if (ini_printf == 2){
				alt_printf(" 0x%x", (unsigned int) &A[i*m+j]);
		   }
	   }
	   if (ini_printf == 1 || ini_printf == 2){
		   alt_printf("\n");
	   }
	//
   }
   return 0;
}
//

// main program
//
int main()
{
	 //int thread_count	= 1    ; 	// opciones: 1,2; numero de hilos
	 unsigned int Niter		= 1000; 	// opciones: 1000,2000,10000,20000,...; veces repite matriz-vector
	 int dumy, start, iteraciones = 0, timeInterval = 0, timeInterval2 = 0;
	 alt_u32 freq=0;
	 unsigned int i, j, time[5];
	 char etiqueta_time[6][6]={"tStar","tInic","tFork","tComp","tJoin","tFina"};
	 
  	alt_printf("\n\nMatriz x Vector Secuencial - CPU - BEGIN\n");
  	//
  	alt_printf("\tNombre procesador Nios II\t: %s\n", nombreNiosV);
  	alt_printf("\tTipo procesador Nios II\t\t: %s\n", tipoNiosV);
  	printf("\tTamano dCache Nios II\t\t: %u bytes\n", size_dCache);
  	printf("\tHilos\t\t\t\t: Secuencial \n\tIteraciones\t\t\t: %u\n", Niter);
 	 
 	// Inicializa el timestamp para medir tiempo en ciclos de reloj
 	start = alt_timestamp_start();
 	if(start < 0) {
     		printf("\nTimestamp start -> FALLO!, %i\n", start);
     	}
     	else{
     		freq = alt_timestamp_freq() / 1e6;
     		printf("\nTimestamp start -> OK!, frecuencia de reloj= %u MHz\n", (unsigned int) freq);
     	}
	// time0: marca tiempo inicial
	time[0] = alt_timestamp();

	//
	// INCIALIZACION DE VARIABLES
	//
   dataInit();

	dataPrint(1);			// se visualizan los valores de la matriz A y vectores x, y
	//dataPrint(2);			// se visualizan las direcciones de la matriz A y vectores x, y

	// time1: marca tiempo inicial y final de Inicializacion
	time[1] = alt_timestamp();

	//
	// COMPUTO MAESTRO - Operacion Matriz x Vector - repetido Niter veces
	// 2 hilos: cada hilo calcula la mitad de filas de la matriz C
	//
	// time2: marca tiempo inicial computo y final de FORK

	time[2] = alt_timestamp();

	unsigned int k1;
	unsigned int local_n 	  = n;
	unsigned int my_first_row = 0;		// 1a fila asignada a este nucleo
	unsigned int my_last_row  = local_n - 1; // ultima fila asignada a este nucleo

	alt_printf("\nEmpieza el computo matriz-vector\n");
	
	for (k1 = 0; k1 < Niter; k1++) {
	   	iteraciones++;
		for (i=my_first_row; i<=my_last_row; i++){
	       		dumy = y[i];
		   	for(j=0; j<m; j++){
			   dumy += A[i*m+j] * x[j];
		   	}
		   	y[i] = dumy;
	    	}
	}

	time[3] = alt_timestamp();

	//
	// FINAL
	//
	// time4: Nueva marca de tiempo (parte final del programa)

	time[4] = alt_timestamp();

	// printf de los tiempos medidos
	for (int k = 1; k < 5; k++){
		timeInterval = (time[k] - time[0])   * 1e-3 / freq;
		timeInterval2= (time[k] - time[k-1]) * 1e-3 / freq;
		alt_printf("%s - ", nombreNiosV);
		printf("%6s : time[%i]= %10u clk\t (%6u ms) intervalo= %6u ms\n",
				&etiqueta_time[k][0], k, time[k], timeInterval, timeInterval2);
	}

	timeInterval = (time[4] - time[0]) * 1e-3 / freq;

	printf("\n%s - %6s : time[%i]= %10u clk\t TiempoTotal= %6u ms\n",
			nombreNiosV, &etiqueta_time[5][0], 5, time[4], timeInterval);

	dataPrint(1);			// se visualiza los valores de la matriz C resultante
//
  	
	alt_printf("\nFin del programa\n");

  	return 0;
}
