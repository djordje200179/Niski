#pragma once

#include <stdbool.h>
#include <stdint.h>
#include "thread_status.h"

struct kmutex {
	struct kthread* owner;
	bool recursive;
	uint16_t lock_count;

	struct kthread* queue_head;
	struct kthread* queue_tail;
};

struct kmutex* kmutex_create(bool recursive);
void kmutex_lock_current(struct kmutex* mutex);
void kmutex_lock(struct kmutex* mutex, struct kthread* thread);
bool kmutex_try_lock_current(struct kmutex* mutex);
enum kthread_status kmutex_unlock(struct kmutex* mutex);
void kmutex_destroy(struct kmutex* mutex);

enum kmutex_mode {
	KMUTEX_MODE_NORMAL = 0b00,
	KMUTEX_MODE_TIMED = 0b01,
	KMUTEX_MODE_RECURSIVE = 0b10
};