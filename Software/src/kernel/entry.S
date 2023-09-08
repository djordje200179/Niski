.global entry

.extern init
.extern trap

.extern STACK_END_ADDR

.text
entry:
	la sp, STACK_END_ADDR

	la a0, trap
	csrw stvec, a0

	call init
spin:
	j spin