#include "kernel/sync/mutex.h"
#include "kernel/mem_alloc/heap_allocator.h"
#include "kernel/sync/thread.h"
#include "kernel/sync/scheduler.h"
#include <stddef.h>

struct kmutex* kmutex_create(bool recursive) {
	struct kmutex* mutex = kheap_alloc(sizeof(struct kmutex));
	if (!mutex)
		return NULL;

	mutex->owner = NULL;
	mutex->recursive = recursive;
	mutex->lock_count = 0;
	mutex->queue_head = NULL;
	mutex->queue_tail = NULL;

	return mutex;
}

bool kmutex_try_lock(struct kmutex* mutex, struct kthread* thread) {
	if (mutex->owner)
		return false;

	mutex->owner = thread;
	mutex->lock_count = 1;

	return true;
}

void kmutex_lock(struct kmutex* mutex, struct kthread* thread) {
	if (!mutex->owner) {
		mutex->owner = thread;
		mutex->lock_count = 1;

		return;
	}

	if (mutex->owner == thread) {
		if (mutex->recursive)
			mutex->lock_count++;

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

enum kthread_status kmutex_unlock(struct kmutex* mutex, struct kthread* thread) {
	if (mutex->owner != thread)
		return KTHREAD_STATUS_ERROR;

	mutex->lock_count--;

	if (mutex->recursive && mutex->lock_count > 0)
		return KTHREAD_STATUS_SUCCESS;

	if (!mutex->queue_head) {
		mutex->owner = NULL;
		return KTHREAD_STATUS_SUCCESS;
	}

	mutex->lock_count = 1;

	struct kthread* next_thread = mutex->queue_head;

	mutex->queue_head = next_thread->next;
	if (!mutex->queue_head)
		mutex->queue_tail = NULL;

	mutex->owner = next_thread;

	kscheduler_enqueue(next_thread);

	return KTHREAD_STATUS_SUCCESS;
}

void kmutex_destroy(struct kmutex* mutex) {
	for (struct kthread* thread = mutex->queue_head; thread; ) {
		struct kthread* next = thread->next;

		kthread_destroy(thread);

		thread = next;
	}

	kheap_dealloc(mutex);
}