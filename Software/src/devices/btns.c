#include "devices/btns.h"

extern volatile struct {
	uint32_t ctrl;
	union btns_statuses statuses;
} BTNS;

void btns_enable_single(uint8_t btn) {
	BTNS.ctrl |= 1 << btn;
}

void btns_enable_all(void) {
	BTNS.ctrl |= 0xF;
}

void btns_disable_single(uint8_t btn) {
	BTNS.ctrl &= ~(1 << btn);
}

void btns_disable_all(void) {
	BTNS.ctrl &= ~0xF;
}

union btns_statuses btns_get_statuses(void) {
	return BTNS.statuses;
}

bool btns_is_pressed(uint8_t btn) {
	return BTNS.statuses.pressed[btn] == 1;
}