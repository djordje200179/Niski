#include "devices/intr_mngr.h"

extern volatile struct {
	uint32_t pending;
	uint32_t mask;
	const uint32_t claim;
} INTR_MNGR;

void intr_mngr_set_mask(uint32_t mask) {
	INTR_MNGR.mask = mask;
}

void intr_mngr_allow_single(uint8_t irq) {
	INTR_MNGR.mask |= (1 << irq);
}

void intr_mngr_allow_all(void) {
	INTR_MNGR.mask = 0xFFFF;
}

void intr_mngr_block_single(uint8_t irq) {
	INTR_MNGR.mask &= ~(1 << irq);
}

void intr_mngr_block_all(void) {
	INTR_MNGR.mask = 0;
}

uint16_t intr_mngr_get_statuses(void) {
	return INTR_MNGR.pending;
}

uint8_t intr_mngr_get_next(void) {
	return INTR_MNGR.claim;
}