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

void kcond_wait(struct kcond* condition, struct kmutex* mutex, struct kthread* thread) {
	thread->state = KTHREAD_STATE_BLOCKED;
	thread->waiting_on = mutex;

	if (!condition->queue_head)
		condition->queue_head = thread;
	else
		condition->queue_tail->next = thread;
	
	condition->queue_tail = thread;

	kmutex_unlock(mutex, thread);
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
	for (struct kthread* thread = condition->queue_head; thread; ) {
		struct kthread* next = thread->next;

		kthread_destroy(thread);

		thread = next;
	}

	kmem_dealloc(condition);
}