.global thrd_create
.global thrd_equal
.global thrd_current
.global thrd_yield
.global thrd_exit

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