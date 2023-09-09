#include "kernel/mutex.h"
#include "kernel/mem_allocator.h"
#include <stddef.h>

struct kmutex* kmutex_create() {
	struct kmutex* mutex = kmem_alloc(sizeof(struct kmutex));
	if (!mutex)
		return NULL;

	mutex->owner = NULL;
	mutex->queue_head = NULL;
	mutex->queue_tail = NULL;

	return mutex;
}

void kmutex_lock(struct kmutex* mutex) {
	if (!mutex->owner) {
		mutex->owner = thread_current;
		return;
	}

	thread_current->state = KTHREAD_STATE_BLOCKED;

	if (!mutex->queue_head)
		mutex->queue_head = thread_current;
	else
		mutex->queue_tail->next = thread_current;
	
	mutex->queue_tail = thread_current;

	thread_current->next = NULL;

	kthread_dispatch();
}

void kmutex_unlock(struct kmutex* mutex) {
	if (mutex->queue_head) {
		struct kthread* thread = mutex->queue_head;

		mutex->queue_head = thread->next;
		if (!mutex->queue_head)
			mutex->queue_tail = NULL;

		mutex->owner = thread;

		thread->next = NULL;
		kthread_enqueue(thread);
	} else {
		mutex->owner = NULL;
	}
}

void kmutex_destroy(struct kmutex* mutex) {
	kmem_dealloc(mutex);
}