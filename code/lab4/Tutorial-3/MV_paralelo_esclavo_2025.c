//
// Lab 4 - Tutorial-3
//
// Multiplication Matrix x Vector, y = A . x
// Parallel version - Slave thread
// Soft multiprocessor: 2 x Nios V/{m,g}
// SOF file: DE0_Nano_Basic_Computer.sof
// Core name: intel_niosv_m_1, intel_niosv_g_1
//
// Domingo Benitez, July 2025
//
#include <stdio.h>
#include <altera_avalon_mutex.h>
#include <system.h>

// Shared RAM memory for synchronizing variables between threads, size= 20 bytes
// All these variables are saved in a cache block (32 bytes)
volatile unsigned int * message_buffer_ptr 		= (unsigned int *) MESSAGE_BUFFER_RAM_BASE;
volatile unsigned int * message_buffer_ptr_join = (unsigned int *) (MESSAGE_BUFFER_RAM_BASE+4);
volatile unsigned int * message_buffer_ptr_fork = (unsigned int *) (MESSAGE_BUFFER_RAM_BASE+8);
volatile unsigned int * message_buffer_threads  = (unsigned int *) (MESSAGE_BUFFER_RAM_BASE+12);
volatile unsigned int * message_buffer_Niter    = (unsigned int *) (MESSAGE_BUFFER_RAM_BASE+16);

// Shared memory for A matrix and x, y vectors
volatile int * A	= (int *) 0x100000; 	// 16x16x4=1KiB: 0x100000 - 0x1003FF
volatile int * x 	= (int *) 0x100400; 	// 16x1 x4=64 B: 0x100400 - 0x10043F
volatile int * y	= (int *) 0x100800; 	// 16x1 x4=64 B: 0x100800 - 0x10083F
// C_DEL is used for erasing the contents of data cache and updating these data in main memory
volatile int * A_DEL= (int *) 0x10000; // 0x108000 = 0x100000 + 0x8000 (32 KB)

#define m 16 					// number of matrix columns 
#define n 16 					// number of matrix rows

int rank = 1; 					// slave thread for core: intel_niosv_m_1 o intel_niosv_g_1

#define size_dCache ALT_CPU_DCACHE_SIZE		// Data Cache size

// Data cache flush for master core: data is forced to be saved in main memory
void flush_dCache(void){
// This procedure is executed only when cache size is non null
// It is assumed that data cache size is 4 KiB= 32 x 32 x 4 bytes
// It is assumed that cache block size is 8 words; para Nios V/g, it is a fixed value and cannot be modified
   if (size_dCache > 0) {
	   int i, j, Nfila=32, Npauta=8;
	   for (i = 0; i < Nfila; i++){
		   for(j = 0; j < Nfila; j+=Npauta){
			   A_DEL[i*Nfila+j] = 0.0;
		   }
	   }
	}
}

//
// main : main programa of the slave thread
//
int main()
{
	int message_buffer_val 		= 0x0;  // local variable
	int message_buffer_val_fork 	= 0x0;  // local variable
	int message_buffer_val_join 	= 0x0;  // local variable
	int thread_count 		= 0;	// local variable
	int Niter		 	= 0;	// local variable
	*(message_buffer_ptr_fork)	|= 0;	// pointer initialization

  	 // pointer to the mutex driver 
	alt_mutex_dev* mutex = altera_avalon_mutex_open("/dev/message_buffer_mutex");

	//
	// FORK - thread synchronization
	// Slave thread initializes shared variables:
	// Slave updates shared variables: *(message_buffer_ptr_fork) |= 2
	// after master thread has been initialized : *(message_buffer_ptr) = 0x15
	// If master thread see both threads are synchronized, master thread updates: *(message_buffer_ptr) = 5
	// In addition, a while loop is used to read:
	//	  thread_count 	: number of activated threads 
	//	  Niter		: number of algorithm repetitions 
	//
	while(message_buffer_val != 5) {
		altera_avalon_mutex_lock(mutex,2);					// lock mutex 

		message_buffer_val 	= *(message_buffer_ptr); 			// read shared RAM 
		thread_count		= *(message_buffer_threads);			// read shared RAM
		Niter			= *(message_buffer_Niter);			// read shared RAM

		if(message_buffer_val == 15 && thread_count == 2) {
			message_buffer_val_fork 	= *(message_buffer_ptr_fork); 	// read shared RAM 
			message_buffer_val_fork 	|= 2;				// updates shared variable 
			*(message_buffer_ptr_fork) 	= message_buffer_val_fork;	// write in RAM
		}

		altera_avalon_mutex_unlock(mutex); 					// free mutex 
	}
	//
	// SLAVE COMPUTING - Matrix x Vector repeated Niter times
	// 2 threads: each thread obtain half output matrix
	// Slave thread: lower half of A matrix
	//
	int i, j, k1, iteraciones = 0, dumy;
	int local_n 	 = n / thread_count;
	int my_first_row = rank * local_n;		 	// first matrix raw
	int my_last_row  = (rank+1) * local_n - 1;  		// last matrix raw

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
	// local data cache is updated (flushed) in main memory to be read by master thread
	flush_dCache();
	
	//
	// JOIN - Join synchronization
	// Slave thread updates shared variable: *(message_buffer_ptr_join) |= 2
	//
	while(message_buffer_val != 6 && thread_count == 2) {
		altera_avalon_mutex_lock(mutex,2);				// lock mutex 

		message_buffer_val 		= *(message_buffer_ptr); 	// read shared variable 

		message_buffer_val_join 	= *(message_buffer_ptr_join); 	// read shared variable 
		message_buffer_val_join 	|= 2;				// master thread is in JOIN stage 		*(message_buffer_ptr_join) 	= message_buffer_val_join;	// write shared variable

		altera_avalon_mutex_unlock(mutex); 				// free mutex 
	}

  	return 0;
}
