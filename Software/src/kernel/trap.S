.global trap

.extern trap_handler
.extern kthread_current

.bss
.align 4
.space 0x1000
kernel_stack:

.text
.align 2
trap:
	csrw sscratch, x15
	lw x15, kthread_current
	.irp index, 1,2,3,4,5,6,7,8,9,10,11,12,13,14
		sw x\index, \index * 4 (x15)
	.endr
	
	csrr x14, sscratch
	sw x14, (16 - 1) * 4 (x15)
	csrr x14, sstatus
	sw x14, 16 * 4 (x15)
	csrr x14, sepc
	sw x14, (16 + 1) * 4 (x15)

	la sp, kernel_stack

	csrr a0, scause
	call exception_handler

	lw x15, kthread_current
	lw x14, (16 + 1) * 4 (x15)
	csrw sepc, x14
	lw x14, 16 * 4 (x15)
	csrw sstatus, x14
	.irp index, 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
		lw x\index, \index * 4 (x15)
	.endr

	sret
