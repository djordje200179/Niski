#include "kernel/thread.h"
#include "kernel/mem_allocator.h"

#define KTHREAD_STACK_SIZE 0x1000

struct kthread* thread_current;
static struct kthread thread_main, thread_idle;

static struct kthread* scheduler_head;
static struct kthread* scheduler_tail;

void kthread_init() {
	thread_main.state = KTHREAD_STATE_RUNNING;
	thread_main.next = NULL;
	thread_main.waiting_on = NULL;

	thread_current = &thread_main;
}

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

static void wrapper_function() {
	int res = thread_current->function(thread_current->arg);

	[[noreturn]] void thrd_exit(int res);
	thrd_exit(res);
}

struct kthread* kthread_create(int (*function)(void*), void* arg) {
	struct kthread* thread = kmem_alloc(sizeof(struct kthread) + KTHREAD_STACK_SIZE);
	if (!thread)
		return NULL;
		
	for (uint8_t i = 3; i < 32; i++)
		thread->context.regs[i] = 0;
	
	thread->context.regs[REG_SP] = (uint32_t)(&(thread->stack[KTHREAD_STACK_SIZE / 4]));
	thread->context.pc = wrapper_function;

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