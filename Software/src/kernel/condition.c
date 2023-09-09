#include "kernel/thread.h"
#include "kernel/mutex.h"
#include "kernel/condition.h"
#include "kernel/mem_allocator.h"

struct kcondition* kcondition_create() {
	struct kcondition* condition = kmem_alloc(sizeof(struct kcondition));
	if (!condition)
		return NULL;

	condition->queue_head = NULL;
	condition->queue_tail = NULL;

	return condition;
}

void kcondition_wait(struct kcondition* condition, struct kmutex* mutex) {
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

void kcondition_signal(struct kcondition* condition) {
	if (!condition->queue_head)
		return;

	struct kthread* thread = condition->queue_head;

	condition->queue_head = thread->next;
	if (!condition->queue_head)
		condition->queue_tail = NULL;

	kmutex_lock(thread->waiting_on, thread);
}

void kcondition_signal_all(struct kcondition* condition) {
	for (struct kthread* thread = condition->queue_head; thread; ) {
		struct kthread* next = thread->next;

		kmutex_lock(thread->waiting_on, thread);

		thread = next;
	}

	condition->queue_head = NULL;
	condition->queue_tail = NULL;
}

void kcondition_destroy(struct kcondition* condition) {
	kmem_dealloc(condition);
}