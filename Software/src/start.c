#include "devices/ssds.h"
#include <stddef.h>

void start() {
	uint16_t value;
	__asm volatile("mv %0, a7" : "=r"(value));

	ssds_on();
	ssds_set_number(value);
}