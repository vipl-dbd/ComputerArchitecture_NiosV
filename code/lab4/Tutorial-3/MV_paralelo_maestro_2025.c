//
// Lab 4 - Tutorial-3
//
// Multiplication Matrix x Vector, y = A . x
// Parallel version - Master thread
// Soft multiprocessor: 2 x Nios V/{m,g}
// SOF file: DE0_Nano_Basic_Computer.sof
// Core name: intel_niosv_m_0, intel_niosv_g_0
//
// Domingo Benitez, July 2025
//
#include <stdio.h>
#include <altera_avalon_mutex.h>		// for mutex controller
#include <system.h>
#include "sys/alt_stdio.h" 			// for alt_putstr
#include <unistd.h>				// for usleep function
#include <sys/alt_timestamp.h>			// for timer driver

// Shared RAM memory for synchronizing variables between threads, size= 20 bytes
// All these variables are saved in a cache block (32 bytes)
volatile unsigned int * message_buffer_ptr 	= (unsigned int *) MESSAGE_BUFFER_RAM_BASE;
volatile unsigned int * message_buffer_ptr_join = (unsigned int *) (MESSAGE_BUFFER_RAM_BASE+4);
volatile unsigned int * message_buffer_ptr_fork = (unsigned int *) (MESSAGE_BUFFER_RAM_BASE+8);
volatile unsigned int * message_buffer_threads  = (unsigned int *) (MESSAGE_BUFFER_RAM_BASE+12);
volatile unsigned int * message_buffer_Niter    = (unsigned int *) (MESSAGE_BUFFER_RAM_BASE+16);

// Shared memory for A matrix and x, y vectors
volatile int * A	= (int *) 0x100000; 	// 16x16x4=1KiB: 0x100000 - 0x1003FF
volatile int * x 	= (int *) 0x100400; 	// 16x1 x4=64 B: 0x100400 - 0x10043F
volatile int * y	= (int *) 0x100800; 	// 16x1 x4=64 B: 0x100800 - 0x10083F
// C_DEL is used for erasing the contents of data cache and updating these data in main memory
volatile int * A_DEL= (int *) 0x108000; // 0x108000 = 0x100000 + 0x8000 (32 KB)

#define m 16 					// number of matrix columns 
#define n 16 					// number of matrix rows

#define sleepTime 100000			// 0.1 seconds

int rank = 0; 					// master thread for core: intel_niosv_m_0 or intel_niosv_g_0

// Constants defined in system.h
#define tipoNiosV   ALT_CPU_ARCHITECTURE 	// "m" (Nios V/n), "g" (Nios V/g)
#define nombreNiosV ALT_CPU_NAME 		// "intel_niosv_m_0" (master core), "intel_niosv_m_1" (slave core)
#define size_dCache ALT_CPU_DCACHE_SIZE		// Data Cache size

// Data cache flush for master core: data is forced to be saved in main memory
void flush_dCache(void){
// This procedure is executed only when cache size is non null
// It is assumed that data cache size is 4 KiB= 32 x 32 x 4 bytes
// It is assumed that cache block size is 8 words; para Nios V/g, it is a fixed value and cannot be modified
   if (size_dCache > 0) {
	   alt_putstr("\nFLUSH for data cache in the master core\n");
	   int i, j, Nfila=32, Npauta=8;
	   for (i = 0; i < Nfila; i++){
		   for(j = 0; j < Nfila; j+=Npauta){
			   A_DEL[i*Nfila+j] = 0.0;
		   }
	   }
   }
   else {
	   alt_putstr("\nCache flash is not done because there no data cache\n");
   }
}

