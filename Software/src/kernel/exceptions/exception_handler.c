#include <stdint.h>
#include "kernel/sync/thread.h"

enum exception_type {
	EXCEPTION_TYPE_INVALID_INSTRUCTION = 0x02,
	EXCEPTION_TYPE_INVALID_MEMORY_READ = 0x05,
	EXCEPTION_TYPE_INVALID_MEMORY_WRITE = 0x07,

	EXCEPTION_TYPE_USER_ECALL = 0x08,
	EXCEPTION_TYPE_SUPERVISOR_ECALL = 0x09,

	EXCEPTION_TYPE_TIMER_INTERRUPT = 0x01UL << 31 | 0x01,
	EXCEPTION_TYPE_EXTERNAL_INTERRUPT = 0x01UL << 31 | 0x09
};

static void syscall_handler() {
	extern void (*syscalls[])();
	extern struct kthread* thread_current;

	uint32_t curr_pc = (uint32_t)(thread_current->context.pc);
	curr_pc += 4;
	thread_current->context.pc = (void(*))(curr_pc);

	uint32_t syscall_type = thread_current->context.regs[REG_A7];
	(syscalls[syscall_type])();
}

void exception_handler(enum exception_type type) {	
	switch (type) {
	case EXCEPTION_TYPE_USER_ECALL:
	case EXCEPTION_TYPE_SUPERVISOR_ECALL:
		syscall_handler();
		break;	
	}
}