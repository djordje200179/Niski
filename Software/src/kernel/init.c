#include "kernel/sync/thread.h"
#include "kernel/mem_alloc/heap_allocator.h"
#include <stddef.h>

void init() {
	kheap_init();

	void main();
	main();
}