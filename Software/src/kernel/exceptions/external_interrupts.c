#include <stddef.h>
#include "devices/plic.h"
#include "kernel/riscv.h"
#include "kernel/signals.h"
#include "kernel/exceptions.h"

enum external_interrupt_type {
	EXT_INTR_TYPE_PS2 = 1,
	EXT_INTR_TYPE_UART = 2,
	EXT_INTR_TYPE_IR = 3,

	EXT_INTR_TYPE_BTN_0 = 4,
	EXT_INTR_TYPE_BTN_1 = 5,
	EXT_INTR_TYPE_BTN_2 = 6,
	EXT_INTR_TYPE_BTN_3 = 7
};

static void (*ext_intr_handlers[16])(void*) = {
	[EXT_INTR_TYPE_BTN_0] = (void(*)(void*))ksignal_send,
	[EXT_INTR_TYPE_BTN_1] = (void(*)(void*))ksignal_send,
	[EXT_INTR_TYPE_BTN_2] = (void(*)(void*))ksignal_send,
	[EXT_INTR_TYPE_BTN_3] = (void(*)(void*))ksignal_send
};

static void* ext_intr_args[16] = {
	[EXT_INTR_TYPE_BTN_0] = (void*)KSIGNAL_BTN_0,
	[EXT_INTR_TYPE_BTN_1] = (void*)KSIGNAL_BTN_1,
	[EXT_INTR_TYPE_BTN_2] = (void*)KSIGNAL_BTN_2,
	[EXT_INTR_TYPE_BTN_3] = (void*)KSIGNAL_BTN_3
};

void handle_ext_intr() {
	while (true) {
		uint8_t intr = plic_get_next();
		if (!intr)
			break;
		
		void (*handler)(void*) = ext_intr_handlers[intr];
		void* arg = ext_intr_args[intr];

		if (handler != NULL)
			handler(arg);
	}

	clear_interrupt(EXTERNAL_INTERRUPT);
}