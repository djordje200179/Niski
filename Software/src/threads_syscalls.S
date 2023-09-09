.global thrd_create
.global thrd_equal
.global thrd_current
.global thrd_yield
.global thrd_exit
.global mtx_init
.global mtx_lock
.global mtx_unlock
.global mtx_destroy

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
	li a7, 0x22
	ecall
	ret

mtx_unlock:
	li a7, 0x23
	ecall
	ret

mtx_destroy:
	li a7, 0x24
	ecall
	ret