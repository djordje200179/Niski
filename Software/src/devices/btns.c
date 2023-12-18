#include "devices/btns.h"

extern volatile struct {
	struct {
		uint8_t irqs : 4;

		uint32_t : 0;
	} ctrl;

	union btns_status data;
} BTNS;

void btns_enable_single(uint8_t btn) {
	BTNS.ctrl.irqs |= 1 << btn;
}

void btns_enable_all(void) {
	BTNS.ctrl.irqs = 0xF;
}

void btns_disable_single(uint8_t btn) {
	BTNS.ctrl.irqs &= ~(1 << btn);
}

void btns_disable_all(void) {
	BTNS.ctrl.irqs = 0;
}

union btns_status btns_get_statuses(void) {
	return BTNS.data;
}