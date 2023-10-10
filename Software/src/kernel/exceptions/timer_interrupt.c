#include "devices/buzzer.h"
#include "devices/ssds.h"
#include <stdint.h>
#include <time.h>
#include <stddef.h>

void handle_timer_interrupt() {
	time_t seconds = time(NULL);
	ssds_set_dec_number(seconds);

	uint32_t timer_mask = 0b100000;
	__asm__ ("csrc sip, %0" : : "r" (timer_mask));
}