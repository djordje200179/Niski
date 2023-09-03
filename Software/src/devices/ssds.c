#include "devices/ssds.h"

extern uint32_t SSDS_CTRL_REG;
extern uint32_t SSDS_DATA_DIGITS_REG;
extern uint32_t SSDS_DATA_DOTS_REG;

#define SSDS_DATA_DIGITS_ARRAY ((uint8_t*)&SSDS_DATA_DIGITS_REG)

void ssds_on(void) {
	SSDS_CTRL_REG = 0b1;
}

void ssds_off(void) {
	SSDS_CTRL_REG = 0b0;
}

void ssds_set_single(uint8_t digit, uint8_t segments) {
	segments &= 0b01111111;
	SSDS_DATA_DIGITS_ARRAY[digit] = segments;
}

void ssds_set_all(uint32_t segments) {
	segments &= 0b01111111011111110111111101111111;
	SSDS_DATA_DIGITS_REG = segments;
}

void ssds_set_dots(uint8_t states) {
	SSDS_DATA_DOTS_REG = states;
}

void ssds_set_digit(uint8_t digit, uint8_t value) {
	value |= 0b10000000;
	SSDS_DATA_DIGITS_ARRAY[digit] = value;
}

void ssds_set_number(uint16_t number) {
	for (int8_t i = 3; i >= 0; i--) {
		uint8_t digit = number % 10;
		number /= 10;
		ssds_set_digit(i, digit);
	}
}