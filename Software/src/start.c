#include "devices/ssds.h"
#include "cpu/counters.h"

void start() {
	ssds_on();

	while (true) {
		uint64_t seconds = get_cpu_seconds();
		ssds_set_digit(3, seconds);

		for(volatile int i = 0; i < 200000; i++);
	}
}