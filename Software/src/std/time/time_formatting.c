#include <time.h>
#include <stddef.h>

int timespec_get(struct timespec* ts, int base) {
	switch (base) {
	case TIME_UTC:
		return 0;
	case TIME_MONOTONIC: {
		time_t seconds = time(NULL);
		clock_t ticks = clock();

		time_t nanoseconds = (ticks - (seconds * CLOCKS_PER_SEC)) * (1000000000 / CLOCKS_PER_SEC);
		
		ts->tv_sec = seconds;
		ts->tv_nsec = nanoseconds;

		return TIME_MONOTONIC;
	}
	default:
		return 0;
	}
}

int timespec_getres(struct timespec* ts, int base) {
	switch (base) {
	case TIME_UTC:
		return 0;
	case TIME_MONOTONIC:
		ts->tv_sec = 0;
		ts->tv_nsec = 1000000000 / CLOCKS_PER_SEC;
		
		return TIME_MONOTONIC;
	default:
		return 0;
	}
}