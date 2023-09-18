#pragma once

#include <stdint.h>
#include <stdbool.h>

#define NO_INTR 0xFF

void intr_set_mask(uint32_t mask);
void intr_allow_single(uint8_t irq);
void intr_allow_all(void);
void intr_block_single(uint8_t irq);
void intr_block_all(void);

uint16_t intr_get_statuses(void);

uint8_t intr_get_next(void);