#pragma once

#include <stdbool.h>
#include <stddef.h>

void dma_transfer(
	char* src, char* dest, size_t count, 
	bool move_src, bool move_dest, bool incr_src, bool incr_dst
);

void dma_copy(char* src, char* dest, size_t count);
void dma_fill(char* dest, size_t count, char value);