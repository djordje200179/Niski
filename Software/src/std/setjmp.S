.global setjmp, longjmp

.text
setjmp:
	sw ra, 0(a0)
	sw sp, 4(a0)
	sw s0, 8(a0)
	sw s1, 12(a0)

	li a0, 0

	ret

longjmp:
	lw ra, 0(a0)
	lw sp, 4(a0)
	lw s0, 8(a0)
	lw s1, 12(a0)

	seqz a0, a1
	add a0, a0, a1

	ret