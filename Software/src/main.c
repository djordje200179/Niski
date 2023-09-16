#include <threads.h>
#include <stddef.h>
#include <stdio.h>

int faulty_thread(void* arg) {
	__asm__ volatile("csrw sstatus, 0x00000000");
	return 0;
}

void main() {
	puts("Hello, world!\n");

	thrd_t handle;
	thrd_create(&handle, faulty_thread, NULL);

	puts("Thread created\n");
}