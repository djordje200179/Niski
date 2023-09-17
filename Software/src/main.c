#include <threads.h>
#include <stddef.h>
#include <errno.h>
#include <stdio.h>
#include <devices/leds.h>
#include <devices/ssds.h>

static void calculate_ok() {
	errno = 0;
}

static void calculate_faulty() {
	errno = 1;
}

int faulty_thread(void* arg) {
	leds_set_single(0, errno == 0);

	calculate_ok();
	leds_set_single(1, errno == 0);

	calculate_faulty();
	leds_set_single(2, errno == 0);

	calculate_ok();
	leds_set_single(3, errno == 0);

	return 0;
}

void main() {
	leds_on();
	//ssds_on();
	
	puts("Main started.\n");

	thrd_t handle;
	thrd_create(&handle, faulty_thread, NULL);

	puts("Thread created.");

	//ssds_set_dec_number(1234);
}