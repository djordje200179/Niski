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

int first_thread(void* arg) {
	calculate_ok();
	leds_set_single(0, errno == 0);

	calculate_faulty();
	leds_set_single(1, errno == 0);

	calculate_ok();
	leds_set_single(2, errno == 0);

	return 0;
}

int second_thread(void* arg) {
	leds_set_single(3, true);

	while(true);

	return 0;
}

void btns_on_0_pressed(void* arg) {
	leds_toggle_single(0);
}

void btns_on_1_pressed(void* arg) {
	leds_toggle_single(1);
}

void btns_on_2_pressed(void* arg) {
	leds_toggle_single(2);
}

void btns_on_3_pressed(void* arg) {
	leds_toggle_single(3);
}

void main() {
	leds_on();
	ssds_on();

	puts("Main started.\n");

	ssds_set_dec_num(1234);

	thrd_t handles[2];
	thrd_create(&handles[0], first_thread, NULL);
	thrd_create(&handles[1], second_thread, NULL);

	puts("Threads created.");
}