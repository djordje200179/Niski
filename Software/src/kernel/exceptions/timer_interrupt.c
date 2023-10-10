#include "devices/ssds.h"
#include "kernel/riscv.h"
#include "kernel/exceptions.h"
#include <time.h>
#include <stddef.h>

void handle_timer_interrupt() {
	time_t seconds = time(NULL);
	ssds_set_dec_number(seconds);

	clear_interrupt(TIMER_INTERRUPT);
}