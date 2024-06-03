#include <stddef.h>
#include "kernel/signals.h"
#include "kernel/sync/thread.h"
#include "kernel/sync/scheduler.h"
#include "devices/ssds.h"
#include <threads.h>

static void handle_illegal_action(enum ksignal cause) {
	ssds_on();

	ssds_set_dec_num((short)cause);

	while(true);
}

typedef void (*handler_t)(enum ksignal);

static handler_t handlers[100] = {
	[KSIGNAL_ILLEGAL] = handle_illegal_action,
	[KSIGNAL_MEM_ACCESS] = handle_illegal_action,
	[KSIGNAL_ABORT] = handle_illegal_action,
};

static volatile enum ksignal requests[10] = {};
static volatile size_t head = 0, tail = 0;

mtx_t requests_mutex;
cnd_t requests_cond;

_Noreturn static int signal_processor() {
	while (true) {
		mtx_lock(&requests_mutex);
		while (head == tail)
			cnd_wait(&requests_cond, &requests_mutex);

		enum ksignal sig = requests[head];
		head = (head + 1) % 10;
		mtx_unlock(&requests_mutex);

		if (handlers[sig])
			handlers[sig](sig);
	}
}

void ksignal_init() {
	mtx_init(&requests_mutex, mtx_plain);
	cnd_init(&requests_cond);

	struct kthread* thread = kthread_create((void*)signal_processor, NULL, false);
	kscheduler_enqueue(thread);
}

void ksignal_send(enum ksignal sig) {
	mtx_lock(&requests_mutex);
	requests[tail] = sig;
	tail = (tail + 1) % 10;
	cnd_signal(&requests_cond);
	mtx_unlock(&requests_mutex);
}
