#include <stddef.h>
#include "devices/intr_manager.h"
#include "devices/ssds.h"
#include "kernel/riscv.h"
#include "kernel/exceptions.h"

enum external_interrupt_type {
	EXT_INTR_TYPE_PS2 = 1,
	EXT_INTR_TYPE_UART = 2,
	EXT_INTR_TYPE_IR = 3,
	EXT_INTR_TYPE_BTN = 4
};

static void handle_button_press(void* arg) {
	uint32_t btn_data = *(uint32_t*)0x70000064;
	ssds_set_hex_number(btn_data);
}

static void (*ext_intr_handlers[16])(void*) = {
	[4] = handle_button_press
};

static void* ext_intr_args[16] = {NULL};

void handle_ext_intr() {
	while (true) {
		uint8_t intr = intr_get_next();
		if (intr == NO_INTR)
			break;
		
		void (*handler)(void*) = ext_intr_handlers[intr];
		void* arg = ext_intr_args[intr];

		if (handler != NULL)
			handler(arg);
	}

	clear_interrupt(EXTERNAL_INTERRUPT);
}