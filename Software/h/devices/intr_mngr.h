#pragma once

#include <stdint.h>
#include <stdbool.h>

void intr_mngr_set_mask(uint32_t mask);
void intr_mngr_allow_single(uint8_t irq);
void intr_mngr_allow_all(void);
void intr_mngr_block_single(uint8_t irq);
void intr_mngr_block_all(void);

uint16_t intr_mngr_get_statuses(void);

#define NO_INTR 0xFF
uint8_t intr_mngr_get_next(void);