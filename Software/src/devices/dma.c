#include "devices/dma.h"
#include <stdint.h>

extern volatile struct DMA {
	uint32_t ctrl;
	char* src;
	char* dest;
	size_t cnt;
} DMA;

void dma_transfer(
	char* src, char* dest, size_t count, 
	enum dma_addressing_mode src_addr_mode, enum dma_addressing_mode dest_addr_mode, bool burst_mode
) {
	if (count == 0) 
		return;
		
	uint8_t ctrl = 0;
	ctrl |= src_addr_mode << 2;
	ctrl |= dest_addr_mode;
	ctrl |= burst_mode << 4;

	DMA.src = src;
	DMA.dest = dest;
	DMA.cnt = count;
	DMA.ctrl = ctrl;

	while (DMA.cnt != 0);
}

void dma_copy(char* src, char* dest, size_t count, bool burst_mode) {
	dma_transfer(
		src, dest, count,
		DMA_ADDRESS_INCREMENT, DMA_ADDRESS_INCREMENT, burst_mode
	);
}

void dma_rcopy(char* src, char* dest, size_t count, bool burst_mode) {
	char* src_end = src + count - 1;
	char* dest_end = dest + count - 1;

	dma_transfer(
		src_end, dest_end, count,
		DMA_ADDRESS_DECREMENT, DMA_ADDRESS_DECREMENT, burst_mode
	);
}

void dma_fill(char* dest, size_t count, char value, bool burst_mode) {
	dma_transfer(
		&value, dest, count,
		DMA_ADDRESS_FIXED, DMA_ADDRESS_INCREMENT, burst_mode
	);
}