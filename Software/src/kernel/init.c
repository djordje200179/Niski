#include "kernel/sync/thread.h"
#include "kernel/mem_alloc/heap_allocator.h"
#include "devices/lcd.h"
#include <stddef.h>

void init() {
	kheap_init();
	lcd_init();

	void main();
	main();
}