.global thrd_create, thrd_equal, thrd_current, thrd_yield, thrd_exit
.global mtx_init, mtx_lock, mtx_unlock, mtx_destroy, mtx_trylock
.global cnd_init, cnd_signal, cnd_broadcast, cnd_wait, cnd_destroy
.global tss_create, tss_get, tss_set, tss_delete

.extern thread_current

.text
thrd_create:
	li a7, 0x11
	ecall
	ret

thrd_equal:
	sub a0, a0, a1
	seqz a0, a0
	ret

thrd_current:
	lw a0, thread_current
	ret

thrd_yield:
	li a7, 0x13
	ecall
	ret

thrd_exit:
	li a7, 0x12
	ecall
	ret

mtx_init:
	li a7, 0x21
	ecall
	ret

mtx_lock:
	lw a0, 0(a0)
	li a7, 0x22
	ecall
	ret

mtx_unlock:
	lw a0, 0(a0)
	li a7, 0x23
	ecall
	ret

mtx_destroy:
	lw a0, 0(a0)
	li a7, 0x24
	ecall
	ret

mtx_trylock:
	lw a0, 0(a0)
	li a7, 0x25
	ecall
	ret

cnd_init:
	li a7, 0x31
	ecall
	ret

cnd_signal:
	lw a0, 0(a0)
	li a7, 0x32
	ecall
	ret

cnd_broadcast:
	lw a0, 0(a0)
	li a7, 0x33
	ecall
	ret

cnd_wait:
	lw a0, 0(a0)
	li a7, 0x34
	ecall
	ret

cnd_destroy:
	lw a0, 0(a0)
	li a7, 0x35
	ecall
	ret

tss_create:
	li a7, 0x41
	ecall
	ret

tss_get:
	li a7, 0x43
	ecall
	ret

tss_set:
	li a7, 0x44
	ecall
	ret

tss_delete:
	li a7, 0x42
	ecall
	ret