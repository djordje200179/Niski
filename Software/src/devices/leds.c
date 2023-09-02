#include "devices/leds.h"

static uint32_t* ctrl_reg = (uint32_t*) 0x70000000;
static uint32_t* data_reg = (uint32_t*) 0x70000008;

void leds_on(void) {
    *ctrl_reg = 0b1;
}

void leds_off(void) {
    *ctrl_reg = 0b0;
}

void leds_set_single(uint8_t led, bool state) {
    ((uint8_t*)data_reg)[led] = state;
}

void leds_set(uint8_t states) {
    uint32_t data = 0;
    for (int i = 0; i < 4; i++)
        data |= ((states >> i) & 0b1) << (i * 8);
    
    *data_reg = data;
}