.global trap

.extern trap_handler
.extern thread_current

.bss
.align 4
.space 0x1000
kernel_stack:

.text
.align 2
trap:
	csrw sscratch, t6
	lw t6, thread_current
	.irp index, 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30
		sw x\index, \index * 4 (t6)
	.endr
	
	csrr t5, sscratch
	sw t5, 31 * 4 (t6)
	csrr t5, sstatus
	sw t5, 32 * 4 (t6)
	csrr t5, sepc
	sw t5, 33 * 4 (t6)

	la sp, kernel_stack

	csrr a0, scause
	call exception_handler

	lw t6, thread_current
	lw t5, 33 * 4 (t6)
	csrw sepc, t5
	lw t5, 32 * 4 (t6)
	csrw sstatus, t5
	.irp index, 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
		lw x\index, \index * 4 (t6)
	.endr

	sret
