#include "devices/buzzer.h"
#include <stdint.h>

void handle_timer_interrupt() {
	buzzer_on();
	buzzer_set(true);

	uint32_t timer_mask = 0b100000;
	__asm__ ("csrc sip, %0" : : "r" (timer_mask));
}