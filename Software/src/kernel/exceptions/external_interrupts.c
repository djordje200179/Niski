#include <stddef.h>
#include "devices/intr_mngr.h"
#include "devices/ssds.h"
#include "devices/btns.h"
#include "kernel/riscv.h"
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

static void handle_btn_0_press(void* arg) {
	ssds_set_hex_number(1);
}

static void handle_btn_1_press(void* arg) {
	ssds_set_hex_number(2);
}

static void handle_btn_2_press(void* arg) {
	ssds_set_hex_number(3);
}

static void handle_btn_3_press(void* arg) {
	ssds_set_hex_number(4);
}

static void (*ext_intr_handlers[16])(void*) = {
	[EXT_INTR_TYPE_BTN_0] = handle_btn_0_press,
	[EXT_INTR_TYPE_BTN_1] = handle_btn_1_press,
	[EXT_INTR_TYPE_BTN_2] = handle_btn_2_press,
	[EXT_INTR_TYPE_BTN_3] = handle_btn_3_press
};

static void* ext_intr_args[16] = {NULL};

void handle_ext_intr() {
	while (true) {
		uint8_t intr = intr_mngr_get_next();
		if (!intr)
			break;
		
		void (*handler)(void*) = ext_intr_handlers[intr];
		void* arg = ext_intr_args[intr];

		if (handler != NULL)
			handler(arg);
	}

	clear_interrupt(EXTERNAL_INTERRUPT);
}