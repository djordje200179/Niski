.global malloc
.global free

.text
malloc:
	li a7, 0x01
	ecall
	ret

free:
	li a7, 0x02
	ecall
	ret