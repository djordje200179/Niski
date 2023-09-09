#include <devices/ssds.h>
#include <stddef.h>
#include <stdbool.h>
#include <threads.h>

mtx_t mtx;

int digit_thread(void* arg) {
	uintptr_t id = (uintptr_t)arg;
	
	ssds_set_digit(id, 0);

	mtx_lock(&mtx);

	ssds_set_digit(id, 1);

	mtx_unlock(&mtx);

	ssds_set_digit(id, 2);
	
	return 0;
}

void main() {
	ssds_on();

	ssds_set_digit(0, 0);

	mtx_init(&mtx, mtx_recursive);

	ssds_set_digit(0, 1);

	mtx_lock(&mtx);
	mtx_lock(&mtx);

	ssds_set_digit(0, 2);

	thrd_t thread;
	thrd_create(&thread, digit_thread, (void*)2);

	ssds_set_digit(1, 0);

	thrd_yield();

	ssds_set_digit(1, 1);

	mtx_unlock(&mtx);

	ssds_set_digit(1, 2);
}