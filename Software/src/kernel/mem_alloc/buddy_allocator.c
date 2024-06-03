#include "kernel/mem_alloc/buddy_allocator.h"
#include <stdbool.h>
#include <stdint.h>

struct free_block {
	struct free_block* next;
	struct free_block* prev;

	size_t order;
};

#define block_size(block) ((uintptr_t)(1ULL << (block)->order))

#define find_buddy(block) ((struct free_block*)((uintptr_t)(block) ^ block_size(block)))

static size_t clog2(size_t n) {
	size_t log = 0;
	while (n >>= 1)
		log++;
	return log;
}

#define BLOCK_SIZES 10

static struct free_block* free_blocks[BLOCK_SIZES] = {0};

static size_t find_free_order(size_t from) {
	for(size_t i = from; i < BLOCK_SIZES; i++)
		if(free_blocks[i])
			return i;

	return BLOCK_SIZES;
}

static void remove_block(struct free_block* block) {
	if (block->prev)
		block->prev->next = block->next;
	else
		free_blocks[block->order] = block->next;

	if(block->next)
		block->next->prev = block->prev;
}

static void insert_block(struct free_block* block) {
	block->next = free_blocks[block->order];
	block->prev = NULL;
	if (block->next)
		block->next->prev = block;

	free_blocks[block->order] = block;
}

static bool contains_block(struct free_block* block, size_t order) {
	for(struct free_block* curr = free_blocks[order]; curr; curr = curr->next) {
		if(curr == block)
			return true;
	}

	return false;
}

static void recursive_join(struct free_block* block) {
	for(struct free_block* buddy = find_buddy(block); contains_block(buddy, block->order); buddy = find_buddy(block)) {
		remove_block(buddy);
		remove_block(block);

		block = block < buddy ? block : buddy;

		block->order++;
		insert_block(block);
	}
}

static void recursive_split(size_t from, size_t to) {
	struct free_block* block = free_blocks[from];
	remove_block(block);

	for(; from > to; from--) {
		block->order--;
		struct free_block* buddy = find_buddy(block);
		buddy->order = block->order;
		insert_block(buddy);
	}

	insert_block(block);
}

void kbuddy_init() {
	extern struct free_block BUDDY_START;
	extern struct free_block BUDDY_END;

	size_t bytes = (uintptr_t)&BUDDY_END - (uintptr_t)&BUDDY_START;
	size_t blocks = bytes / KMEM_PAGE_SIZE;
	size_t order = clog2(blocks);

	BUDDY_START.order = order;
	BUDDY_START.next = NULL;
	BUDDY_START.prev = NULL;

	free_blocks[order] = &BUDDY_START;
}

void* kbuddy_alloc(size_t pages) {
	size_t order = clog2(pages);

	size_t free_order = find_free_order(order);
	if (free_order == BLOCK_SIZES)
		return NULL;

	if (free_order > BLOCK_SIZES)
		recursive_split(free_order, order);

	struct free_block* block = free_blocks[order];
	remove_block(block);

	return block;
}

void kbuddy_dealloc(void* ptr, size_t pages) {
	if(!ptr)
		return;

	size_t order = clog2(pages * KMEM_PAGE_SIZE);

	struct free_block* block = ptr;
	block->order = order;

	insert_block(block);
	recursive_join(block);
}