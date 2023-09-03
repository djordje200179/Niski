#pragma once

#include "stdbool.h"
#include "stdint.h"

void leds_on(void);
void leds_off(void);

void leds_set_single(uint8_t led, bool state);
void leds_set_all(uint8_t states);