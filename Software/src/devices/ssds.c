#include "devices/ssds.h"

extern volatile struct {
	uint32_t ctrl;

	union {
		uint32_t data;
		uint8_t digits[4];
	};
	
	uint32_t dots;
} SSDS;


void ssds_on(void) {
	SSDS.ctrl = 0b1;
}

void ssds_off(void) {
	SSDS.ctrl = 0b0;
}

void ssds_set_single(uint8_t digit, uint8_t segments) {
	segments &= 0b01111111u;
	SSDS.digits[digit] = segments;
}

void ssds_set(uint32_t segments) {
	segments &= 0b01111111011111110111111101111111u;
	SSDS.data = segments;
}

void ssds_set_dots(uint8_t states) {
	SSDS.dots = states;
}

void ssds_set_digit(uint8_t digit, unsigned char value) {
	value |= 0b10000000u;
	SSDS.digits[digit] = value;
}

void ssds_set_dec_number(short number) {
	uint32_t value = 0;
	for (uint8_t i = 0; i < 4; i++) {
		uint16_t digit = number % 10;
		digit |= 0b10000000u;

		value <<= 8;
		value |= digit;
		
		number /= 10;
	}

	SSDS.data = value;
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

	SSDS.data = value;
}