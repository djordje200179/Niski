#pragma once

#include "common/signals.h"
#include <stdint.h>

extern volatile uint32_t* ksig_addr;

typedef void (*ksignal_handler_t)(enum __signal);

void ksignal_init();

ksignal_handler_t ksignal_handle(enum __signal sig, ksignal_handler_t handler);
void ksignal_send(enum __signal sig);