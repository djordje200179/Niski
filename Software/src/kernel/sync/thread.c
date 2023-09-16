#include "kernel/sync/thread.h"
#include "kernel/sync/thread_local.h"
#include "kernel/mem_alloc/heap_allocator.h"

#define KTHREAD_STACK_SIZE 0x1000

static struct kthread thread_main = {
	.stack = NULL,
	.state = KTHREAD_STATE_RUNNING,
	.next = NULL,
	.waiting_on = NULL
}, thread_idle = {
	.stack = NULL,
	.state = KTHREAD_STATE_READY,
	.next = NULL,
	.waiting_on = NULL
};

struct kthread* thread_current = &thread_main;

static struct kthread* scheduler_head = NULL;
static struct kthread* scheduler_tail = NULL;

void kthread_enqueue(struct kthread* thread) {
	if (thread == &thread_idle)
		return;

	thread->state = KTHREAD_STATE_READY;
	thread->next = NULL;
	thread->waiting_on = NULL;

	if (scheduler_head)
		scheduler_tail->next = thread;
	else
		scheduler_head = thread;

	scheduler_tail = thread;
}

static struct kthread* kthread_dequeue() {
	if (!scheduler_head)
		return &thread_idle;

	struct kthread* thread = scheduler_head;

	scheduler_head = thread->next;
	if (!scheduler_head)
		scheduler_tail = NULL;

	thread->next = NULL;
	thread->waiting_on = NULL;

	return thread;
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
		
	for (uint8_t i = 3; i < 32; i++)
		thread->context.regs[i] = 0;
	
	thread->context.regs[REG_SP] = (uint32_t)(&(thread->stack[KTHREAD_STACK_SIZE / 4]));

	uint32_t thread_status;
	__asm__ volatile("csrr %0, sstatus" : "=r"(thread_status));
	if (supervisor_mode)
		thread_status |= 0b1 << 8;
	else
		thread_status &= ~(0b1 << 8);
	thread->context.status = thread_status;

	void kthread_wrapper_function();
	thread->context.pc = kthread_wrapper_function;

	thread->function = function;
	thread->arg = arg;

	thread->state = KTHREAD_STATE_READY;
	thread->next = NULL;

	return thread;
}

void kthread_dispatch() {
	struct kthread* old_thread = thread_current;

	if (old_thread && old_thread->state != KTHREAD_STATE_BLOCKED)
		kthread_enqueue(old_thread);
		
	struct kthread* new_thread = kthread_dequeue();

	thread_current = new_thread;
	new_thread->state = KTHREAD_STATE_RUNNING;
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

		if (local_data->storage->destructor)
			local_data->storage->destructor(local_data->data);

		kheap_dealloc(local_data);

		local_data = next_data;
	}
}

void kthread_destroy(struct kthread* thread) {
	kthread_clean_td(thread);

	if (thread->stack)
		kheap_dealloc(thread->stack);

	kheap_dealloc(thread);
}