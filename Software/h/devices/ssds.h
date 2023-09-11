#pragma once

#include <stdint.h>

void ssds_on(void);
void ssds_off(void);

void ssds_set_single(uint8_t digit, uint8_t segments);
void ssds_set(uint32_t segments);
void ssds_set_dots(uint8_t states);

void ssds_set_digit(uint8_t digit, uint8_t value);
void ssds_set_number(uint16_t number);
