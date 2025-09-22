/*
 * Lab 4 - Tutorial-2
 *
 * Source code: dualCoreNVm_app1_semaforo_0
 *
 * Program for master thread. Shared buffer is repetitively read and its content is shown on display using printf. Shared buffer is updated by the slave thread.
 *
 * Domingo Benitez, August 2025
 */
#include <stdio.h>
#include <system.h>
#include <altera_avalon_mutex.h>
#include <unistd.h>

int main(){

/* address memory for a shared message buffer: 0x 0820 0000 */
volatile int * message_buffer_ptr = (int *) MESSAGE_BUFFER_RAM_BASE;	

printf("Hello, I am Semaforo_0\n");

/* driver for mutex controller */
alt_mutex_dev* mutex = altera_avalon_mutex_open("/dev/message_buffer_mutex");

int message_buffer_val 	= 0x0;
int iterations 		= 0x0;

while(1) {
	iterations++;

	/* Master core wants to lock the mutex controller, using an ID with value 1 */
	altera_avalon_mutex_lock(mutex,1);

	message_buffer_val = *(message_buffer_ptr); /* read the value saved in shared buffer */

	altera_avalon_mutex_unlock(mutex); /* free mutex */

	printf("CPU - iteration: %i - message_buffer_val: %08X\n", iterations, message_buffer_val); 

	usleep(4000000); /* wait 4 seg = 4000000 useg */
}
return 0;
}