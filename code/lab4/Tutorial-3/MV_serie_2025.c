//
// Lab 4 - Tutorial-3
//
// Multiplication Matrix x Vector, y = A . x
// Secuential version
// Soft multiprocessor: 2 x Nios V/{m,g}
// SOF file: DE0_Nano_Basic_Computer.sof
// Core name: intel_niosv_m_0, intel_niosv_g_0
//
// Domingo Benitez, July 2025
//
#include <stdio.h>
#include <altera_avalon_mutex.h>	// for mutex driver
#include <system.h>
#include "sys/alt_stdio.h" 		// for alt_putstr
#include <sys/alt_timestamp.h>		// for timer

// Shared memory addresses for A matrix and x, y vectors
volatile int * A	= (int *) 0x100000; 	// 16x16x4=1KiB: 0x100000 - 0x1003FF
volatile int * x 	= (int *) 0x100400; 	// 16x1 x4=64 B: 0x100400 - 0x10043F
volatile int * y	= (int *) 0x100800; 	// 16x1 x4=64 B: 0x100800 - 0x10083F

#define m 16 					// number of matrix columns 
#define n 16 					// number of matrix rows

int rank = 0; 					// ID for master thread

// Constantí defiende in system.h
#define tipoNiosV   ALT_CPU_ARCHITECTURE 	// "m" (Nios V/n), "g" (Nios V/g)
#define nombreNiosV ALT_CPU_NAME 		// "intel_niosv_m_0" (master core), "intel_niosv_m_1" (slave core)
#define size_dCache ALT_CPU_DCACHE_SIZE		// Data Cache size

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

// dataPrint: initialize shared memory 
// ini_printf=1: printf de valores A, x, y
// ini_printf=2: printf addresses assigned to A, x, y
int dataPrint(int ini_printf){
   int i=0, j=0;
   if (ini_printf == 1){
	   alt_printf("\nPRINTF VALUES\n");
   }
   else if (ini_printf == 2){
	   alt_printf("\nPRINTF ADDRESSES\n");
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
   }
   return 0;
}

// main program

int main()
{
	unsigned int Niter = 1000; 	// options: 1000,2000,10000; number of repetitions
	int dumy, start, iteraciones = 0, timeInterval = 0, timeInterval2 = 0;
	alt_u32 freq=0;
	unsigned int i, j, time[5];
	char etiqueta_time[6][6]={"tStar","tInic","tFork","tComp","tJoin","tFina"};
	 
  	alt_printf("\n\nMatriz x Vector Secuencial - CPU - BEGIN\n");
  	alt_printf("\tNombre procesador Nios II\t: %s\n", nombreNiosV);
  	alt_printf("\tTipo procesador Nios II\t\t: %s\n", tipoNiosV);
  	printf("\tTamano dCache Nios II\t\t: %u bytes\n", size_dCache);
  	printf("\tHilos\t\t\t\t: Secuencial \n\tIteraciones\t\t\t: %u\n", Niter);
 	 
 	// Initialize timestamp for measuring the number of clock cycles
 	start = alt_timestamp_start();
 	if(start < 0) {
     		printf("\nTimestamp start -> LAILED!, %i\n", start);
     	}
     	else{
     		freq = alt_timestamp_freq() / 1e6;
     		printf("\nTimestamp start -> OK!, clock speed= %u MHz\n", (unsigned int) freq);
     	}
	// time0: first time measure
	time[0] = alt_timestamp();

	//
	// INCIALIZACION DE VARIABLES
	//
   	dataInit();

	dataPrint(1);			// Values of A, x, y are displayed 

	// time1: second time measure, end of initialization
	time[1] = alt_timestamp();

	//
	// COMPUTING - Matrix x Vector repeated Niter times

	// time2: third time measure, end of thread fork
	time[2] = alt_timestamp();

	unsigned int k1;
	unsigned int local_n 	  = n;
	unsigned int my_first_row = 0;		 // first matrix raw
	unsigned int my_last_row  = local_n - 1; // last matrix raw

	alt_printf("\nBegin computing matrix-vector\n");
	
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

	// time3: fourth time measure, end of computing
	time[3] = alt_timestamp();

	// time4: fifth time measure, end of thread join
	time[4] = alt_timestamp();

	// printf of time measurements
	for (int k = 1; k < 5; k++){
		timeInterval = (time[k] - time[0])   * 1e-3 / freq;
		timeInterval2= (time[k] - time[k-1]) * 1e-3 / freq;
		alt_printf("%s - ", nombreNiosV);
		printf("%6s : time[%i]= %10u clk\t (%6u ms) intervals= %6u ms\n",
				&etiqueta_time[k][0], k, time[k], timeInterval, timeInterval2);
	}

	timeInterval = (time[4] - time[0]) * 1e-3 / freq;

	printf("\n%s - %6s : time[%i]= %10u clk\t Total Time= %6u ms\n",
			nombreNiosV, &etiqueta_time[5][0], 5, time[4], timeInterval);

	dataPrint(1);	// printf of final out A matrix
  	
	alt_printf("\nEnd of program\n");

  	return 0;
}
