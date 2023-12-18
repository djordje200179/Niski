#pragma once

#include "stdbool.h"
#include "stdint.h"

void leds_on(void);
void leds_off(void);

union leds_state {
	uint32_t data;
	
	bool leds[4];
};

void leds_set_single(uint8_t led, bool state);
void leds_toggle_single(uint8_t led);

void leds_set(union leds_state state);