//
// Lab 4 - version: july 2025
//
// Multiplicacion Matriz x Vector, y = A . x
// Version paralela - Hilo Esclavo
// Tipo multiprocesador: 2 x Nios V/m
// SOF file: C:\altera\24.1std\quartus\qdesigns\misProyectos\DE0-Nano_Basic_Computer_NiosVm_conSDRAM_dualCore_Q24\verilog\DE0_Nano_Basic_Computer.sof
// Tipo procesador: Nios V/g, nombre: intel_niosv_g_1
//

#include <stdio.h>
#include <altera_avalon_mutex.h>
#include <system.h>

// RAM para sincronizacion entre hilos, tamano total RAM= 20 bytes
// Todas las variables se encuentran en una linea de cache (32 bytes)
//
volatile unsigned int * message_buffer_ptr 		= (unsigned int *) MESSAGE_BUFFER_RAM_BASE;
volatile unsigned int * message_buffer_ptr_join = (unsigned int *) (MESSAGE_BUFFER_RAM_BASE+4);
volatile unsigned int * message_buffer_ptr_fork = (unsigned int *) (MESSAGE_BUFFER_RAM_BASE+8);
volatile unsigned int * message_buffer_threads  = (unsigned int *) (MESSAGE_BUFFER_RAM_BASE+12);
volatile unsigned int * message_buffer_Niter    = (unsigned int *) (MESSAGE_BUFFER_RAM_BASE+16);

// Zona de memoria compartida para matriz A y vectores x, y
volatile int * A	= (int *) 0x100000; 	// 16x16x4=1KiB: 0x100000 - 0x1003FF
volatile int * x 	= (int *) 0x100400; 	// 16x1 x4=64 B: 0x100400 - 0x10043F
volatile int * y	= (int *) 0x100800; 	// 16x1 x4=64 B: 0x100800 - 0x10083F
// C_DEL se utiliza para hacer un borrado completo de la dCache
volatile int * A_DEL= (int *) 0x10000; // 0x108000 = 0x100000 + 0x8000 (32 KB)

#define m 16 					// numero de columnas de las matrices
#define n 16 					// numero de filas de las matrices

int rank = 1; 					// hilo esclavo para nucleo= CPU2

#define size_dCache ALT_CPU_DCACHE_SIZE 	// tamano de la dCache, en system.h

// Flush de la dCache del esclavo:
// el contenido de la dCache se guarda en memoria principal
void flush_dCache(void){
// Se ejecuta solo cuando el tamano de dCache no es nulo
// Se supone que el tamaño de dCache es 4 KiB= 32 x 32 x 4 bytes
// Se supone que el tamano de bloque es de 32 bytes, 8 palabras
   if (size_dCache > 0) {
	   int i, j, Nfila=32, Npauta=8;
	   for (i = 0; i < Nfila; i++){
		   for(j = 0; j < Nfila; j+=Npauta){
			   A_DEL[i*Nfila+j] = 0.0;
		   }
	   }
	}
}

// main : programa principal del hilo esclavo
//
int main()
{
	int message_buffer_val 		= 0x0;  // variable local, copia de variable global
	int message_buffer_val_fork 	= 0x0;  // variable local, copia de variable global
	int message_buffer_val_join 	= 0x0;  // variable local, copia de variable global
	int thread_count 		= 0;	// variable local, copia de variable global
	int Niter		 	= 0;	// variable local, copia de variable global
	*(message_buffer_ptr_fork)	|= 0;	// no hace nada, pero es necesario inicializar puntero porque si no se cuelga cuando se usa Nios II/s

  	 // direccion del dispositivo mutex de exclusion mutua 
	alt_mutex_dev* mutex = altera_avalon_mutex_open("/dev/message_buffer_mutex");
	//
	// FORK - Sincronizacion de Distribucion
	// Esclavo inicializa variables compartidas: *(message_buffer_ptr_fork) |= 2
	// cuando maestro inicializa : *(message_buffer_ptr) = 0x15
	// Si el maestro observa que ambos hilos estan sincronizados, maestro inicializa *(message_buffer_ptr) = 5
	// Ademas, el siguiente while se usa para leer:
	//	  thread_count 	: numero de hilos activados
	//	  Niter		: numero de iteraciones del computo
	//
	while(message_buffer_val != 5) {
		altera_avalon_mutex_lock(mutex,2);					// bloquea mutex 

		message_buffer_val 	= *(message_buffer_ptr); 			// lee valor almacenado en RAM 
		thread_count		= *(message_buffer_threads);			// lee valor almacenado en RAM
		Niter			= *(message_buffer_Niter);			// lee valor almacenado en RAM

		if(message_buffer_val == 15 && thread_count == 2) {
			message_buffer_val_fork 	= *(message_buffer_ptr_fork); 	// lee valor almacenado en RAM 
			message_buffer_val_fork 	|= 2;				// inicializa variable compartida
			*(message_buffer_ptr_fork) 	= message_buffer_val_fork;	// escribe valor en RAM
		}

		altera_avalon_mutex_unlock(mutex); 					// libera mutex 
	}
	//
	// COMPUTO ESCLAVO - Operacion Matriz x Vector - repetido Niter veces
	// 2 hilos: cada hilo calcula la mitad de elementos del vector resultado: y
	// Hilo esclavo: la mitad inferior de la matriz A
	//
	int i, j, k1, iteraciones = 0, dumy;
	int local_n 	 = n / thread_count;
	int my_first_row = rank * local_n;		 	// 1a fila asignada a este hilo
	int my_last_row  = (rank+1) * local_n - 1;  		// ultima fila asignada a este hilo

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
	// se obliga a actualizar la memoria principal desde la dCache de CPU2
	// para que el otro procesador, CPU, pueda leer estos resultados
	flush_dCache();
	
	//
	// JOIN - Sincronizacion de union
	// Esclavo inicializa variable compartidas:
	//    *(message_buffer_ptr_join) |= 2
	//
	while(message_buffer_val != 6 && thread_count == 2) {
		altera_avalon_mutex_lock(mutex,2);				// bloquea mutex 

		message_buffer_val 		= *(message_buffer_ptr); 	// lee valor de variable compartida 

		message_buffer_val_join 	= *(message_buffer_ptr_join); 	// lee valor de variable compartida 
		message_buffer_val_join 	|= 2;				// indica que hilo esclavo ha llegado a JOIN
		*(message_buffer_ptr_join) 	= message_buffer_val_join;	// escribe valor en RAM

		altera_avalon_mutex_unlock(mutex); 				// libera mutex 
	}

  	return 0;
}
