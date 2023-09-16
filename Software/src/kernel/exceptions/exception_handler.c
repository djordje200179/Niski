#include <stdint.h>
#include "kernel/sync/thread.h"
#include "devices/ssds.h"
#include "devices/buzzer.h"

enum exception_type {
	EXC_TYPE_ILLEGAL_INSTRUCTION = 0x02,
	EXC_TYPE_INVALID_MEMORY_READ = 0x05,
	EXC_TYPE_INVALID_MEMORY_WRITE = 0x07,

	EXC_TYPE_USER_ECALL = 0x08,
	EXC_TYPE_SUPERVISOR_ECALL = 0x09,

	EXC_TYPE_TIMER_INTERRUPT = 0x01UL << 31 | 0x01,
	EXC_TYPE_EXTERNAL_INTERRUPT = 0x01UL << 31 | 0x09
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

static void illegal_action_handler(enum exception_type type) {
	buzzer_on();
	ssds_on();

	ssds_set_number(type);
	buzzer_set(true);

	while(true);
}

void exception_handler(enum exception_type type) {	
	switch (type) {
	case EXC_TYPE_USER_ECALL:
	case EXC_TYPE_SUPERVISOR_ECALL:
		syscall_handler();
		break;	
	case EXC_TYPE_ILLEGAL_INSTRUCTION:
	case EXC_TYPE_INVALID_MEMORY_READ:
	case EXC_TYPE_INVALID_MEMORY_WRITE:
		illegal_action_handler(type);
		break;
	}
}