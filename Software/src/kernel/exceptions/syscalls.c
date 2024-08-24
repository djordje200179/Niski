#include "kernel/sync/thread.h"
#include "kernel/mem_alloc/heap_allocator.h"
#include "kernel/sync/mutex.h"
#include "kernel/sync/condition.h"
#include "kernel/sync/thread_local.h"
#include "kernel/sync/scheduler.h"
#include "kernel/signals.h"
#include "common/syscall_codes.h"

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

static void syscall_mem_try_expand() {
	void* ptr = GET_PARAM(0, void*);
	size_t bytes = GET_PARAM(1, size_t);

	SET_RET_VALUE(kheap_try_expand(ptr, bytes));
}

static void syscall_thread_create() {
	struct kthread** location = GET_PARAM(0, struct kthread**);
	int (*func)(void*) = GET_PARAM(1, int (*)(void*));
	void* arg = GET_PARAM(2, void*);

	if (!location || !func) {
		SET_RET_VALUE(__THREAD_STATUS_ERROR);
		return;
	}

	struct kthread* thread = kthread_create(func, arg, false);
	if (!thread) {
		SET_RET_VALUE(__THREAD_STATUS_NO_MEMORY);
		return;
	}

	*location = thread;

	kscheduler_enqueue(thread);

	SET_RET_VALUE(__THREAD_STATUS_SUCCESS);
}

static void syscall_thread_detach() {
	struct kthread* thread = GET_PARAM(0, struct kthread*);
	if (!thread) {
		SET_RET_VALUE(__THREAD_STATUS_ERROR);
		return;
	}

	kthread_destroy(thread);

	SET_RET_VALUE(__THREAD_STATUS_SUCCESS);
}

static void syscall_thread_join() {
	// TODO: implement
}

static void syscall_mutex_create() {
	struct kmutex** location = GET_PARAM(0, struct kmutex**);
	enum __mutex_mode mode = GET_PARAM(1, enum __mutex_mode);

	if (!location) {
		SET_RET_VALUE(__THREAD_STATUS_ERROR);
		return;
	}

	struct kmutex* mutex = kheap_alloc(sizeof(struct kmutex));
	if (!mutex) {
		SET_RET_VALUE(__THREAD_STATUS_NO_MEMORY);
		return;
	}

	kmutex_init(mutex, mode & __MUTEX_MODE_RECURSIVE);
	*location = mutex;

	SET_RET_VALUE(__THREAD_STATUS_SUCCESS);
}

static void syscall_mutex_lock() {
	struct kmutex* mutex = GET_PARAM(0, struct kmutex*);

	if (!mutex) {
		SET_RET_VALUE(__THREAD_STATUS_ERROR);
		return;
	}

	kmutex_lock(mutex, kthread_current);

	SET_RET_VALUE(__THREAD_STATUS_SUCCESS);

	if (kthread_current->state == KTHREAD_STATE_BLOCKED)
		kthread_dispatch();
}

static void syscall_mutex_unlock() {
	struct kmutex* mutex = GET_PARAM(0, struct kmutex*);

	if (!mutex) {
		SET_RET_VALUE(__THREAD_STATUS_ERROR);
		return;
	}

	enum __thread_status status = kmutex_unlock(mutex, kthread_current);
	SET_RET_VALUE(status);
}

static void syscall_mutex_destroy() {
	struct kmutex* mutex = GET_PARAM(0, struct kmutex*);

	if (!mutex) {
		SET_RET_VALUE(__THREAD_STATUS_ERROR);
		return;
	}

	kmutex_destroy(mutex);
	kheap_dealloc(mutex);

	SET_RET_VALUE(__THREAD_STATUS_SUCCESS);
}

static void syscall_mutex_try_lock() {
	struct kmutex* mutex = GET_PARAM(0, struct kmutex*);

	if (!mutex) {
		SET_RET_VALUE(__THREAD_STATUS_ERROR);
		return;
	}

	bool result = kmutex_try_lock(mutex, kthread_current);
	if (!result) {
		SET_RET_VALUE(__THREAD_STATUS_BUSY);
		return;
	}

	SET_RET_VALUE(__THREAD_STATUS_SUCCESS);
}

static void syscall_cond_create() {
	struct kcond** location = GET_PARAM(0, struct kcond**);

	if (!location) {
		SET_RET_VALUE(__THREAD_STATUS_ERROR);
		return;
	}

	struct kcond* cond = kheap_alloc(sizeof(struct kcond));
	if (!cond) {
		SET_RET_VALUE(__THREAD_STATUS_NO_MEMORY);
		return;
	}

	kcond_init(cond);
	*location = cond;

	SET_RET_VALUE(__THREAD_STATUS_SUCCESS);
}

static void syscall_cond_wait() {
	struct kcond* cond = GET_PARAM(0, struct kcond*);
	struct kmutex* mutex = GET_PARAM(1, struct kmutex*);

	if (!cond || !mutex) {
		SET_RET_VALUE(__THREAD_STATUS_ERROR);
		return;
	}

	kcond_wait(cond, mutex, kthread_current);

	SET_RET_VALUE(__THREAD_STATUS_SUCCESS);

	if (kthread_current->state == KTHREAD_STATE_BLOCKED)
		kthread_dispatch();
}

static void syscall_cond_signal() {
	struct kcond* cond = GET_PARAM(0, struct kcond*);

	if (!cond) {
		SET_RET_VALUE(__THREAD_STATUS_ERROR);
		return;
	}

	kcond_signal(cond, false);

	SET_RET_VALUE(__THREAD_STATUS_SUCCESS);
}

