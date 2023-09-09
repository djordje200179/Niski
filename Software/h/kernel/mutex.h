#pragma once

#include <stdbool.h>

struct kmutex {
	struct kthread* owner;

	struct kthread* queue_head;
	struct kthread* queue_tail;
};

struct kmutex* kmutex_create();
void kmutex_lock_current(struct kmutex* mutex);
void kmutex_lock(struct kmutex* mutex, struct kthread* thread);
bool kmutex_try_lock_current(struct kmutex* mutex);
void kmutex_unlock(struct kmutex* mutex);
void kmutex_destroy(struct kmutex* mutex);