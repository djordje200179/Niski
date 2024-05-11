#pragma once

struct kcond {
	struct kthread* queue_head;
	struct kthread* queue_tail;
};

struct kcond* kcond_create();
void kcond_wait(struct kcond* cond, struct kmutex* mutex, struct kthread* thread);
void kcond_signal(struct kcond* cond);
void kcond_signal_all(struct kcond* cond);
void kcond_destroy(struct kcond* cond);