.global signal, raise

#include "kernel/syscalls.h"

.text
signal:
	li a5, SYSCALL_SIG_SET
	ecall
	ret

raise:
	li a5, SYSCALL_SIG_RAISE
	ecall
	ret
