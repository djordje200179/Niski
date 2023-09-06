#include "devices/ssds.h"
#include "devices/leds.h"
#include "cpu/counters.h"

void start() {
	ssds_on();
	leds_on();

	leds_set_single(3, 1);
	ssds_set_digit(0, 2);
	leds_set_single(2, 1);
	// uint64_t last_seconds = 0;
	// while (1) {
	// 	uint64_t seconds = get_cpu_seconds();

	// 	if (seconds == last_seconds)
	// 		continue;

	// 	last_seconds = seconds;
	// 	ssds_set_number(seconds);
	// }
}