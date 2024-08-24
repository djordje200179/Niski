#pragma once

#include <stdbool.h>
#include <stdint.h>
#include "common/threads.h"

struct kmutex {
	struct kthread* owner;
	struct kthread* queue_head;
	struct kthread* queue_tail;

	uint16_t lock_count;
	bool recursive;
};

void kmutex_init(struct kmutex* mutex, bool recursive);
void kmutex_lock(struct kmutex* mutex, struct kthread* thread);
bool kmutex_try_lock(struct kmutex* mutex, struct kthread* thread);
enum __thread_status kmutex_unlock(struct kmutex* mutex, struct kthread* thread);
void kmutex_destroy(struct kmutex* mutex);