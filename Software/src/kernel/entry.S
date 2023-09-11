.global entry

.extern init, trap
.extern thrd_yield

.extern STACK_END

.text
entry:
	la sp, STACK_END

	la a0, trap
	csrw stvec, a0

	call init
spin:
	call thrd_yield
	j spin