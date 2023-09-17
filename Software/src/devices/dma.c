#include "devices/dma.h"
#include <stdint.h>

extern volatile uint8_t DMA_CTRL_REG;
extern volatile char* DMA_SRC_REG;
extern volatile char* DMA_DEST_REG;
extern volatile size_t DMA_CNT_REG;

void dma_transfer(
	char* src, char* dest, size_t count, 
	bool move_src, bool move_dest, bool incr_src, bool incr_dst
) {
	if (count == 0) 
		return;
		
	uint8_t ctrl = 0;
	if (move_src) ctrl |= 0b1000;
	if (move_dest) ctrl |= 0b0100;
	if (incr_src) ctrl |= 0b0010;
	if (incr_dst) ctrl |= 0b0001;

	DMA_SRC_REG = src;
	DMA_DEST_REG = dest;
	DMA_CNT_REG = count;

	DMA_CTRL_REG = ctrl;

	while (DMA_CNT_REG != 0);
}

void dma_copy(char* src, char* dest, size_t count) {
	dma_transfer(
		src, dest, count,
		true, true, true, true
	);
}

void dma_fill(char* dest, size_t count, char value) {
	dma_transfer(
		&value, dest, count,
		false, true, false, true
	);
}