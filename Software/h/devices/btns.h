#pragma once

#include <stdint.h>
#include <stdbool.h>

void btns_enable_single(uint8_t btn);
void btns_disable_single(uint8_t btn);
void btns_enable_all(void);
void btns_disable_all(void);

union btns_status {
	uint32_t status;

	bool pressed[4];
};

union btns_status btns_get_statuses(void);

static inline bool btns_is_pressed(uint8_t btn) {
	return btns_get_statuses().pressed[btn];
}

#define SIGBTN0 __SIGNAL_BTN_0
#define SIGBTN1 __SIGNAL_BTN_1
#define SIGBTN2 __SIGNAL_BTN_2
#define SIGBTN3 __SIGNAL_BTN_3