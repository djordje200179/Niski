.global __mem_alloc, __mem_free, __mem_try_realloc
.global __thread_create, __thread_exit, __thread_detach, __thread_dispatch
.global __mutex_create, __mutex_lock, __mutex_unlock, __mutex_destroy, __mutex_try_lock
.global __cond_create, __cond_wait, __cond_signal, __con_signal_all, __cond_destroy
.global __ts_create, __ts_destroy, __ts_get, __ts_set
.global __sig_set, __sig_raise

#include "common/syscall_codes.h"

.text
__mem_alloc:
	li a5, __SYSCALL_MEM_ALLOC
	ecall
	ret

__mem_free:
	li a5, __SYSCALL_MEM_FREE
	ecall
	ret

__mem_try_realloc:
	li a5, __SYSCALL_MEM_TRY_REALLOC
	ecall
	ret

__thread_create:
	li a5, __SYSCALL_THREAD_CREATE
	ecall
	ret

__thread_exit:
	li a5, __SYSCALL_THREAD_EXIT
	ecall
	ret

__thread_detach:
	li a5, __SYSCALL_THREAD_DETACH
	ecall
	ret

__thread_dispatch:
	li a5, __SYSCALL_THREAD_DISPATCH
	ecall
	ret

__mutex_create:
	li a5, __SYSCALL_MUTEX_CREATE
	ecall
	ret

__mutex_lock:
	li a5, __SYSCALL_MUTEX_LOCK
	ecall
	ret

__mutex_unlock:
	li a5, __SYSCALL_MUTEX_UNLOCK
	ecall
	ret

__mutex_destroy:
	li a5, __SYSCALL_MUTEX_DESTROY
	ecall
	ret

__mutex_try_lock:
	li a5, __SYSCALL_MUTEX_TRY_LOCK
	ecall
	ret

__cond_create:
	li a5, __SYSCALL_COND_CREATE
	ecall
	ret

__cond_wait:
	li a5, __SYSCALL_COND_WAIT
	ecall
	ret

__cond_signal:
	li a5, __SYSCALL_COND_SIGNAL
	ecall
	ret

__con_signal_all:
	li a5, __SYSCALL_COND_SIGNAL_ALL
	ecall
	ret

__cond_destroy:
	li a5, __SYSCALL_COND_DESTROY
	ecall
	ret

__ts_create:
	li a5, __SYSCALL_TS_CREATE
	ecall
	ret

__ts_destroy:
	li a5, __SYSCALL_TS_DESTROY
	ecall
	ret

__ts_get:
	li a5, __SYSCALL_TS_GET
	ecall
	ret

__ts_set:
	li a5, __SYSCALL_TS_SET
	ecall
	ret

__sig_set:
	li a5, __SYSCALL_SIG_SET
	ecall
	ret

__sig_raise:
	li a5, __SYSCALL_SIG_RAISE
	ecall
	ret