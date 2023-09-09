#include "kernel/thread.h"
#include "kernel/mutex.h"
#include "kernel/condition.h"
#include "kernel/mem_allocator.h"

struct kcond* kcond_create() {
	struct kcond* condition = kmem_alloc(sizeof(struct kcond));
	if (!condition)
		return NULL;

	condition->queue_head = NULL;
	condition->queue_tail = NULL;

	return condition;
}

void kcond_wait(struct kcond* condition, struct kmutex* mutex) {
	thread_current->state = KTHREAD_STATE_BLOCKED;
	thread_current->waiting_on = mutex;

	if (!condition->queue_head)
		condition->queue_head = thread_current;
	else
		condition->queue_tail->next = thread_current;
	
	condition->queue_tail = thread_current;

	kmutex_unlock(mutex);
	kthread_dispatch();
}

void kcond_signal(struct kcond* condition) {
	if (!condition->queue_head)
		return;

	struct kthread* thread = condition->queue_head;

	condition->queue_head = thread->next;
	if (!condition->queue_head)
		condition->queue_tail = NULL;

	kmutex_lock(thread->waiting_on, thread);
}

void kcond_signal_all(struct kcond* condition) {
	for (struct kthread* thread = condition->queue_head; thread; ) {
		struct kthread* next = thread->next;

		kmutex_lock(thread->waiting_on, thread);

		thread = next;
	}

	condition->queue_head = NULL;
	condition->queue_tail = NULL;
}

void kcond_destroy(struct kcond* condition) {
	kmem_dealloc(condition);
}