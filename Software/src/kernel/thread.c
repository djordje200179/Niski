#include "kernel/thread.h"

struct kthread* thread_current;
struct kthread thread_main;

static void wrapper_function() {
	thread_current->function(thread_current->arg);
	// TODO: thread_exit();
}

void kthread_init(struct kthread* thread, uint32_t* stack, int (*function)(void*), void* arg) {
	for (uint8_t i = 3; i < 32; i++)
		thread->context.regs[i] = 0;
	
	thread->context.regs[REG_SP] = (uint32_t)(&(stack[0x1000]));
	thread->context.pc = wrapper_function;

	thread->function = function;
	thread->arg = arg;

	thread->stack = stack;

	thread->state = KTHREAD_STATE_READY;
}