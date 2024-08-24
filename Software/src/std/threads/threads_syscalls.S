.global thrd_create, thrd_equal, thrd_current, thrd_yield, thrd_exit
.global mtx_init, mtx_lock, mtx_unlock, mtx_destroy, mtx_trylock
.global cnd_init, cnd_signal, cnd_broadcast, cnd_wait, cnd_destroy
.global tss_create, tss_get, tss_set, tss_delete

#include "kernel/syscalls.h"

.extern kthread_current

.text
thrd_create:
	li a5, SYSCALL_THREAD_CREATE
	ecall
	ret

thrd_equal:
	sub a0, a0, a1
	seqz a0, a0
	ret

thrd_current:
	lw a0, kthread_current
	ret

thrd_yield:
	li a5, SYSCALL_THREAD_DISPATCH
	ecall
	ret

thrd_exit:
	li a5, SYSCALL_THREAD_EXIT
	ecall

thrd_detach:
	li a5, SYSCALL_THREAD_DETACH
	ecall
	ret

mtx_init:
	li a5, SYSCALL_MUTEX_CREATE
	ecall
	ret

mtx_lock:
	lw a0, 0(a0)
	li a5, SYSCALL_MUTEX_LOCK
	ecall
	ret

mtx_unlock:
	lw a0, 0(a0)
	li a5, SYSCALL_MUTEX_UNLOCK
	ecall
	ret

mtx_destroy:
	lw a0, 0(a0)
	li a5, SYSCALL_MUTEX_DESTROY
	ecall
	ret

mtx_trylock:
	lw a0, 0(a0)
	li a5, SYSCALL_MUTEX_TRY_LOCK
	ecall
	ret

cnd_init:
	li a5, SYSCALL_COND_CREATE
	ecall
	ret

cnd_signal:
	lw a0, 0(a0)
	li a5, SYSCALL_COND_SIGNAL
	ecall
	ret

cnd_broadcast:
	lw a0, 0(a0)
	li a5, SYSCALL_COND_SIGNAL_ALL
	ecall
	ret

cnd_wait:
	lw a0, 0(a0)
	lw a1, 0(a1)
	li a5, SYSCALL_COND_WAIT
	ecall
	ret

cnd_destroy:
	lw a0, 0(a0)
	li a5, SYSCALL_COND_DESTROY
	ecall
	ret

tss_create:
	li a5, SYSCALL_TS_CREATE
	ecall
	ret

tss_get:
	li a5, SYSCALL_TS_GET
	ecall
	ret

tss_set:
	li a5, SYSCALL_TS_SET
	ecall
	ret

tss_delete:
	li a5, SYSCALL_TS_CREATE
	ecall
	ret