#include "devices/buzzer.h"
#include <stdint.h>

extern volatile uint8_t BUZZER_CTRL_REG;
extern volatile uint8_t BUZZER_DATA_REG;

void buzzer_on(void) {
	BUZZER_CTRL_REG = 0b1;
}

void buzzer_off(void) {
	BUZZER_CTRL_REG = 0b0;
}

void buzzer_set(bool state) {
	BUZZER_DATA_REG = state ? 0b1 : 0b0;
}