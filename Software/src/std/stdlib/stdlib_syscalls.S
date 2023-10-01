.global malloc, free

#include "kernel/syscalls.h"

.text
malloc:
	li a7, SYSCALL_MEM_ALLOC
	ecall
	ret

free:
	li a7, SYSCALL_MEM_FREE
	ecall
	ret