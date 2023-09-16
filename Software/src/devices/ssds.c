#include "devices/ssds.h"

extern volatile uint8_t SSDS_CTRL_REG;
extern volatile uint32_t SSDS_DATA_DIGITS_REG;
extern volatile uint8_t SSDS_DATA_DOTS_REG;

#define SSDS_DATA_DIGITS_ARRAY ((uint8_t*)&SSDS_DATA_DIGITS_REG)

void ssds_on(void) {
	SSDS_CTRL_REG = 0b1;
}

void ssds_off(void) {
	SSDS_CTRL_REG = 0b0;
}

void ssds_set_single(uint8_t digit, uint8_t segments) {
	segments &= 0b01111111u;
	SSDS_DATA_DIGITS_ARRAY[digit] = segments;
}

void ssds_set(uint32_t segments) {
	segments &= 0b01111111011111110111111101111111u;
	SSDS_DATA_DIGITS_REG = segments;
}

void ssds_set_dots(uint8_t states) {
	SSDS_DATA_DOTS_REG = states;
}

void ssds_set_digit(uint8_t digit, unsigned char value) {
	value |= 0b10000000u;
	SSDS_DATA_DIGITS_ARRAY[digit] = value;
}

void __attribute__((optimize("O0"))) ssds_set_dec_number(short number) {
	uint32_t value = 0;
	for (uint8_t i = 0; i < 4; i++) {
		uint16_t digit = number % 10;
		digit |= 0b10000000u;

		value <<= 8;
		value |= digit;
		
		number /= 10;
	}

	SSDS_DATA_DIGITS_REG = value;
}

void ssds_set_hex_number(unsigned short number) {
	uint32_t value = 0;
	for (uint8_t i = 0; i < 4; i++) {
		uint16_t digit = number & 0xF;
		digit |= 0b10000000u;

		value <<= 8;
		value |= digit;

		number >>= 4;
	}

	SSDS_DATA_DIGITS_REG = value;
}