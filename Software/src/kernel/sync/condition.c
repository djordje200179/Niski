#include "kernel/sync/thread.h"
#include "kernel/sync/mutex.h"
#include "kernel/sync/condition.h"
#include "kernel/mem_alloc/heap_allocator.h"

struct kcond* kcond_create() {
	struct kcond* cond = kheap_alloc(sizeof(struct kcond));
	if (!cond)
		return NULL;

	cond->queue_head = NULL;
	cond->queue_tail = NULL;

	return cond;
}

void kcond_wait(struct kcond* cond, struct kmutex* mutex, struct kthread* thread) {
	thread->state = KTHREAD_STATE_BLOCKED;
	thread->waiting_on = mutex;

	if (!cond->queue_head)
		cond->queue_head = thread;
	else
		cond->queue_tail->next = thread;

	cond->queue_tail = thread;

	kmutex_unlock(mutex, thread);
}

void kcond_signal(struct kcond* cond) {
	if (!cond->queue_head)
		return;

	struct kthread* thread = cond->queue_head;

	cond->queue_head = thread->next;
	if (!cond->queue_head)
		cond->queue_tail = NULL;

	kmutex_lock(thread->waiting_on, thread);
}

void kcond_signal_all(struct kcond* cond) {
	for (struct kthread* thread = cond->queue_head; thread; ) {
		struct kthread* next = thread->next;

		kmutex_lock(thread->waiting_on, thread);

		thread = next;
	}

	cond->queue_head = NULL;
	cond->queue_tail = NULL;
}

void kcond_destroy(struct kcond* cond) {
	for (struct kthread* thread = cond->queue_head; thread; ) {
		struct kthread* next = thread->next;

		kthread_destroy(thread);

		thread = next;
	}

	kheap_dealloc(cond);
}