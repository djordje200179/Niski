#include "kernel/sync/thread.h"
#include "kernel/mem_alloc/heap_allocator.h"
#include "kernel/sync/mutex.h"
#include "kernel/sync/condition.h"
#include "kernel/sync/thread_local.h"

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
	SYSCALL_TYPE_MUTEX_TRY_LOCK = 0x25,

	SYSCALL_TYPE_CONDITION_CREATE = 0x31,
	SYSCALL_TYPE_CONDITION_WAIT = 0x32,
	SYSCALL_TYPE_CONDITION_SIGNAL = 0x33,
	SYSCALL_TYPE_CONDITION_SIGNAL_ALL = 0x34,
	SYSACLL_TYPE_CONDITION_DESTROY = 0x35,

	SYSCALL_TYPE_TS_CREATE = 0x41,
	SYSCALL_TYPE_TS_DESTROY = 0x42,
	SYSCALL_TYPE_TS_GET = 0x43,
	SYSCALL_TYPE_TS_SET = 0x44
};

#define GET_PARAM(index, type) (type)(thread_current->context.regs[REG_A ## index])
#define SET_RET_VALUE(value) thread_current->context.regs[REG_A0] = (uint32_t)value

static void syscall_mem_alloc() {
	size_t bytes = GET_PARAM(0, size_t);

	void* result = kheap_alloc(bytes);
	SET_RET_VALUE(result);
}

static void syscall_mem_free() {
	void* ptr = GET_PARAM(0, void*);

	kheap_dealloc(ptr);
}

static void syscall_thread_create() {
	struct kthread** location = GET_PARAM(0, struct kthread**);
	int (*func)() = GET_PARAM(1, int (*)());
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

	kmutex_lock(mutex, thread_current);

	SET_RET_VALUE(KTHREAD_STATUS_SUCCESS);

	if (thread_current->state == KTHREAD_STATE_BLOCKED)
		kthread_dispatch();
}

static void syscall_mutex_unlock() {
	struct kmutex* mutex = GET_PARAM(0, struct kmutex*);

	if (!mutex) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

	enum kthread_status status = kmutex_unlock(mutex, thread_current);
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

	bool result = kmutex_try_lock(mutex, thread_current);
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

	kcond_wait(condition, mutex, thread_current);

	SET_RET_VALUE(KTHREAD_STATUS_SUCCESS);

	if (thread_current->state == KTHREAD_STATE_BLOCKED)
		kthread_dispatch();
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

static void syscall_ts_create() {
	struct kthread_ls** location = GET_PARAM(0, struct kthread_ls**);
	void (*destructor)(void*) = GET_PARAM(1, void (*)(void*));

	if (!location) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

	struct kthread_ls* local_storage = kthread_ls_create(destructor);
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

	void* data = kthread_ls_get(local_storage, thread_current);
	SET_RET_VALUE(data);
}

static void syscall_ts_set() {
	struct kthread_ls* local_storage = GET_PARAM(0, struct kthread_ls*);
	void* data = GET_PARAM(1, void*);

	if (!local_storage) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

	enum kthread_status status = kthread_ls_set(local_storage, thread_current, data);
	if (status != KTHREAD_STATUS_SUCCESS) {
		SET_RET_VALUE(KTHREAD_STATUS_ERROR);
		return;
	}

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
	[SYSCALL_TYPE_MUTEX_TRY_LOCK] = syscall_mutex_try_lock,

	[SYSCALL_TYPE_CONDITION_CREATE] = syscall_cond_create,
	[SYSCALL_TYPE_CONDITION_WAIT] = syscall_cond_wait,
	[SYSCALL_TYPE_CONDITION_SIGNAL] = syscall_cond_signal,
	[SYSCALL_TYPE_CONDITION_SIGNAL_ALL] = syscall_cond_signal_all,
	[SYSACLL_TYPE_CONDITION_DESTROY] = syscall_cond_destroy,

	[SYSCALL_TYPE_TS_CREATE] = syscall_ts_create,
	[SYSCALL_TYPE_TS_DESTROY] = syscall_ts_destroy,
	[SYSCALL_TYPE_TS_GET] = syscall_ts_get,
	[SYSCALL_TYPE_TS_SET] = syscall_ts_set
};