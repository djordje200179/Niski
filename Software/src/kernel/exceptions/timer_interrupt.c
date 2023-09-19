#include "devices/ssds.h"

static int cnt = 0;

void handle_timer_interrupt() {
	cnt++;

	ssds_set_dec_number(cnt);

	uint32_t timer_mask = 0b100000;
	__asm__ ("csrc sip, %0" : : "r" (timer_mask));
}