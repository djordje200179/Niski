#include "kernel/sync/scheduler.h"
#include "kernel/sync/thread.h"
#include <stddef.h>

static struct kthread* kscheduler_head = NULL;
static struct kthread* kscheduler_tail = NULL;

void kscheduler_enqueue(struct kthread* thread) {
	thread->state = KTHREAD_STATE_READY;
	thread->next = NULL;
	thread->waiting_on = NULL;

	if (kscheduler_head)
		kscheduler_tail->next = thread;
	else
		kscheduler_head = thread;

	kscheduler_tail = thread;
}

struct kthread* kscheduler_dequeue() {
	if (!kscheduler_head)
		return NULL;

	struct kthread* thread = kscheduler_head;

	kscheduler_head = thread->next;
	if (!kscheduler_head)
		kscheduler_tail = NULL;

	thread->next = NULL;
	thread->waiting_on = NULL;

	return thread;
}