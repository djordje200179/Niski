#include "kernel/sync/thread.h"
#include "kernel/sync/mutex.h"
#include "kernel/sync/condition.h"
#include "kernel/sync/scheduler.h"

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

void kcond_signal(struct kcond* cond, bool enqueue) {
	if (!cond->queue_head)
		return;

	struct kthread* next_thread = cond->queue_head;

	cond->queue_head = next_thread->next;
	if (!cond->queue_head)
		cond->queue_tail = NULL;

	kmutex_lock(next_thread->waiting_on, next_thread);
	if (enqueue)
		kscheduler_enqueue(next_thread);		
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
}