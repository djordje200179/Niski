#include <stdint.h>
#include "kernel/sync/thread.h"
#include "devices/ssds.h"
#include "devices/buzzer.h"

enum exception_type {
	EXC_TYPE_INSTRUCTION_ADDRESS_MISALIGNED = 0x00,
	EXC_TYPE_INSTRUCTION_ACCESS_FAULT = 0x01,
	EXC_TYPE_ILLEGAL_INSTRUCTION = 0x02,

	EXC_TYPE_LOAD_ADDRESS_MISALIGNED = 0x04,
	EXC_TYPE_LOAD_ACCESS_FAULT = 0x05,
	EXC_TYPE_STORE_ADDRESS_MISALIGNED = 0x06,
	EXC_TYPE_STORE_ACCESS_FAULT = 0x07,

	EXC_TYPE_USER_ECALL = 0x08,
	EXC_TYPE_SUPERVISOR_ECALL = 0x09,

	EXC_TYPE_TIMER_INTERRUPT = 0x01UL << 31 | 0x01,
	EXC_TYPE_EXTERNAL_INTERRUPT = 0x01UL << 31 | 0x09
};

static void syscall_handler() {
	extern void (*syscalls[])();
	extern struct kthread* kthread_current;

	uint32_t curr_pc = (uint32_t)(kthread_current->context.pc);
	curr_pc += 4;
	kthread_current->context.pc = (void(*))(curr_pc);

	uint32_t syscall_type = kthread_current->context.regs[REG_A7];
	(syscalls[syscall_type])();
}

static void illegal_action_handler(enum exception_type type) {
	buzzer_on();
	ssds_on();

	ssds_set_dec_number(type);
	buzzer_set(true);

	while(true);
}

void exception_handler(enum exception_type type) {	
	switch (type) {
	case EXC_TYPE_USER_ECALL:
	case EXC_TYPE_SUPERVISOR_ECALL:
		syscall_handler();
		break;	
	case EXC_TYPE_INSTRUCTION_ADDRESS_MISALIGNED:
	case EXC_TYPE_INSTRUCTION_ACCESS_FAULT:
	case EXC_TYPE_ILLEGAL_INSTRUCTION:
	case EXC_TYPE_LOAD_ADDRESS_MISALIGNED:
	case EXC_TYPE_LOAD_ACCESS_FAULT:
	case EXC_TYPE_STORE_ADDRESS_MISALIGNED:
	case EXC_TYPE_STORE_ACCESS_FAULT:
		illegal_action_handler(type);
		break;
	}
}