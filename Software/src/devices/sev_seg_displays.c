#include "devices/sev_seg_displays.h"

static char* ctrl_addr = (char*) 0x70000020;
static uint32_t* data_digits_addr = (uint32_t*) 0x70000028;
static char* data_dots_addr = (char*) 0x70000030;

void sev_seg_displays_on(void) {
	*ctrl_addr = 0b1;
}

void sev_seg_displays_off(void) {
	*ctrl_addr = 0b0;
}

void sev_seg_displays_set_single(uint8_t digit, uint8_t segments) {
	segments &= 0b01111111;
	((char*)data_digits_addr)[digit] = segments;
}

void sev_seg_displays_set(uint32_t segments) {
	segments &= 0b01111111011111110111111101111111;
	*data_digits_addr = segments;
}

void sev_seg_displays_set_dots(uint8_t states) {
	*data_dots_addr = states;
}

void sev_seg_displays_set_digit(uint8_t digit, uint8_t value) {
	value |= 0b10000000;
	((char*)data_digits_addr)[digit] = value;
}

void sev_seg_displays_set_number(uint16_t number) {
	for (int8_t i = 3; i >= 0; i--) {
		uint8_t digit = number % 10;
		number /= 10;
		sev_seg_displays_set_digit(i, digit);
	}
}