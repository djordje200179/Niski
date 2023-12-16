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