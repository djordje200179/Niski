#include "kernel/thread.h"
#include "kernel/mem_allocator.h"
#include "kernel/mutex.h"
#include "kernel/condition.h"

enum syscall_type {
	SYSCALL_TYPE_MEM_ALLOC = 0x01,
	SYSCALL_TYPE_MEM_FREE = 0x02,

	SYSCALL_TYPE_THREAD_CREATE = 0x11,
	SYSCALL_TYPE_THREAD_EXIT = 0x12,
	SYSCALL_TYPE_THREAD_DISPATCH = 0x13,
	SYSCALL_TYPE_THREAD_JOIN = 0x14,

	SYSCALL_TYPE_MUTEX_CREATE = 0x21,
	SYSCALL_TYPE_MUTEX_LOCK = 0x22,
	SYSCALL_TYPE_MUTEX_UNLOCK = 0x23,
	SYSCALL_TYPE_MUTEX_DESTROY = 0x24,

	SYSCALL_TYPE_CONDITION_CREATE = 0x31,
	SYSCALL_TYPE_CONDITION_WAIT = 0x32,
	SYSCALL_TYPE_CONDITION_SIGNAL = 0x33,
	SYSCALL_TYPE_CONDITION_SIGNAL_ALL = 0x34,
	SYSACLL_TYPE_CONDITION_DESTROY = 0x35
};

#define GET_PARAM(index, type) (type)(thread_current->context.regs[REG_A ## index])
#define SET_RET_VALUE(value) thread_current->context.regs[REG_A0] = (uint32_t)value

static void syscall_mem_alloc() {
	size_t bytes = GET_PARAM(0, size_t);

	void* result = kmem_alloc(bytes);
	SET_RET_VALUE(result);
}

static void syscall_mem_free() {
	void* ptr = GET_PARAM(0, void*);

	kmem_dealloc(ptr);
}

static void syscall_thread_create() {
	struct kthread** location = GET_PARAM(0, struct kthread**);
	int (*func)() = GET_PARAM(1, int (*)());
	void* arg = GET_PARAM(2, void*);

	if (!location || !func) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

	struct kthread* thread = kthread_create(func, arg);
	if (!thread) {
		SET_RET_VALUE(KTHREAD_STATUS_NOMEM);
		return;
	}

	*location = thread;

	kthread_enqueue(thread);

	SET_RET_VALUE(KTHREAD_STATUS_SUCCESS);
}

static void syscall_thread_exit() {
	kthread_destroy(thread_current);
	thread_current = NULL;

	kthread_dispatch();
}

static void syscall_thread_join() {
	// TODO: implement
}

static void syscall_mutex_create() {
	struct kmutex** location = GET_PARAM(0, struct kmutex**);

	if (!location) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

	struct kmutex* mutex = kmutex_create();
	if (!mutex) {
		SET_RET_VALUE(KTHREAD_STATUS_NOMEM);
		return;
	}

	*location = mutex;

	SET_RET_VALUE(KTHREAD_STATUS_SUCCESS);
}

static void syscall_mutex_lock() {
	struct kmutex* mutex = GET_PARAM(0, struct kmutex*);

	if (!mutex) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

	kmutex_lock_current(mutex);

	SET_RET_VALUE(KTHREAD_STATUS_SUCCESS);
}

static void syscall_mutex_unlock() {
	struct kmutex* mutex = GET_PARAM(0, struct kmutex*);

	if (!mutex) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

	kmutex_unlock(mutex);

	SET_RET_VALUE(KTHREAD_STATUS_SUCCESS);
}

static void syscall_mutex_destroy() {
	struct kmutex* mutex = GET_PARAM(0, struct kmutex*);

	if (!mutex) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

	kmutex_destroy(mutex);

	SET_RET_VALUE(KTHREAD_STATUS_SUCCESS);
}

static void syscall_cond_create() {
	struct kcond** location = GET_PARAM(0, struct kcond**);

	if (!location) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

	struct kcond* condition = kcond_create();
	if (!condition) {
		SET_RET_VALUE(KTHREAD_STATUS_NOMEM);
		return;
	}

	*location = condition;

	SET_RET_VALUE(KTHREAD_STATUS_SUCCESS);
}

static void syscall_cond_wait() {
	struct kcond* condition = GET_PARAM(0, struct kcond*);
	struct kmutex* mutex = GET_PARAM(1, struct kmutex*);

	if (!condition || !mutex) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

	kcond_wait(condition, mutex);

	SET_RET_VALUE(KTHREAD_STATUS_SUCCESS);
}

static void syscall_cond_signal() {
	struct kcond* condition = GET_PARAM(0, struct kcond*);

	if (!condition) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

	kcond_signal(condition);

	SET_RET_VALUE(KTHREAD_STATUS_SUCCESS);
}

static void syscall_cond_signal_all() {
	struct kcond* condition = GET_PARAM(0, struct kcond*);

	if (!condition) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

	kcond_signal_all(condition);

	SET_RET_VALUE(KTHREAD_STATUS_SUCCESS);
}

static void syscall_cond_destroy() {
	struct kcond* condition = GET_PARAM(0, struct kcond*);

	if (!condition) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

	kcond_destroy(condition);

	SET_RET_VALUE(KTHREAD_STATUS_SUCCESS);
}

void (*syscalls[100])() = {
	[SYSCALL_TYPE_MEM_ALLOC] = syscall_mem_alloc,
	[SYSCALL_TYPE_MEM_FREE] = syscall_mem_free,

	[SYSCALL_TYPE_THREAD_CREATE] = syscall_thread_create,
	[SYSCALL_TYPE_THREAD_EXIT] = syscall_thread_exit,
	[SYSCALL_TYPE_THREAD_DISPATCH] = kthread_dispatch,
	[SYSCALL_TYPE_THREAD_JOIN] = syscall_thread_join,

	[SYSCALL_TYPE_MUTEX_CREATE] = syscall_mutex_create,
	[SYSCALL_TYPE_MUTEX_LOCK] = syscall_mutex_lock,
	[SYSCALL_TYPE_MUTEX_UNLOCK] = syscall_mutex_unlock,
	[SYSCALL_TYPE_MUTEX_DESTROY] = syscall_mutex_destroy,

	[SYSCALL_TYPE_CONDITION_CREATE] = syscall_cond_create,
	[SYSCALL_TYPE_CONDITION_WAIT] = syscall_cond_wait,
	[SYSCALL_TYPE_CONDITION_SIGNAL] = syscall_cond_signal,
	[SYSCALL_TYPE_CONDITION_SIGNAL_ALL] = syscall_cond_signal_all,
	[SYSACLL_TYPE_CONDITION_DESTROY] = syscall_cond_destroy
};