#include <threads.h>
#include <stddef.h>
#include <errno.h>
#include <stdio.h>
#include <devices/leds.h>
#include <devices/ssds.h>
#include <devices/btns.h>
#include <signal.h>

static void calculate_ok() { errno = 0; }
static void calculate_faulty() { errno = 1; }

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
	leds_toggle_single(1);

	return 0;
}

static void btn_on_pressed(int signal) { leds_toggle_single(3); }

void main() {
	leds_on();
	ssds_on();

	puts("Main started.\n");

	ssds_set_dec_num(1234);

	signal(SIGBTN0, btn_on_pressed);
	signal(SIGBTN1, btn_on_pressed);
	signal(SIGBTN2, btn_on_pressed);
	signal(SIGBTN3, btn_on_pressed);

	thrd_t handles[2];
	thrd_create(&handles[0], first_thread, NULL);
	thrd_create(&handles[1], second_thread, NULL);

	puts("Created.");


	while(true);
}