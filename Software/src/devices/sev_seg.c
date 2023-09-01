#include "devices/sev_seg.h"

static char* ctrl_addr = (char*) 0x70000020;
static uint32_t* data_digits_addr = (uint32_t*) 0x70000028;
static char* data_dots_addr = (char*) 0x70000030;

void sev_seg_on(void) {
    *ctrl_addr = 0b1;
}

void sev_seg_off(void) {
    *ctrl_addr = 0b0;
}

void sev_seg_set_single(uint8_t digit, uint8_t segments) {
    ((char*)data_digits_addr)[digit] = segments;
}

void sev_seg_set(uint32_t segments) {
    *data_digits_addr = segments;
}

void sev_seg_set_dots(uint8_t states) {
    *data_dots_addr = states;
}

static uint8_t digit_segments[] = {
    [0] = 0b1111110,
    [1] = 0b0110000,
    [2] = 0b1101101,
    [3] = 0b1111001,
    [4] = 0b0110011,
    [5] = 0b1011011,
    [6] = 0b1011111,
    [7] = 0b1110000,
    [8] = 0b1111111,
    [9] = 0b1111011,
    [10] = 0b1110111,
    [11] = 0b0011111,
    [12] = 0b1001110,
    [13] = 0b0111101,
    [14] = 0b1001111,
    [15] = 0b1000111
};

void sev_seg_set_digit(uint8_t digit, uint8_t value) {
    sev_seg_set_single(digit, digit_segments[value]);
}

void sev_seg_set_number(uint16_t number) {    
    for (int8_t i = 3; i >= 0; i--) {
        uint8_t digit = number % 10;
        number /= 10;
        sev_seg_set_digit(i, digit);
    }
}