#include "devices/dma.h"
#include <stdint.h>

extern volatile uint8_t DMA_CTRL_REG;
extern volatile char* DMA_SRC_REG;
extern volatile char* DMA_DEST_REG;
extern volatile size_t DMA_CNT_REG;

void dma_transfer(
	char* src, char* dest, size_t count, 
	enum dma_addressing_mode src_addr_mode, enum dma_addressing_mode dest_addr_mode, bool burst_mode
) {
	if (count == 0) 
		return;
		
	uint8_t ctrl = 0;

	switch (src_addr_mode) {
	case DMA_ADDRESS_INCREMENT:
		ctrl |= 0b1100;
	case DMA_ADDRESS_DECREMENT:
		ctrl |= 0b1000;
		break;
	}

	switch (dest_addr_mode) {
	case DMA_ADDRESS_INCREMENT:
		ctrl |= 0b0011;
		break;
	case DMA_ADDRESS_DECREMENT:
		ctrl |= 0b0010;
		break;
	}

	if (burst_mode)
		ctrl |= 0b00010000;

	DMA_SRC_REG = src;
	DMA_DEST_REG = dest;
	DMA_CNT_REG = count;

	DMA_CTRL_REG = ctrl;

	while (DMA_CNT_REG != 0);
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