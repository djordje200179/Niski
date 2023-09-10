#include <devices/ssds.h>
#include <devices/leds.h>
#include <stddef.h>
#include <stdbool.h>
#include <threads.h>

tss_t tss;

int digit_thread(void* arg) {
	uintptr_t id = (uintptr_t)arg;
	
	ssds_set_digit(id, 0);

	tss_set(tss, (void*)5);

	ssds_set_digit(id, 1);

	thrd_yield();

	ssds_set_digit(id, 2);

	uintptr_t value = (uintptr_t)tss_get(tss);

	ssds_set_digit(id, value);
	
	return 0;
}

void main() {
	leds_on();
	ssds_on();

	ssds_set_digit(0, 0);

	int tss_status = tss_create(&tss, NULL);
	leds_set_single(0, tss_status == thrd_success);

	ssds_set_digit(0, 1);

	thrd_t thread;
	int thrd_status = thrd_create(&thread, digit_thread, (void*)2);
	leds_set_single(1, thrd_status == thrd_success);

	ssds_set_digit(0, 2);

	thrd_yield();

	ssds_set_digit(0, 3);

	tss_set(tss, (void*)7);

	ssds_set_digit(0, 4);

	thrd_yield();

	ssds_set_digit(0, 5);

	uintptr_t value = (uintptr_t)tss_get(tss);

	ssds_set_digit(0, value);
}