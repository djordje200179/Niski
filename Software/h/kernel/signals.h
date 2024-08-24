#pragma once

#include <stdint.h>

enum ksignal {
	KSIGNAL_ABORT = 0x01,
	KSIGNAL_ILLEGAL = 0x02,
	KSIGNAL_INTERRUPT = 0x03,
	KSIGNAL_MEM_ACCESS = 0x04,
	
	KSIGNAL_KEY = 0x05,
	KSIGNAL_BTN_0 = 0x06,
	KSIGNAL_BTN_1 = 0x07,
	KSIGNAL_BTN_2 = 0x08,
	KSIGNAL_BTN_3 = 0x09
};

extern volatile uint32_t* ksig_addr;

typedef void (*ksignal_handler_t)(enum ksignal);

void ksignal_init();

ksignal_handler_t ksignal_handle(enum ksignal sig, ksignal_handler_t handler);
void ksignal_send(enum ksignal sig);