#pragma once

#include <stdint.h>
#include <stdbool.h>

void ssds_on(void);
void ssds_off(void);

union ssds_state {
	uint32_t data;

	struct ssds_display_state {
		uint8_t data : 7;
		uint8_t is_digit : 1;
	} digits[4];
};

void ssds_set(union ssds_state state);
void ssds_set_dots(uint8_t states);

void ssds_set_digit(uint8_t digit, unsigned char value);

static inline void ssds_set_dec_num(short number) {
	union ssds_state new_state = {0};

	for (uint8_t i = 0; i < 4; i++) {
		new_state.digits[3 - i].is_digit = true;
		new_state.digits[3 - i].data = number % 10;

		number /= 10;
	}

	ssds_set(new_state);
}

static inline void ssds_set_hex_num(unsigned short number) {
	union ssds_state new_state = {0};

	for (uint8_t i = 0; i < 4; i++) {
		new_state.digits[3 - i].is_digit = true;
		new_state.digits[3 - i].data = number & 0xF;

		number >>= 4;
	}

	ssds_set(new_state);
}