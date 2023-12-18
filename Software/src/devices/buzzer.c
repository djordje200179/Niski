#include "devices/buzzer.h"
#include <stdint.h>

extern volatile struct {
	struct {
		bool en : 1;

		uint32_t : 0;
	} ctrl;

	struct {
		bool state : 1;

		uint32_t : 0;
	} data;
} BUZZER;

void buzzer_on(void) {
	BUZZER.ctrl.en = true;
}

void buzzer_off(void) {
	BUZZER.ctrl.en = false;
}

void buzzer_set(bool state) {
	BUZZER.data.state = state;
}

void buzzer_toggle(void) {
	BUZZER.data.state = !BUZZER.data.state;
}