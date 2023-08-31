#include "devices/buzzer.h"

static char* ctrl_addr = (char*) 0x70000010;
static char* data_addr = (char*) 0x70000018;

void buzzer_on(void) {
    *ctrl_addr = 0b1;
}

void buzzer_off(void) {
    *ctrl_addr = 0b0;
}

void buzzer_set(bool state) {
    *data_addr = state ? 0b1 : 0b0;
}