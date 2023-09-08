#include "kernel/thread.h"
#include "kernel/mem_allocator.h"
#include <stddef.h>

void init() {
	kmem_init();
	kthread_init();

	void main();
	main();
}