#include "kernel/mem_alloc/heap_allocator.h"
#include <stdint.h>

#define KMEM_BLOCK_SIZE 64

struct mem_segment {
	size_t blocks;

	struct mem_segment* next;
	struct mem_segment* prev;

	char data[];
};

extern struct mem_segment HEAP_START;

static struct mem_segment* head_segment = &HEAP_START;

void kheap_init() {
	extern char HEAP_END;
	
	size_t bytes = (uintptr_t)&HEAP_END - (uintptr_t)&HEAP_START;
	size_t blocks = bytes / KMEM_BLOCK_SIZE;

	HEAP_START.blocks = blocks;
	HEAP_START.prev = NULL;
	HEAP_START.next = NULL;
}

static size_t calculate_blocks(size_t bytes) {
	bytes += sizeof(struct mem_segment);

	size_t blocks = bytes / KMEM_BLOCK_SIZE;
	if(bytes % KMEM_BLOCK_SIZE)
		blocks++;

	return blocks;
}

void* kheap_alloc(size_t bytes) {
	size_t blocks = calculate_blocks(bytes);

	struct mem_segment* valid_segment;
	for (valid_segment = head_segment; valid_segment; valid_segment = valid_segment->next) {
		if(valid_segment->blocks >= blocks)
			break;
	}

	if (!valid_segment)
		return NULL;

	size_t remaining_blocks = valid_segment->blocks - blocks;

	if (remaining_blocks > 0) {
		struct mem_segment* new_segment = (struct mem_segment*)((char*)valid_segment + blocks * KMEM_BLOCK_SIZE);

		new_segment->blocks = remaining_blocks;
		new_segment->next = valid_segment->next;
		new_segment->prev = valid_segment->prev;

		if (new_segment->next)
			new_segment->next->prev = new_segment;

		if (new_segment->prev)
			new_segment->prev->next = new_segment;
		else
			head_segment = new_segment;

		valid_segment->blocks = blocks;
	} else {
		if (valid_segment->prev)
			valid_segment->prev->next = valid_segment->next;
		else
			head_segment = valid_segment->next;

		if (valid_segment->next)
			valid_segment->next->prev = valid_segment->prev;
	}

	valid_segment->prev = NULL;
	valid_segment->next = NULL;

	return valid_segment->data;
}

static void try_join_next_segment(struct mem_segment* segment) {
	if (!segment->next)
		return;

	if ((char*)segment + segment->blocks * KMEM_BLOCK_SIZE != (char*)segment->next)
		return;

	segment->blocks += segment->next->blocks;
	segment->next = segment->next->next;
	if (segment->next)
		segment->next->prev = segment;
}

void kheap_dealloc(void* ptr) {
	struct mem_segment* segment = (struct mem_segment*)(ptr) - 1;

	struct mem_segment* prev_segment = NULL;
	for (struct mem_segment* curr = head_segment; curr; prev_segment = curr, curr = curr->next) {
		if (segment < curr)
			break;
	}

	segment->prev = prev_segment;
	segment->next = prev_segment ? prev_segment->next : head_segment;

	if (prev_segment)
		prev_segment->next = segment;
	else
		head_segment = segment;

	if (segment->next)
		segment->next->prev = segment;
	
	try_join_next_segment(segment);
	if (segment->prev)
		try_join_next_segment(segment->prev);
}