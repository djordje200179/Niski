#include "devices/leds.h"

extern volatile uint8_t LEDS_CTRL_REG;
extern volatile uint32_t LEDS_DATA_REG;

#define LEDS_DATA_ARRAY ((uint8_t*)&LEDS_DATA_REG)

void leds_on(void) {
	LEDS_CTRL_REG = 0b1;
}

void leds_off(void) {
	LEDS_CTRL_REG = 0b0;
}

void leds_set_single(uint8_t led, bool state) {
	LEDS_DATA_ARRAY[led] = state;
}

void leds_set(uint8_t states) {
	uint32_t data = 0;
	for (int i = 0; i < 4; i++)
		data |= ((states >> i) & 0b1) << (i * 8);
	
	LEDS_DATA_REG = data;
}