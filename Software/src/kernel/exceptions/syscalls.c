#include "kernel/sync/thread.h"
#include "kernel/mem_alloc/heap_allocator.h"
#include "kernel/sync/mutex.h"
#include "kernel/sync/condition.h"
#include "kernel/sync/thread_local.h"
#include "kernel/sync/scheduler.h"
#include "kernel/syscalls.h"

#define GET_PARAM(index, type) (type)(kthread_current->context.regs[REG_A ## index])
#define SET_RET_VALUE(value) kthread_current->context.regs[REG_A0] = (uint32_t)value

static void syscall_mem_alloc() {
	size_t bytes = GET_PARAM(0, size_t);

	void* result = kheap_alloc(bytes);
	SET_RET_VALUE(result);
}

static void syscall_mem_free() {
	void* ptr = GET_PARAM(0, void*);

	kheap_dealloc(ptr);
}

static void syscall_mem_try_realloc() {
	void* ptr = GET_PARAM(0, void*);
	size_t bytes = GET_PARAM(1, size_t);

	SET_RET_VALUE(kheap_try_realloc(ptr, bytes));
}

static void syscall_thread_create() {
	struct kthread** location = GET_PARAM(0, struct kthread**);
	int (*func)(void*) = GET_PARAM(1, int (*)(void*));
	void* arg = GET_PARAM(2, void*);

	if (!location || !func) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

	struct kthread* thread = kthread_create(func, arg, false);
	if (!thread) {
		SET_RET_VALUE(KTHREAD_STATUS_NOMEM);
		return;
	}

	*location = thread;

	kscheduler_enqueue(thread);

	SET_RET_VALUE(KTHREAD_STATUS_SUCCESS);
}

static void syscall_thread_exit() {
	kthread_destroy(kthread_current);
	kthread_current = NULL;

	kthread_dispatch();
}

static void syscall_thread_join() {
	// TODO: implement
}

static void syscall_mutex_create() {
	struct kmutex** location = GET_PARAM(0, struct kmutex**);
	enum kmutex_mode mode = GET_PARAM(1, enum kmutex_mode);

	if (!location) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

	struct kmutex* mutex = kmutex_create(mode & KMUTEX_MODE_RECURSIVE);
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

	kmutex_lock(mutex, kthread_current);

	SET_RET_VALUE(KTHREAD_STATUS_SUCCESS);

	if (kthread_current->state == KTHREAD_STATE_BLOCKED)
		kthread_dispatch();
}

