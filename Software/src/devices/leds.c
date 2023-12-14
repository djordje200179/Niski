#include "devices/leds.h"

extern volatile struct {
	uint32_t ctrl;

	union {
		uint32_t data;
		uint8_t digits[4];
	};
} LEDS;

void leds_on(void) {
	LEDS.ctrl = 0b1;
}

void leds_off(void) {
	LEDS.ctrl = 0b1;
}

void leds_set_single(uint8_t led, bool state) {
	LEDS.digits[led] = state;
}

void leds_set(uint8_t states) {
	uint32_t data = 0;
	for (int i = 0; i < 4; i++)
		data |= ((states >> i) & 0b1) << (i * 8);
	
	LEDS.data = data;
}