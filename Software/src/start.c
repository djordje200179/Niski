#include "devices/ssds.h"
#include <time.h>
#include <stddef.h>

void start() {
	ssds_on();

	time_t last_seconds = 0;
	while (1) {
		time_t seconds = time(NULL);

		if (seconds == last_seconds)
			continue;

		last_seconds = seconds;
		ssds_set_number(seconds);
	}
}