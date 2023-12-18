#include "devices/plic.h"

extern volatile struct {
	uint32_t pending;
	uint32_t mask;
	const uint32_t claim;
} PLIC;

void plic_set_mask(uint32_t mask) {
	PLIC.mask = mask;
}

void plic_allow_single(uint8_t irq) {
	PLIC.mask |= (1 << irq);
}

void plic_allow_all(void) {
	PLIC.mask = 0xFFFF;
}

void plic_block_single(uint8_t irq) {
	PLIC.mask &= ~(1 << irq);
}

void plic_block_all(void) {
	PLIC.mask = 0;
}

uint16_t plic_get_statuses(void) {
	return PLIC.pending;
}

uint8_t plic_get_next(void) {
	return PLIC.claim;
}