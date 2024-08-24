#pragma once

#include <stddef.h>

struct kcond {
	struct kthread* queue_head;
	struct kthread* queue_tail;
};

static inline void kcond_init(struct kcond* cond) {
	cond->queue_head = NULL;
	cond->queue_tail = NULL;
}

void kcond_wait(struct kcond* cond, struct kmutex* mutex, struct kthread* thread);
void kcond_signal(struct kcond* cond, bool enqueue);
void kcond_signal_all(struct kcond* cond);
void kcond_destroy(struct kcond* cond);