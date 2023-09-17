#include <threads.h>
#include <stddef.h>
#include <stdio.h>
#include <errno.h>

void calculate() {
	errno = 0;
}

int faulty_thread(void* arg) {
	calculate();

	if (errno != 0) {
		puts("Error in thread!");
		return 1;
	}

	return 0;
}

void main() {
	puts("Hello, world!\n");

	thrd_t handle;
	thrd_create(&handle, faulty_thread, NULL);
}