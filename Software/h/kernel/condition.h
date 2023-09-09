#pragma once

struct kcondition {
	struct kthread* queue_head;
	struct kthread* queue_tail;
};

struct kcondition* kcondition_create();
void kcondition_wait(struct kcondition* condition, struct kmutex* mutex);
void kcondition_signal(struct kcondition* condition);
void kcondition_signal_all(struct kcondition* condition);
void kcondition_destroy(struct kcondition* condition);