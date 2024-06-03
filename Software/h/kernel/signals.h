#pragma once

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

void ksignal_init();

void ksignal_send(enum ksignal sig);