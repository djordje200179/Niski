#include "kernel/mutex.h"
#include "kernel/mem_allocator.h"
#include "kernel/thread.h"
#include <stddef.h>

struct kmutex* kmutex_create(bool recursive) {
	struct kmutex* mutex = kmem_alloc(sizeof(struct kmutex));
	if (!mutex)
		return NULL;

	mutex->owner = NULL;
	mutex->recursive = recursive;
	mutex->lock_count = 0;
	mutex->queue_head = NULL;
	mutex->queue_tail = NULL;

	return mutex;
}

void kmutex_lock_current(struct kmutex* mutex) {
	kmutex_lock(mutex, thread_current);
	kthread_dispatch();
}

bool kmutex_try_lock_current(struct kmutex* mutex) {
	if (mutex->owner)
		return false;

	mutex->owner = thread_current;
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

enum kthread_status kmutex_unlock(struct kmutex* mutex) {
	if (mutex->owner != thread_current)
		return KTHREAD_STATUS_ERROR;

	mutex->lock_count--;

	if (mutex->recursive && mutex->lock_count > 0)
		return KTHREAD_STATUS_SUCCESS;

	if (!mutex->queue_head) {
		mutex->owner = NULL;
		return KTHREAD_STATUS_SUCCESS;
	}

	mutex->lock_count = 1;

	struct kthread* thread = mutex->queue_head;

	mutex->queue_head = thread->next;
	if (!mutex->queue_head)
		mutex->queue_tail = NULL;

	mutex->owner = thread;

	kthread_enqueue(thread);

	return KTHREAD_STATUS_SUCCESS;
}

void kmutex_destroy(struct kmutex* mutex) {
	for (struct kthread* thread = mutex->queue_head; thread; ) {
		struct kthread* next = thread->next;

		kthread_destroy(thread);

		thread = next;
	}

	kmem_dealloc(mutex);
}