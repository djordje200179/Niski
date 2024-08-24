.global __memory_allocate, __memory_free, __memory_try_expand
.global __thread_create, __thread_exit, __thread_detach, __thread_dispatch, __thread_get_current
.global __mutex_create, __mutex_lock, __mutex_unlock, __mutex_destroy, __mutex_try_lock
.global __condition_create, __condition_wait, __condition_signal, __con_signal_all, __condition_destroy
.global __thread_storage_create, __thread_storage_destroy, __thread_storage_get, __thread_storage_set
.global __signal_set_handler, __signal_raise

#include "common/syscall_codes.h"

.text
__memory_allocate:
	li a5, __SYSCALL_MEMORY_ALLOCATE
	ecall
	ret

__memory_free:
	li a5, __SYSCALL_MEMORY_FREE
	ecall
	ret

__memory_try_expand:
	li a5, __SYSCALL_MEMORY_TRY_EXPAND
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

__thread_get_current:
	li a5, __SYSCALL_THREAD_GET_CURRENT
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

__condition_create:
	li a5, __SYSCALL_CONDITION_CREATE
	ecall
	ret

__condition_wait:
	li a5, __SYSCALL_CONDITION_WAIT
	ecall
	ret

__condition_signal:
	li a5, __SYSCALL_CONDITION_SIGNAL
	ecall
	ret

__con_signal_all:
	li a5, __SYSCALL_CONDITION_SIGNAL_ALL
	ecall
	ret

__condition_destroy:
	li a5, __SYSCALL_CONDITION_DESTROY
	ecall
	ret

__thread_storage_create:
	li a5, __SYSCALL_THREAD_STORAGE_CREATE
	ecall
	ret

__thread_storage_destroy:
	li a5, __SYSCALL_THREAD_STORAGE_DESTROY
	ecall
	ret

__thread_storage_get:
	li a5, __SYSCALL_THREAD_STORAGE_GET
	ecall
	ret

__thread_storage_set:
	li a5, __SYSCALL_THREAD_STORAGE_SET
	ecall
	ret

__signal_set_handler:
	li a5, __SYSCALL_SIGNAL_SET_HANDLER
	ecall
	ret

__signal_raise:
	li a5, __SYSCALL_SIGNAL_RAISE
	ecall
	ret