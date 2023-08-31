#include "devices/leds.h"

static char* ctrl_addr = (char*) 0x70000000;
static char* data_addr = (char*) 0x70000008;

void leds_on(void) {
    *ctrl_addr = 0b1;
}

void leds_off(void) {
    *ctrl_addr = 0b0;
}

void leds_set_single(uint8_t led, bool state) {
    if (state)
        *data_addr |= (1 << led);
    else
        *data_addr &= ~(1 << led);
}

void leds_set(uint8_t states) {
    *data_addr = states;
}