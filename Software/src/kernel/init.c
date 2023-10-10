#include "kernel/mem_alloc/heap_allocator.h"
#include "kernel/sync/thread.h"
#include "kernel/sync/scheduler.h"
#include "devices/lcd.h"

void init() {
	kheap_init();
	lcd_init();

	void main();
	struct kthread* user_thread = kthread_create((void*)main, NULL, false);
	kscheduler_enqueue(user_thread);
}