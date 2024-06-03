#include <stdint.h>
#include <stdbool.h>
#include "kernel/exceptions.h"
#include "devices/ssds.h"

static void handle_illegal_action(uint32_t cause) {
	ssds_on();

	ssds_set_dec_num((short)cause);

	while(true);
}

void exception_handler(uint32_t type) {	
	void handle_syscall();
	void handle_ext_intr();
	void handle_timer_interrupt();

	switch (type) {
	case EXCEPTION_USER_ECALL:
	case EXCEPTION_SUPERVISOR_ECALL:
		handle_syscall();
		break;	
	case EXCEPTION_INST_ADDR_MISALIGNED:
	case EXCEPTION_INST_ACCESS_FAULT:
	case EXCEPTION_ILLEGAL_INST:
	case EXCEPTION_LOAD_ADDR_MISALIGNED:
	case EXCEPTION_LOAD_ACCESS_FAULT:
	case EXCEPTION_STORE_ADDR_MISALIGNED:
	case EXCEPTION_STORE_ACCESS_FAULT:
		handle_illegal_action(type);
		break;
	case EXCEPTION_INTERRUPT | EXTERNAL_INTERRUPT:
		handle_ext_intr();
		break;
	case EXCEPTION_INTERRUPT | TIMER_INTERRUPT:
		handle_timer_interrupt();
		break;
	default:
		// TODO: Implement
		while(true);
	}
}