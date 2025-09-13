/*
 * Lab 4 - Tutorial-2
 *
 * Source code: dualCoreNVm_app1_semaforo_1
 *
 * Program for slave thread. Shared buffer is repetitively updated using a variable that is increased in sucessive iterations.
 *
 * Domingo Benitez, August 2025
 */

#include "stdio.h"

#include <stdio.h>
#include <system.h>
#include <altera_avalon_mutex.h>

int main(){

// address memory for a shared message buffer: 0x 400 0000
volatile int * message_buffer_ptr  = (int *) MESSAGE_BUFFER_RAM_BASE;	

/* driver for mutex controller */
alt_mutex_dev* mutex = altera_avalon_mutex_open("/dev/message_buffer_mutex");

int message_buffer_val 	= 0x0;

while(1) {
   /* Slave core wants to lock the mutex controller, using an ID 1with value 2 */
   altera_avalon_mutex_lock(mutex,2);

    /* save message_buffer_val variable in the message buffer */
   *(message_buffer_ptr) = message_buffer_val; 

   altera_avalon_mutex_unlock(mutex); /* free mutex */

   /* shared variable message_buffer_val is increased */
   message_buffer_val++;
}

return 0;
}