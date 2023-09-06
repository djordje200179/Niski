#include "devices/ssds.h"
#include "devices/leds.h"
#include "cpu/counters.h"

void start() {
	ssds_on();

	uint64_t last_seconds = 0;
	while (1) {
		uint64_t seconds = get_cpu_seconds();

		if (seconds == last_seconds)
			continue;

		last_seconds = seconds;
		ssds_set_number(seconds);
	}
}