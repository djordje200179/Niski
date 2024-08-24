#include "kernel/sync/thread.h"
#include "kernel/sync/thread_local.h"
#include "kernel/sync/scheduler.h"
#include "kernel/mem_alloc/heap_allocator.h"
#include "devices/dma.h"

#define KTHREAD_STACK_SIZE 0x1000

static struct kthread kthread_main = {
	.stack = NULL,
	.tdata = NULL,
	.state = KTHREAD_STATE_RUNNING,
	.next = NULL,
	.waiting_on = NULL
};

struct kthread* kthread_current = &kthread_main;

static void* kthread_allocate_tdata() {
	extern char TDATA_START, TDATA_END, TBSS_START, TBSS_END;

	size_t tdata_size = &TDATA_END - &TDATA_START;
	size_t tbss_size = &TBSS_END - &TBSS_START;

	void* tdata = kheap_alloc(tdata_size + tbss_size);
	if (!tdata)
		return NULL;

	dma_copy(&TDATA_START, tdata, tdata_size, true);
	dma_fill(tdata + tdata_size, tbss_size, 0, true);

	return tdata;
}

struct kthread* kthread_create(int (*function)(void*), void* arg, bool supervisor_mode) {
	struct kthread* thread = kheap_alloc(sizeof(struct kthread));
	if (!thread)
		return NULL;

	uint32_t* stack = kheap_alloc(KTHREAD_STACK_SIZE);
	if (!stack) {
		kheap_dealloc(thread);
		return NULL;
	}

	thread->stack = stack;
	thread->context.regs[REG_SP] = (uint32_t)(&(thread->stack[KTHREAD_STACK_SIZE / 4]));
	
	void* tdata = kthread_allocate_tdata();
	if (!tdata) {
		kheap_dealloc(thread->stack);
		kheap_dealloc(thread);
		return NULL;
	}
	
	thread->tdata = tdata;
	thread->context.regs[REG_TP] = (uint32_t)tdata;

	uint32_t thread_status;
	__asm__ volatile("csrr %0, sstatus" : "=r"(thread_status));
	if (supervisor_mode)
		thread_status |= 0b1 << 8;
	else
		thread_status &= ~(0b1 << 8);
	thread->context.status = thread_status;
	
	thread->local_data_head = NULL;

	thread->context.pc = (uint32_t*)function;
	thread->context.regs[REG_A0] = (uint32_t)arg;
	
	_Noreturn void thrd_exit(int res);
	thread->context.regs[REG_RA] = (uint32_t)thrd_exit;

	thread->state = KTHREAD_STATE_READY;
	thread->next = NULL;

	return thread;
}

void kthread_stop() {
	//kthread_destroy(kthread_current);
	kthread_current = NULL;

	kthread_dispatch();
}

void kthread_dispatch() {
	struct kthread* prev_thread = kthread_current;

	if (prev_thread && prev_thread->state != KTHREAD_STATE_BLOCKED && prev_thread != &kthread_main)
		kscheduler_enqueue(prev_thread);
		
	struct kthread* next_thread = kscheduler_dequeue();
	if (!next_thread)
		next_thread = &kthread_main;

	kthread_current = next_thread;
	next_thread->state = KTHREAD_STATE_RUNNING;
}

static void kthread_clean_td(struct kthread* thread) {
	for (struct kthread_ld* local_data = thread->local_data_head; local_data;) {
		struct kthread_ld* next_data = local_data->next_data;

		if (local_data->prev_data)
			local_data->prev_data->next_data = local_data->next_data;
		else
			local_data->storage->data_head = local_data->next_data;

		if (local_data->next_data)
			local_data->next_data->prev_data = local_data->prev_data;

		if (local_data->storage->dtor)
			local_data->storage->dtor(local_data->data);

		kheap_dealloc(local_data);

		local_data = next_data;
	}
}

void kthread_destroy(struct kthread* thread) {
	kthread_clean_td(thread);

	if (thread->stack)
		kheap_dealloc(thread->stack);

	if (thread->tdata)
		kheap_dealloc(thread->tdata);

	kheap_dealloc(thread);
}