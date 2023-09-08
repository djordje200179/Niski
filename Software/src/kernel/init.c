#include "kernel/thread.h"
#include <stddef.h>

static void threads_init() {
	kthread_init(&thread_main, NULL, NULL, NULL);
	thread_current = &thread_main;
	thread_main.state = KTHREAD_STATE_RUNNING;
}

void init() {
	threads_init();

	void main();
	main();
}