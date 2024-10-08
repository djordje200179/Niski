#pragma once

#include <stdint.h>
#include <stdbool.h>
#include "common/threads.h"

enum cpu_reg {
	REG_ZERO,
	REG_RA, REG_SP, REG_GP, REG_TP,
	REG_T0, REG_T1, REG_T2,
	REG_S0, REG_S1, 
	REG_A0, REG_A1, REG_A2, REG_A3, REG_A4, REG_A5, REG_A6, REG_A7,
	REG_S2, REG_S3, REG_S4, REG_S5, REG_S6, REG_S7, REG_S8, REG_S9, REG_S10, REG_S11,
	REG_T3, REG_T4, REG_T5, REG_T6
};

struct kthread {
	struct kcontext {
		uint32_t regs[16];
		uint32_t status;

		uint32_t* pc;
	} context;
	
	uint32_t* stack;
	void* tdata;

	struct kthread* next;
	struct kmutex* waiting_on;

	struct kthread_ld* local_data_head;
	
	enum kthread_state {
		KTHREAD_STATE_CREATED,
		KTHREAD_STATE_READY,
		KTHREAD_STATE_RUNNING,
		KTHREAD_STATE_BLOCKED
	} state;
};

extern struct kthread* kthread_current;

struct kthread* kthread_create(int (*function)(void*), void* arg, bool supervisor_mode);
void kthread_dispatch();
void kthread_stop();
void kthread_destroy(struct kthread* thread);