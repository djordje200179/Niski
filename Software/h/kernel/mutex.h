#pragma once

#include "thread.h"

struct kmutex {
	struct kthread* owner;

	struct kthread* queue_head;
	struct kthread* queue_tail;
};

struct kmutex* kmutex_create();
void kmutex_lock(struct kmutex* mutex);
void kmutex_unlock(struct kmutex* mutex);
void kmutex_destroy(struct kmutex* mutex);