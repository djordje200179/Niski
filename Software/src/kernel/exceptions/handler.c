#include <stdint.h>
#include <stdbool.h>
#include "kernel/exceptions.h"
#include "kernel/signals.h"
#include "kernel/sync/thread.h"

void exception_handler(uint32_t type) {	
	void handle_syscall();
	void handle_ext_intr();

	switch (type) {
	case EXCEPTION_USER_ECALL:
	case EXCEPTION_SUPERVISOR_ECALL:
		handle_syscall();
		break;	
	case EXCEPTION_INST_ADDR_MISALIGNED:
	case EXCEPTION_INST_ACCESS_FAULT:
	case EXCEPTION_ILLEGAL_INST:
		ksig_addr = kthread_current->context.pc;
		ksignal_send(KSIGNAL_ILLEGAL);
		kthread_stop();
		break;
	case EXCEPTION_LOAD_ADDR_MISALIGNED:
	case EXCEPTION_LOAD_ACCESS_FAULT:
	case EXCEPTION_STORE_ADDR_MISALIGNED:
	case EXCEPTION_STORE_ACCESS_FAULT:
		ksig_addr = kthread_current->context.pc;
		ksignal_send(KSIGNAL_MEM_ACCESS);
		kthread_stop();
		break;
	case EXCEPTION_INTERRUPT | EXTERNAL_INTERRUPT:
		handle_ext_intr();
		break;
	case EXCEPTION_INTERRUPT | TIMER_INTERRUPT:
		kthread_dispatch();
		break;
	default:
		// TODO: Handle unreachable exception
		while(true);
	}
}