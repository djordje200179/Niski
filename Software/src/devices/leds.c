#include "devices/leds.h"

extern volatile struct {
	struct {
		bool en : 1;

		uint32_t : 0;
	} ctrl;

	union leds_state data;
} LEDS;

void leds_on(void) {
	LEDS.ctrl.en = true;
}

void leds_off(void) {
	LEDS.ctrl.en = false;
}

void leds_set_single(uint8_t led, bool state) {
	LEDS.data.leds[led] = state;
}

void leds_set(union leds_state state) {
	LEDS.data = state;
}

void leds_toggle_single(uint8_t led) {
	LEDS.data.leds[led] = !LEDS.data.leds[led];
}