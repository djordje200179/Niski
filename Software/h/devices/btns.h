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

void __attribute__((weak)) btns_on_0_pressed(void) {}
//void __attribute__((weak)) btns_on_0_released(void) {}

void __attribute__((weak)) btns_on_1_pressed(void) {}
//void __attribute__((weak)) btns_on_1_released(void) {}

void __attribute__((weak)) btns_on_2_pressed(void) {}
//void __attribute__((weak)) btns_on_2_released(void) {}

void __attribute__((weak)) btns_on_3_pressed(void) {}
//void __attribute__((weak)) btns_on_3_released(void) {}
