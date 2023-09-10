#include "kernel/mem_allocator.h"

#define KMEM_BLOCK_SIZE 64

struct mem_segment {
	size_t blocks;

	struct mem_segment* next;
	struct mem_segment* prev;

	char data[];
};

extern struct mem_segment HEAP_START_ADDR = {
	.next = NULL,
	.prev = NULL
};

static struct mem_segment* head_segment = &HEAP_START_ADDR;

void kmem_init() {
	extern char HEAP_END_ADDR;
	
	size_t bytes = (size_t)(&HEAP_END_ADDR - (char*)&HEAP_START_ADDR);
	head_segment->blocks = bytes / KMEM_BLOCK_SIZE;
}

static size_t calculate_blocks(size_t bytes) {
	bytes += sizeof(struct mem_segment);

	size_t blocks = bytes / KMEM_BLOCK_SIZE;
	if(bytes % KMEM_BLOCK_SIZE)
		blocks++;

	return blocks;
}

void* kmem_alloc(size_t bytes) {
	size_t blocks = calculate_blocks(bytes);

	struct mem_segment* valid_segment;
	for (valid_segment = head_segment; valid_segment; valid_segment = valid_segment->next) {
		if(valid_segment->blocks >= blocks)
			break;
	}

	if (!valid_segment)
		return NULL;

	struct mem_segment* prev_segment = valid_segment->prev;
	struct mem_segment* next_segment = valid_segment->next;

	if (valid_segment->blocks > blocks) {
		struct mem_segment* new_segment = (struct mem_segment*)((char*)valid_segment + blocks * KMEM_BLOCK_SIZE);

		new_segment->blocks = valid_segment->blocks - blocks;

		if (prev_segment)
			prev_segment->next = new_segment;
		else
			head_segment = new_segment;

		if (next_segment)
			next_segment->prev = new_segment;
		
		new_segment->prev = valid_segment;
		new_segment->next = next_segment;
	} else {
		if (prev_segment)
			prev_segment->next = next_segment;
		else
			head_segment = next_segment;

		if (next_segment)
			next_segment->prev = prev_segment;
	}

	valid_segment->blocks = blocks;
	valid_segment->prev = NULL;
	valid_segment->next = NULL;

	return &valid_segment->data;
}

static void segment_try_join_next(struct mem_segment* segment) {
	if (!segment->next)
		return;

	if ((char*)segment + segment->blocks * KMEM_BLOCK_SIZE != (char*)segment->next)
		return;

	segment->blocks += segment->next->blocks;
	segment->next = segment->next->next;
	if (segment->next)
		segment->next->prev = segment;
}

void kmem_dealloc(void* ptr) {
	struct mem_segment* segment = (struct mem_segment*)(ptr) - 1;

	struct mem_segment* prev_segment;
	for (prev_segment = head_segment; prev_segment; prev_segment = prev_segment->next) {
		if (prev_segment > segment)
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
	
	segment_try_join_next(segment);
	if (segment->prev)
		segment_try_join_next(segment->prev);
}