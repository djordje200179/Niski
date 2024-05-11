.global malloc, free

#include "kernel/syscalls.h"

.text
malloc:
	li a5, SYSCALL_MEM_ALLOC
	ecall
	ret

free:
	li a5, SYSCALL_MEM_FREE
	ecall
	ret

.__try_realloc:
	li a5, SYSCALL_MEM_TRY_REALLOC
	ecall
	ret