static void syscall_cond_signal_all() {
	struct kcond* cond = GET_PARAM(0, struct kcond*);

	if (!cond) {
		SET_RET_VALUE(__THREAD_STATUS_ERROR);
		return;
	}

	kcond_signal_all(cond);

	SET_RET_VALUE(__THREAD_STATUS_SUCCESS);
}

static void syscall_cond_destroy() {
	struct kcond* cond = GET_PARAM(0, struct kcond*);

	if (!cond) {
		SET_RET_VALUE(__THREAD_STATUS_ERROR);
		return;
	}

	kcond_destroy(cond);
	kheap_dealloc(cond);

	SET_RET_VALUE(__THREAD_STATUS_SUCCESS);
}

static void syscall_ts_create() {
	struct kthread_ls** location = GET_PARAM(0, struct kthread_ls**);
	void (*dtor)(void*) = GET_PARAM(1, void (*)(void*));

	if (!location) {
		SET_RET_VALUE(__THREAD_STATUS_ERROR);
		return;
	}

	struct kthread_ls* local_storage = kthread_ls_create(dtor);
	if (!local_storage) {
		SET_RET_VALUE(__THREAD_STATUS_NO_MEMORY);
		return;
	}

	*location = local_storage;

	SET_RET_VALUE(__THREAD_STATUS_SUCCESS);
}

static void syscall_ts_destroy() {
	struct kthread_ls* local_storage = GET_PARAM(0, struct kthread_ls*);

	if (!local_storage) {
		SET_RET_VALUE(__THREAD_STATUS_ERROR);
		return;
	}

	kthread_ls_destroy(local_storage);

	SET_RET_VALUE(__THREAD_STATUS_SUCCESS);
}

static void syscall_ts_get() {
	struct kthread_ls* local_storage = GET_PARAM(0, struct kthread_ls*);

	if (!local_storage) {
		SET_RET_VALUE(__THREAD_STATUS_ERROR);
		return;
	}

	void* data = kthread_ls_get(local_storage, kthread_current);
	SET_RET_VALUE(data);
}

static void syscall_ts_set() {
	struct kthread_ls* local_storage = GET_PARAM(0, struct kthread_ls*);
	void* data = GET_PARAM(1, void*);

	if (!local_storage) {
		SET_RET_VALUE(__THREAD_STATUS_ERROR);
		return;
	}

	enum __thread_status status = kthread_ls_set(local_storage, kthread_current, data);
	if (status != __THREAD_STATUS_SUCCESS) {
		SET_RET_VALUE(__THREAD_STATUS_ERROR);
		return;
	}

	SET_RET_VALUE(__THREAD_STATUS_SUCCESS);
}

static void syscall_sig_set_handler() {
	enum __signal sig = GET_PARAM(0, enum __signal);
	ksignal_handler_t handler = GET_PARAM(1, ksignal_handler_t);

	handler = ksignal_handle(sig, handler);

	SET_RET_VALUE(handler);
}

static void syscall_sig_raise() {
	int sig = GET_PARAM(0, int);

	ksignal_send(sig);

	SET_RET_VALUE(0);
}

static void (*syscalls[])() = {
	[__SYSCALL_MEMORY_ALLOCATE] = syscall_mem_alloc,
	[__SYSCALL_MEMORY_FREE] = syscall_mem_free,
	[__SYSCALL_MEMORY_TRY_EXPAND] = syscall_mem_try_expand,

	[__SYSCALL_THREAD_CREATE] = syscall_thread_create,
	[__SYSCALL_THREAD_EXIT] = kthread_stop,
	[__SYSCALL_THREAD_DETACH] = syscall_thread_detach,
	[__SYSCALL_THREAD_DISPATCH] = kthread_dispatch,
	[__SYSCALL_THREAD_JOIN] = syscall_thread_join,

	[__SYSCALL_MUTEX_CREATE] = syscall_mutex_create,
	[__SYSCALL_MUTEX_LOCK] = syscall_mutex_lock,
	[__SYSCALL_MUTEX_UNLOCK] = syscall_mutex_unlock,
	[__SYSCALL_MUTEX_DESTROY] = syscall_mutex_destroy,
	[__SYSCALL_MUTEX_TRY_LOCK] = syscall_mutex_try_lock,

	[__SYSCALL_CONDITION_CREATE] = syscall_cond_create,
	[__SYSCALL_CONDITION_WAIT] = syscall_cond_wait,
	[__SYSCALL_CONDITION_SIGNAL] = syscall_cond_signal,
	[__SYSCALL_CONDITION_SIGNAL_ALL] = syscall_cond_signal_all,
	[__SYSCALL_CONDITION_DESTROY] = syscall_cond_destroy,

	[__SYSCALL_THREAD_STORAGE_CREATE] = syscall_ts_create,
	[__SYSCALL_THREAD_STORAGE_DESTROY] = syscall_ts_destroy,
	[__SYSCALL_THREAD_STORAGE_GET] = syscall_ts_get,
	[__SYSCALL_THREAD_STORAGE_SET] = syscall_ts_set,

	[__SYSCALL_SIGNAL_SET_HANDLER] = syscall_sig_set_handler,
	[__SYSCALL_SIGNAL_RAISE] = syscall_sig_raise,
};

void handle_syscall() {
	kthread_current->context.pc++;

	uint32_t syscall_type = kthread_current->context.regs[REG_A5];
	(syscalls[syscall_type])();
}