static void syscall_mutex_unlock() {
	struct kmutex* mutex = GET_PARAM(0, struct kmutex*);

	if (!mutex) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

	enum kthread_status status = kmutex_unlock(mutex, kthread_current);
	SET_RET_VALUE(status);
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

static void syscall_mutex_try_lock() {
	struct kmutex* mutex = GET_PARAM(0, struct kmutex*);

	if (!mutex) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

	bool result = kmutex_try_lock(mutex, kthread_current);
	if (!result) {
		SET_RET_VALUE(KTHREAD_STATUS_BUSY);
		return;
	}

	SET_RET_VALUE(KTHREAD_STATUS_SUCCESS);
}

static void syscall_cond_create() {
	struct kcond** location = GET_PARAM(0, struct kcond**);

	if (!location) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

	struct kcond* cond = kcond_create();
	if (!cond) {
		SET_RET_VALUE(KTHREAD_STATUS_NOMEM);
		return;
	}

	*location = cond;

	SET_RET_VALUE(KTHREAD_STATUS_SUCCESS);
}

static void syscall_cond_wait() {
	struct kcond* cond = GET_PARAM(0, struct kcond*);
	struct kmutex* mutex = GET_PARAM(1, struct kmutex*);

	if (!cond || !mutex) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

	kcond_wait(cond, mutex, kthread_current);

	SET_RET_VALUE(KTHREAD_STATUS_SUCCESS);

	if (kthread_current->state == KTHREAD_STATE_BLOCKED)
		kthread_dispatch();
}

static void syscall_cond_signal() {
	struct kcond* cond = GET_PARAM(0, struct kcond*);

	if (!cond) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

	kcond_signal(cond);

	SET_RET_VALUE(KTHREAD_STATUS_SUCCESS);
}

static void syscall_cond_signal_all() {
	struct kcond* cond = GET_PARAM(0, struct kcond*);

	if (!cond) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

	kcond_signal_all(cond);

	SET_RET_VALUE(KTHREAD_STATUS_SUCCESS);
}

static void syscall_cond_destroy() {
	struct kcond* cond = GET_PARAM(0, struct kcond*);

	if (!cond) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

	kcond_destroy(cond);

	SET_RET_VALUE(KTHREAD_STATUS_SUCCESS);
}

static void syscall_ts_create() {
	struct kthread_ls** location = GET_PARAM(0, struct kthread_ls**);
	void (*dtor)(void*) = GET_PARAM(1, void (*)(void*));

	if (!location) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

	struct kthread_ls* local_storage = kthread_ls_create(dtor);
	if (!local_storage) {
		SET_RET_VALUE(KTHREAD_STATUS_NOMEM);
		return;
	}

	*location = local_storage;

	SET_RET_VALUE(KTHREAD_STATUS_SUCCESS);
}

static void syscall_ts_destroy() {
	struct kthread_ls* local_storage = GET_PARAM(0, struct kthread_ls*);

	if (!local_storage) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

	kthread_ls_destroy(local_storage);

	SET_RET_VALUE(KTHREAD_STATUS_SUCCESS);
}

static void syscall_ts_get() {
	struct kthread_ls* local_storage = GET_PARAM(0, struct kthread_ls*);

	if (!local_storage) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

	void* data = kthread_ls_get(local_storage, kthread_current);
	SET_RET_VALUE(data);
}

static void syscall_ts_set() {
	struct kthread_ls* local_storage = GET_PARAM(0, struct kthread_ls*);
	void* data = GET_PARAM(1, void*);

	if (!local_storage) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

	enum kthread_status status = kthread_ls_set(local_storage, kthread_current, data);
	if (status != KTHREAD_STATUS_SUCCESS) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

	SET_RET_VALUE(KTHREAD_STATUS_SUCCESS);
}

static void (*syscalls[100])() = {
	[SYSCALL_MEM_ALLOC] = syscall_mem_alloc,
	[SYSCALL_MEM_FREE] = syscall_mem_free,
	[SYSCALL_MEM_TRY_REALLOC] = syscall_mem_try_realloc,

	[SYSCALL_THREAD_CREATE] = syscall_thread_create,
	[SYSCALL_THREAD_EXIT] = syscall_thread_exit,
	[SYSCALL_THREAD_DISPATCH] = kthread_dispatch,
	[SYSCALL_THREAD_JOIN] = syscall_thread_join,

	[SYSCALL_MUTEX_CREATE] = syscall_mutex_create,
	[SYSCALL_MUTEX_LOCK] = syscall_mutex_lock,
	[SYSCALL_MUTEX_UNLOCK] = syscall_mutex_unlock,
	[SYSCALL_MUTEX_DESTROY] = syscall_mutex_destroy,
	[SYSCALL_MUTEX_TRY_LOCK] = syscall_mutex_try_lock,

	[SYSCALL_COND_CREATE] = syscall_cond_create,
	[SYSCALL_COND_WAIT] = syscall_cond_wait,
	[SYSCALL_COND_SIGNAL] = syscall_cond_signal,
	[SYSCALL_COND_SIGNAL_ALL] = syscall_cond_signal_all,
	[SYSCALL_COND_DESTROY] = syscall_cond_destroy,

	[SYSCALL_TS_CREATE] = syscall_ts_create,
	[SYSCALL_TS_DESTROY] = syscall_ts_destroy,
	[SYSCALL_TS_GET] = syscall_ts_get,
	[SYSCALL_TS_SET] = syscall_ts_set
};

void handle_syscall() {
	intptr_t curr_pc = (intptr_t)(kthread_current->context.pc);
	curr_pc += 4;
	kthread_current->context.pc = (void(*))(curr_pc);

	uint32_t syscall_type = kthread_current->context.regs[REG_A5];
	(syscalls[syscall_type])();
}