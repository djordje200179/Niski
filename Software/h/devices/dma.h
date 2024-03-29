#pragma once

#include <stdbool.h>
#include <stddef.h>

enum dma_addressing_mode {
	DMA_ADDRESS_FIXED 		= 0b00,
	DMA_ADDRESS_INCREMENT	= 0b11,
	DMA_ADDRESS_DECREMENT	= 0b10
};

void dma_transfer(
	char* src, char* dest, size_t count, 
	enum dma_addressing_mode src_addr_mode, enum dma_addressing_mode dest_addr_mode, bool burst_mode
);

void dma_copy(char* src, char* dest, size_t count, bool burst_mode);
void dma_rcopy(char* src, char* dest, size_t count, bool burst_mode);
void dma_fill(char* dest, size_t count, char value, bool burst_mode);