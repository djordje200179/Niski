#include "devices/sev_seg_displays.h"

extern uint32_t SEV_SEG_DISPLAYS_CTRL_REG;
extern uint32_t SEV_SEG_DISPLAYS_DATA_DIGITS_REG;
extern uint32_t SEV_SEG_DISPLAYS_DATA_DOTS_REG;

#define SEV_SEG_DISPLAYS_DATA_DIGITS_ARRAY ((uint8_t*)&SEV_SEG_DISPLAYS_DATA_DIGITS_REG)

void sev_seg_displays_on(void) {
	SEV_SEG_DISPLAYS_CTRL_REG = 0b1;
}

void sev_seg_displays_off(void) {
	SEV_SEG_DISPLAYS_CTRL_REG = 0b0;
}

void sev_seg_displays_set_single(uint8_t digit, uint8_t segments) {
	segments &= 0b01111111;
	SEV_SEG_DISPLAYS_DATA_DIGITS_ARRAY[digit] = segments;
}

void sev_seg_displays_set(uint32_t segments) {
	segments &= 0b01111111011111110111111101111111;
	SEV_SEG_DISPLAYS_DATA_DIGITS_REG = segments;
}

void sev_seg_displays_set_dots(uint8_t states) {
	SEV_SEG_DISPLAYS_DATA_DOTS_REG = states;
}

void sev_seg_displays_set_digit(uint8_t digit, uint8_t value) {
	value |= 0b10000000;
	SEV_SEG_DISPLAYS_DATA_DIGITS_ARRAY[digit] = value;
}

void sev_seg_displays_set_number(uint16_t number) {
	for (int8_t i = 3; i >= 0; i--) {
		uint8_t digit = number % 10;
		number /= 10;
		sev_seg_displays_set_digit(i, digit);
	}
}