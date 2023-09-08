#include <devices/ssds.h>
#include <stddef.h>
#include <threads.h>

int digit_thread(void* arg) {
	ssds_set_digit(2, 2);

	return 0;
}

void main() {
	ssds_on();
	ssds_set_digit(0, 1);

	thrd_t handler;
	int res = thrd_create(&handler, digit_thread, NULL);

	ssds_set_digit(1, res);

	thrd_yield();

	ssds_set_digit(3, 3);
}