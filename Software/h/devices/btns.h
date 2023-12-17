#pragma once

#include <stdint.h>
#include <stdbool.h>

void btns_enable_single(uint8_t btn);
void btns_enable_all(void);
void btns_disable_single(uint8_t btn);
void btns_disable_all(void);

union btns_statuses {
	uint8_t pressed[4];
	uint32_t statuses;
};

union btns_statuses btns_get_statuses(void);

bool btns_is_pressed(uint8_t btn);

void __attribute__((weak)) btns_on_0_pressed(void) {}
//void __attribute__((weak)) btns_on_0_released(void) {}

void __attribute__((weak)) btns_on_1_pressed(void) {}
//void __attribute__((weak)) btns_on_1_released(void) {}

void __attribute__((weak)) btns_on_2_pressed(void) {}
//void __attribute__((weak)) btns_on_2_released(void) {}

void __attribute__((weak)) btns_on_3_pressed(void) {}
//void __attribute__((weak)) btns_on_3_released(void) {}
