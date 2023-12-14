#include "devices/buzzer.h"
#include <stdint.h>

extern volatile struct {
	uint32_t ctrl;
	uint32_t data;
} BUZZER;

void buzzer_on(void) {
	BUZZER.ctrl = 0b1;
}

void buzzer_off(void) {
	BUZZER.ctrl = 0b0;
}

void buzzer_set(bool state) {
	BUZZER.ctrl = state;
}