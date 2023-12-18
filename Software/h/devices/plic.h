#pragma once

#include <stdint.h>
#include <stdbool.h>

void plic_set_mask(uint32_t mask);
void plic_allow_single(uint8_t irq);
void plic_allow_all(void);
void plic_block_single(uint8_t irq);
void plic_block_all(void);

uint16_t plic_get_statuses(void);

uint8_t plic_get_next(void);