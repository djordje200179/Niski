.global kthread_wrapper_function

.extern thread_current
.extern thrd_exit

.equ KTHREAD_FUNCTION_OFFSET, 32 * 4 + 4
.equ KTHREAD_ARG_OFFSET, KTHREAD_FUNCTION_OFFSET + 4

.text
kthread_wrapper_function:
	la a2, thread_current
	lw a2, 0(a2)

	lw a1, KTHREAD_FUNCTION_OFFSET(a2)
	lw a0, KTHREAD_ARG_OFFSET(a2)

	jalr a1

	j thrd_exit
