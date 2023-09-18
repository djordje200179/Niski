#include "devices/intr_manager.h"

extern uint16_t PENDING_INTR_REG;
extern uint16_t ENABLE_INTR_REG;
extern uint8_t CLAIM_INTR_REG;

void intr_set_mask(uint32_t mask) {
	ENABLE_INTR_REG = mask;
}

void intr_allow_single(uint8_t irq) {
	ENABLE_INTR_REG |= (1 << irq);
}

void intr_allow_all(void) {
	ENABLE_INTR_REG = 0xFFFF;
}
void intr_block_single(uint8_t irq) {
	ENABLE_INTR_REG &= ~(1 << irq);
}

void intr_block_all(void) {
	ENABLE_INTR_REG = 0;
}

uint16_t intr_get_statuses(void) {
	return PENDING_INTR_REG;
}

uint8_t intr_get_next(void) {
	return CLAIM_INTR_REG;
}