#pragma once

#include <stdbool.h>
#include <stdint.h>
#include "thread_status.h"

struct kmutex {
	struct kthread* owner;
	struct kthread* queue_head;
	struct kthread* queue_tail;

	uint16_t lock_count;
	bool recursive;
};

struct kmutex* kmutex_create(bool recursive);
void kmutex_lock(struct kmutex* mutex, struct kthread* thread);
bool kmutex_try_lock(struct kmutex* mutex, struct kthread* thread);
enum kthread_status kmutex_unlock(struct kmutex* mutex, struct kthread* thread);
void kmutex_destroy(struct kmutex* mutex);

enum kmutex_mode {
	KMUTEX_MODE_NORMAL = 0b00,
	KMUTEX_MODE_TIMED = 0b01,
	KMUTEX_MODE_RECURSIVE = 0b10
};