// inicializaMemoria : Initialize shared memory
//
// ini_printf=0: Initialize: A, x, y
// ini_printf=1: printf of values of A, x, y
// ini_printf=2: printf of memory addresses of A, x, y
//
void inicializaMemoria(int ini_printf){
   int i,j;
   if (ini_printf == 0){
	   printf("\nInitialize Matrix and Vector\n");
   }
   else if (ini_printf == 1){
	   printf("\nPRINTF VALUES\n");
	   flush_dCache(); // data cache flush to make master core to get algoritm results obtained by slave core
   }
   else if (ini_printf == 2){
	   printf("\nPRINTF ADDRESSES\n");
   }
   for (i=0; i<n; i++){
	   if (ini_printf == 0){
		   x[i] = (int)i;
		   y[i] = 0.0;
	   }
	   else if (ini_printf == 1){
		   printf("y[%2i]= %i"   , i, (int)y[i]);
		   printf("\tx[%2i]= %2i", i, (int)x[i]);
		   printf("\tA[%2i]= "   , i);
	   }
	   else if (ini_printf == 2){
		   printf("y[%i]= 0x%x"  , i, (unsigned int) &y[i]);
		   printf("\tx[%i]= 0x%x", i, (unsigned int) &x[i]);
		   printf("\tA[%i][]= "  , i);
	   }
	   for(j=0; j<m; j++){
		   if (ini_printf == 0){
			   A[i*m+j]=(int)j;
		   }
		   else if (ini_printf == 1){
			   printf("%i ", (int)A[i*m+j]);
		   }
		   else if (ini_printf == 2){
			   printf(" 0x%x ", (unsigned int) &A[i*m+j]);
		   }
	   }
	   if (ini_printf == 1 || ini_printf == 2){
		   printf("\n");
	   }
   }
   if (ini_printf == 0){
	   flush_dCache(); // shared memory is updated after initialization of values
   }
}
//
// main : main programa of the master thread
//
int main()
{
	 int thread_count	= 2; 	// number of threads: 1,2
	 int Niter		= 1000; // options: 1000,2000,10000; number of repetitions
	 int dumy = 0, start, iteraciones = 0, timeInterval = 0, timeInterval2 = 0;
	 alt_u32 freq		= 0;
	 unsigned int time[5]	= {0};
	 char etiqueta_time[6][6]	= {"tStar","tInic","tFork","tComp","tJoin","tFina"};

	 int message_buffer_val      	= 0x0; // local variable
	 int message_buffer_val_fork 	= 0x0; // local variable
	 int message_buffer_val_join 	= 0x0; // local variable

  	 // pointer to the mutex driver
  	 alt_mutex_dev* mutex = altera_avalon_mutex_open("/dev/message_buffer_mutex");

  	 alt_putstr("\n\nParallel Matrix x Vector - Master core - BEGIN\n");
  	 printf("\tNios V processor name\t: %s\n", tipoNiosV);
  	 printf("\tData cache size\t\t: %i bytes\n", size_dCache);
  	 printf("\Threads\t\t\t\t: %i \n\Iterations\t\t\t: %i\n", thread_count, Niter);

 	// Initialize timestamp for measuring the number of clock cycles
 	start = alt_timestamp_start();
 	if(start < 0) {
     		printf("\nTimestamp start -> FAILED!, %i\n", start);
     	}
     	else{
     		freq = alt_timestamp_freq() / 1e6;
     		printf("\nTimestamp start -> OK!, clock speed= %u MHz\n", (unsigned int) freq);
     	}
	// time0: first time measure
	time[0] = alt_timestamp();


	//
	// INITIALIZATION OF VARIABLES
	//

	// Read synchronization RAM, it is forced to be done using mutex controller
	//
	altera_avalon_mutex_lock(mutex,1); 		// lock mutex

	message_buffer_val 		= *(message_buffer_ptr); 	
	message_buffer_val_fork 	= *(message_buffer_ptr_fork); 	
	message_buffer_val_join 	= *(message_buffer_ptr_join); 	

	altera_avalon_mutex_unlock(mutex); 		// free mutex

	inicializaMemoria(0);			// initialization of A,x,y
	inicializaMemoria(1);			// A is displayed

	alt_putstr("\nCPU - before FORK\n");
	printf("\tmessage_buffer_val:\t\t%08X\n\tmessage_buffer_val_fork:\t%08X\n\tmessage_buffer_val_join:\t%08X\n",
			message_buffer_val, message_buffer_val_fork, message_buffer_val_join);    

	// time1: second time measure, end of initialization
	time[1] = alt_timestamp();

	//
	// FORK - thread synchronization
	// Master thread initializes shared variables:
	//    *(message_buffer_ptr) 	 = 15
	//    *(message_buffer_ptr_fork) = 1
	//
	message_buffer_val 	= 15;  // ID=15(0xF) : fork begins
	message_buffer_val_fork = 1 ;  // master thread is ready for computing


	// Write synchronization RAM, it is forced to be done using mutex controller

	altera_avalon_mutex_lock(mutex,1);		// lock mutex

	*(message_buffer_ptr) 		= message_buffer_val; 		
	*(message_buffer_ptr_fork) 	= message_buffer_val_fork; 
	*(message_buffer_threads) 	= thread_count;  
	*(message_buffer_Niter) 	= Niter;
  
	altera_avalon_mutex_unlock(mutex); 		// free mutex


	// while loop for synchronizing both threads before computing
	// message_buffer_val = 5 : means both threads are synchronized
	//
	int vista = 0;
	while( (message_buffer_val != 5) ){
		if (vista > 0) usleep(sleepTime); 			// wait "sleepTime/1000000" seconds

		altera_avalon_mutex_lock(mutex,1);			// lock mutex

		message_buffer_val_fork = *(message_buffer_ptr_fork); 	// read RAM to test is the other thread is ready

		altera_avalon_mutex_unlock(mutex); 			// free mutex

		if ( (message_buffer_val_fork == 0x3 && thread_count == 2 ) ||
			 (message_buffer_val_fork == 0x1 && thread_count == 1) ){
			dumy = 5;

			altera_avalon_mutex_lock(mutex,1);	// lock mutex
			*(message_buffer_ptr) 		= dumy; // write buffer
			*(message_buffer_ptr_join) 	= 0;  	// write buffer
			altera_avalon_mutex_unlock(mutex); 	// free mutex

			message_buffer_val 		= dumy;

			alt_putstr("\nCPU - FORK ENDS !!\n");
			printf("\tmessage_buffer_val:\t\t%08X\n\tmessage_buffer_val_fork:\t%08X\n",
					message_buffer_val, message_buffer_val_fork);      
		}
		vista++;
	}
	//
	// MASTER COMPUTING - Matrix x Vector repeated Niter times
	// 1 thread : all job is done by one core
	// 2 threads: each thread obtain half output matrix
	//
	// time2: third time measure, end of thread fork
	time[2] = alt_timestamp();

	int i, j, k1, k;
	int local_n 	 	= n / thread_count;
	int my_first_row 	= rank * local_n;		// first matrix raw
	int my_last_row  	= (rank+1) * local_n - 1;  	// last matrix raw

	printf("\nBegin computing matrix-vector, number of iterations: %i\n", Niter);

	for (k1 = 0; k1 < Niter; k1++) {
	   	iteraciones++;
		for (i=my_first_row; i<=my_last_row; i++){
	   	dumy = y[i];
		  for(j=0; j<m; j++){
		   	dumy = dumy + A[i*m+j] * x[j];
		  }
		  y[i] = dumy;
	   	}
	}

	//
	// JOIN - Join synchronization
	// Master thread updates shared variable: *(message_buffer_ptr_join) |= 1
	//
	// time3: fourth time measure, end of computing and begin of JOIN thread synchronization
	time[3] = alt_timestamp();

	message_buffer_val_join = 1; 		// master thread is in JOIN stage

	altera_avalon_mutex_lock(mutex,1);	// lock mutex

	*(message_buffer_ptr_join) 	|= message_buffer_val_join; 	// shared variable is updated by master thread

	altera_avalon_mutex_unlock(mutex); 	// free mutex

	// while loop for synchronizing both threads after computing
	// message_buffer_val = 5 : means both threads are synchronized

	time[4] = alt_timestamp();

	vista = 0;
	while( (message_buffer_val != 6) ){
		if (vista > 0) usleep(sleepTime); 			// wait "sleepTime/1000000" seconds

		altera_avalon_mutex_lock(mutex,1);			// lock mutex

		message_buffer_val 		= *(message_buffer_ptr); 	
		message_buffer_val_join = *(message_buffer_ptr_join); 	
		altera_avalon_mutex_unlock(mutex); 			// free mutex

		if ( (message_buffer_val_join == 0x3 && thread_count == 2 ) ||
			  (message_buffer_val_join == 0x1 && thread_count == 1) ){

			dumy = 6;

			altera_avalon_mutex_lock(mutex,1);		// lock mutex
			*(message_buffer_ptr) 			= dumy; // both threads are synchronized
			altera_avalon_mutex_unlock(mutex); 		// free mutex

			message_buffer_val 			= dumy; // update local variable

			alt_putstr("\nCPU - JOIN ENDS!!\n");
			printf("\tmessage_buffer_val:\t\t%08X\n\tmessage_buffer_val_join:\t%08X\n\n",
					message_buffer_val, message_buffer_val_join);
		}
		vista++;
	}

	//
	// FINAL
	//
	// time4: fifth time measure, end of thread JOIN
	time[4] = alt_timestamp();
	
	// printf execution times
	printf("%s : %s \t %s \t %s\n---------------------------------------------------------------------------\n",
		"nombContador", "clock cycles", "(accumulated ms)", "interval ms");
	for (k = 1; k < 5; k++){
		timeInterval = (time[k] - time[0])   * 1e-3 / freq;
		timeInterval2= (time[k] - time[k-1]) * 1e-3 / freq;
		//alt_putstr("CPU - ");
		//printf("%u\n",time[4]);
		//printf("%6s : time[%i]= %10u clk\t (%6u ms) interval= %6u ms\n",
		//		&etiqueta_time[k][0], k, time[k], timeInterval, timeInterval2);
		printf("CPU - %6s : ", &etiqueta_time[k][0]);
		printf("time[%i]= %10u clk\t (%6u ms) ",k, time[k], timeInterval);
		printf("intervalo= %6u ms\n",timeInterval2);
	}

	timeInterval = (time[4] - time[0]) * 1e-3 / freq;
	printf("\nCPU - %6s : time[%i]= %10u clk\t TotalTime= %6u ms\n",
			&etiqueta_time[5][0], 5, time[4], timeInterval);

	// synchronizing variables are reset
	altera_avalon_mutex_lock(mutex,1);			// lock mutex
	*(message_buffer_ptr) 			= 0;  		// initialize RAM
	*(message_buffer_ptr_fork) 	= 0;  			// initialize RAM FORK
	*(message_buffer_ptr_join) 	= 0;  			// initialize RAM JOIN
	altera_avalon_mutex_unlock(mutex);			// free mutex

	inicializaMemoria(1);					// output matrix is displayed
	alt_putstr("\nEnd of program and synchronizing variables are reset\n");

  	return 0;
}
