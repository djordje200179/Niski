#include "kernel/thread_local.h"
#include "kernel/mem_allocator.h"
#include "kernel/thread.h"
#include <stddef.h>

struct kthread_ls* kthread_ls_create(void (*destructor)(void*)) {
	struct kthread_ls* local_storage = kmem_alloc(sizeof(struct kthread_ls));
	if (!local_storage)
		return NULL;

	local_storage->destructor = destructor;
	local_storage->data_head = NULL;

	return local_storage;
}

void kthread_ls_destroy(struct kthread_ls* local_storage) {
	for (struct kthread_ld* local_data = local_storage->data_head; local_data;) {
		struct kthread_ld* next_data = local_data->next_thread;

		if (local_data->prev_thread)
			local_data->prev_thread->next_thread = local_data->next_thread;
		else
			local_data->thread->local_data_head = local_data->next_thread;

		if (local_data->next_thread)
			local_data->next_thread->prev_thread = local_data->prev_thread;

		kmem_dealloc(local_data);

		local_data = next_data;
	}

	kmem_dealloc(local_storage);
}

void* kthread_ls_get(struct kthread_ls* local_storage, struct kthread* thread) {
	for (struct kthread_ld* local_data = thread->local_data_head; local_data; local_data = local_data->next_data) {
		if (local_data->storage == local_storage)
			return local_data->data;
	}

	return NULL;
}

enum kthread_status kthread_ls_set(struct kthread_ls* local_storage, struct kthread* thread, void* data) {
	for (struct kthread_ld* local_data = thread->local_data_head; local_data; local_data = local_data->next_data) {
		if (local_data->storage == local_storage) {
			local_data->data = data;
			return KTHREAD_STATUS_SUCCESS;
		}
	}

	struct kthread_ld* local_data = kmem_alloc(sizeof(struct kthread_ld));
	if (!local_data)
		return KTHREAD_STATUS_NOMEM;

	local_data->storage = local_storage;
	local_data->thread = thread;
	local_data->data = data;

	local_data->prev_data = NULL;
	local_data->next_data = thread->local_data_head;
	if (thread->local_data_head)
		thread->local_data_head->prev_data = local_data;
	thread->local_data_head = local_data;

	local_data->prev_thread = NULL;
	local_data->next_thread = local_storage->data_head;
	if (local_storage->data_head)
		local_storage->data_head->prev_thread = local_data;
	local_storage->data_head = local_data;

	return KTHREAD_STATUS_SUCCESS;
}