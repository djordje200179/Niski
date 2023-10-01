.global entry

.extern init, trap
.extern thrd_yield

.extern MAIN_THREAD_STACK_END, MAIN_THREAD_TDATA_START, DATA_START

.text
entry:
	la sp, MAIN_THREAD_STACK_END
	la tp, MAIN_THREAD_TDATA_START
	la gp, DATA_START

	la a0, trap
	csrw stvec, a0

	li a0, 0b1000100000
	#csrw sie, a0
	
	csrwi sstatus, 0

	call init
spin:
	call thrd_yield
	j spin