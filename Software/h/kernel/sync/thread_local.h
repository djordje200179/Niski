#pragma once

#include "common/threads.h"

struct kthread_ls {
	void (*dtor)(void*);

	struct kthread_ld* data_head;
};

struct kthread_ld {
	struct kthread_ls* storage;
	struct kthread* thread;

	void* data;

	struct kthread_ld* prev_thread;
	struct kthread_ld* next_thread;

	struct kthread_ld* prev_data;
	struct kthread_ld* next_data;
};

struct kthread_ls* kthread_ls_create(void (*dtor)(void*));
void kthread_ls_destroy(struct kthread_ls* local_storage);

struct kthread;

void* kthread_ls_get(struct kthread_ls* local_storage, struct kthread* thread);
enum __thread_status kthread_ls_set(struct kthread_ls* local_storage, struct kthread* thread, void* data);