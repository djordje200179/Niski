#include <stdint.h>
#include "kernel/sync/thread.h"
#include "devices/ssds.h"

enum exception_type {
	EXC_TYPE_INST_ADDR_MISALIGNED = 0,
	EXC_TYPE_INST_ACCESS_FAULT = 1,
	EXC_TYPE_ILLEGAL_INST = 2,

	EXC_TYPE_LOAD_ADDR_MISALIGNED = 4,
	EXC_TYPE_LOAD_ACCESS_FAULT = 5,
	EXC_TYPE_STORE_ADDR_MISALIGNED = 6,
	EXC_TYPE_STORE_ACCESS_FAULT = 7,

	EXC_TYPE_USER_ECALL = 8,
	EXC_TYPE_SUPERVISOR_ECALL = 9,

	EXC_TYPE_INTR_TIMER = (1U << 31) | 5,
	EXC_TYPE_INTR_EXT = (1U << 31) | 9
};

static void handle_illegal_action(enum exception_type type) {
	ssds_on();

	ssds_set_dec_number(type);

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
	case EXC_TYPE_INST_ADDR_MISALIGNED:
	case EXC_TYPE_INST_ACCESS_FAULT:
	case EXC_TYPE_ILLEGAL_INST:
	case EXC_TYPE_LOAD_ADDR_MISALIGNED:
	case EXC_TYPE_LOAD_ACCESS_FAULT:
	case EXC_TYPE_STORE_ADDR_MISALIGNED:
	case EXC_TYPE_STORE_ACCESS_FAULT:
		handle_illegal_action(type);
		break;
	case EXC_TYPE_INTR_EXT:
		handle_ext_intr();
		break;
	case EXC_TYPE_INTR_TIMER:
		handle_timer_interrupt();
		break;
	}
}