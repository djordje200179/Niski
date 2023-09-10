#pragma once

#include <stdint.h>
#include "thread_status.h"

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
		uint32_t regs[32];
		
		void (*pc)();
	} context;

	uint32_t* stack;
	
	int (*function)(void*);
	void* arg;

	enum kthread_state {
		KTHREAD_STATE_CREATED,
		KTHREAD_STATE_READY,
		KTHREAD_STATE_RUNNING,
		KTHREAD_STATE_BLOCKED
	} state;
	struct kthread* next;
	struct kmutex* waiting_on;

	struct kthread_ld* local_data_head;
};

extern struct kthread* thread_current;

void kthread_init();

struct kthread* kthread_create(int (*function)(void*), void* arg);
void kthread_dispatch();
void kthread_enqueue(struct kthread* thread);
void kthread_destroy(struct kthread* thread);