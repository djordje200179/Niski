.global kthread_wrapper_function

.extern kthread_current
.extern thrd_exit

.equ KTHREAD_FUNCTION_OFFSET, 16 * 4 + 4 + 4
.equ KTHREAD_ARG_OFFSET, KTHREAD_FUNCTION_OFFSET + 4

.text
kthread_wrapper_function:
	lw a2, kthread_current

	lw a1, KTHREAD_FUNCTION_OFFSET(a2)
	lw a0, KTHREAD_ARG_OFFSET(a2)

	jalr a1

	j thrd_exit
