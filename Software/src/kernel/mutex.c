#include "kernel/mutex.h"
#include "kernel/mem_allocator.h"
#include "kernel/thread.h"
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

void kmutex_lock_current(struct kmutex* mutex) {
	kmutex_lock(mutex, thread_current);
	kthread_dispatch();
}

void kmutex_lock(struct kmutex* mutex, struct kthread* thread) {
	if (!mutex->owner) {
		mutex->owner = thread;
		return;
	}

	thread->state = KTHREAD_STATE_BLOCKED;
	thread->waiting_on = mutex;

	if (!mutex->queue_head)
		mutex->queue_head = thread;
	else
		mutex->queue_tail->next = thread;
	
	mutex->queue_tail = thread;
}

void kmutex_unlock(struct kmutex* mutex) {
	if (mutex->queue_head) {
		struct kthread* thread = mutex->queue_head;

		mutex->queue_head = thread->next;
		if (!mutex->queue_head)
			mutex->queue_tail = NULL;

		mutex->owner = thread;

		kthread_enqueue(thread);
	} else {
		mutex->owner = NULL;
	}
}

void kmutex_destroy(struct kmutex* mutex) {
	for (struct kthread* thread = mutex->queue_head; thread; ) {
		struct kthread* next = thread->next;

		kthread_destroy(thread);

		thread = next;
	}

	kmem_dealloc(mutex);
}