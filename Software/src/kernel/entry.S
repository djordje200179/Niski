.global entry

.extern init, trap
.extern __thread_dispatch

.extern KERNEL_STACK_END, DATA_START

.text
entry:
	la sp, KERNEL_STACK_END
	la gp, DATA_START

	la a0, trap
	csrw stvec, a0

	li a0, 0b1000100000
	csrw sie, a0
	
	csrwi sstatus, 0

	call init
	
spin:
	call __thread_dispatch
	j spin