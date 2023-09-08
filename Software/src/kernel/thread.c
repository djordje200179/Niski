#include "kernel/thread.h"
#include "kernel/mem_allocator.h"

#define KTHREAD_STACK_SIZE 0x1000

struct kthread* thread_current;
struct kthread thread_main;

static void wrapper_function() {
	thread_current->function(thread_current->arg);
	// TODO: thread_exit();
}

struct kthread* kthread_create(int (*function)(void*), void* arg) {
	struct kthread* thread = kmem_alloc(sizeof(struct kthread) + KTHREAD_STACK_SIZE);

	for (uint8_t i = 3; i < 32; i++)
		thread->context.regs[i] = 0;
	
	thread->context.regs[REG_SP] = (uint32_t)(&(thread->stack[KTHREAD_STACK_SIZE / 4]));
	thread->context.pc = wrapper_function;

	thread->function = function;
	thread->arg = arg;

	thread->state = KTHREAD_STATE_READY;

	return thread;
}

void kthread_init() {
	thread_main.state = KTHREAD_STATE_RUNNING;

	thread_current = &thread_main;
}