#include <stddef.h>
#include "kernel/signals.h"
#include "kernel/sync/thread.h"
#include "kernel/sync/mutex.h"
#include "kernel/sync/condition.h"
#include "kernel/sync/scheduler.h"
#include "devices/lcd.h"
#include "devices/leds.h"
#include <stdio.h>
#include <threads.h>

volatile uint32_t* ksig_addr;

static void handle_illegal_action(enum ksignal cause) {
	lcd_clear();

	puts("FATAL SIGNAL ");
	char cause_str[4];
	cause_str[0] = '0' + (cause / 10);
	cause_str[1] = '0' + (cause % 10);
	cause_str[2] = '\n';
	cause_str[3] = '\0';
	puts(cause_str);

	puts("Addr: ");
	uint32_t addr_repr = (uint32_t)ksig_addr;
	char addr_str[11];
	addr_str[0] = '0';
	addr_str[1] = 'x';
	for (int i = 0; i < 8; i++)
		addr_str[i + 2] = "0123456789ABCDEF"[((addr_repr >> (28 - i * 4)) & 0xF)];
	addr_str[10] = '\0';
	puts(addr_str);
}

static ksignal_handler_t handlers[] = {
	[KSIGNAL_ILLEGAL] = handle_illegal_action,
	[KSIGNAL_MEM_ACCESS] = handle_illegal_action,
	[KSIGNAL_ABORT] = handle_illegal_action,
	[KSIGNAL_INTERRUPT] = NULL,
	
	[KSIGNAL_KEY] = NULL,
	[KSIGNAL_BTN_0] = NULL,
	[KSIGNAL_BTN_1] = NULL,
	[KSIGNAL_BTN_2] = NULL,
	[KSIGNAL_BTN_3] = NULL
};

static volatile enum ksignal requests[10] = {};
static volatile size_t head = 0, tail = 0;

struct kmutex requests_mutex;
struct kcond requests_cond;

_Noreturn static int signal_processor(void* arg) {	
	static mtx_t mutex = &requests_mutex;
	static cnd_t cond = &requests_cond;

	while (true) {
		mtx_lock(&mutex);
		while (head == tail)
			cnd_wait(&cond, &mutex);

		enum ksignal sig = requests[head];
		head = (head + 1) % 10;
		mtx_unlock(&mutex);

		lcd_clear();
		puts("HEAD: ");
		char head_str[2];
		head_str[0] = '0' + (head / 10);
		head_str[1] = '\0';
		puts(head_str);

		puts("\nTAIL: ");
		head_str[0] = '0' + (tail / 10);
		puts(head_str);

		if (handlers[sig])
			handlers[sig](sig);
	}
}

void ksignal_init() {
	kmutex_init(&requests_mutex, false);
	kcond_init(&requests_cond);

	struct kthread* thread = kthread_create(signal_processor, NULL, false);
	kscheduler_enqueue(thread);
}

ksignal_handler_t ksignal_handle(enum ksignal sig, ksignal_handler_t handler) {
	ksignal_handler_t old_handler = handlers[sig];
	handlers[sig] = handler;

	return old_handler;
}

void ksignal_send(enum ksignal sig) {
	leds_set_single(3, true);
	requests[tail] = sig;
	tail = (tail + 1) % 10;
	
	kcond_signal(&requests_cond, true);
}