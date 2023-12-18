#include "devices/ssds.h"
#include <stdbool.h>

extern volatile struct {
	struct {
		bool en : 1;

		uint32_t : 0;
	} ctrl;

	union ssds_state data;
	
	uint32_t dots;
} SSDS;


void ssds_on(void) {
	SSDS.ctrl.en = true;
}

void ssds_off(void) {
	SSDS.ctrl.en = false;
}

void ssds_set(union ssds_state state) {
	SSDS.data = state;
}

void ssds_set_dots(uint8_t states) {
	SSDS.dots = states;
}

void ssds_set_digit(uint8_t digit, unsigned char value) {
	SSDS.data.digits[digit] = (struct ssds_display_state) {
		.data = value,
		.is_digit = true
	};
}