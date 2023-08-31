#pragma once

#include "stdbool.h"
#include "stdint.h"

void sev_seg_on(void);
void sev_seg_off(void);

void sev_seg_set_single(uint8_t digit, uint8_t segments);
void sev_seg_set(uint32_t segments);
void sev_seg_set_dots(uint8_t states);

void sev_seg_set_digit(uint8_t digit, uint8_t value);
void sev_seg_set_number(uint16_t number);
