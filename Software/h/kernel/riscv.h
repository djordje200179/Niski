#pragma once

#include <stdint.h>

static inline void clear_interrupt(uint32_t irq) {
	irq = 1 << irq;
	__asm__ ("csrc sip, %0" : : "r" (irq));
}