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

static void handle_illegal_action(enum exception_type type) {
	buzzer_on();
	ssds_on();

	ssds_set_dec_number(type);
	buzzer_set(true);

	while(true);
}

void exception_handler(enum exception_type type) {	
	void handle_syscall();
	void handle_ext_intr();
	void handle_timer_interrupt();

	switch (type) {
	case EXC_TYPE_USER_ECALL:
	case EXC_TYPE_SUPERVISOR_ECALL:
		handle_syscall();
		break;	
	case EXC_TYPE_INSTRUCTION_ADDRESS_MISALIGNED:
	case EXC_TYPE_INSTRUCTION_ACCESS_FAULT:
	case EXC_TYPE_ILLEGAL_INSTRUCTION:
	case EXC_TYPE_LOAD_ADDRESS_MISALIGNED:
	case EXC_TYPE_LOAD_ACCESS_FAULT:
	case EXC_TYPE_STORE_ADDRESS_MISALIGNED:
	case EXC_TYPE_STORE_ACCESS_FAULT:
		handle_illegal_action(type);
		break;
	case EXC_TYPE_EXTERNAL_INTERRUPT:
		handle_ext_intr();
		break;
	case EXC_TYPE_TIMER_INTERRUPT:
		handle_timer_interrupt();
		break;
	}
}