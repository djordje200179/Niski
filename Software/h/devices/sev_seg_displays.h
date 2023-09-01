#pragma once

#include "stdbool.h"
#include "stdint.h"

void sev_seg_displays_on(void);
void sev_seg_displays_off(void);

void sev_seg_displays_set_single(uint8_t digit, uint8_t segments);
void sev_seg_displays_set(uint32_t segments);
void sev_seg_displays_set_dots(uint8_t states);

void sev_seg_displays_set_digit(uint8_t digit, uint8_t value);
void sev_seg_displays_set_number(uint16_t number);
