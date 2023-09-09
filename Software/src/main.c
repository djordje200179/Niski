#include <devices/ssds.h>
#include <stddef.h>
#include <stdbool.h>
#include <threads.h>

int digit_thread(void* arg) {
	uintptr_t id = (uintptr_t)arg;

	ssds_set_digit(id, 2);
	
	return 0;
}

void main() {
	ssds_on();

	ssds_set_digit(3, 0);

	thrd_t threads[4];

	uint8_t created = 0;
	for (int i = 0; i < 2; i++) {
		int res = thrd_create(&threads[i], digit_thread, (void*)(uintptr_t)i);
		if (res == thrd_success)
			created++;
		else
			ssds_set_digit(2, res);

		ssds_set_digit(3, created);
	}
}