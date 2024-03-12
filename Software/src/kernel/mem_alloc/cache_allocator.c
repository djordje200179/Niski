#include "kernel/mem_alloc/cache_allocator.h"

void* kcache_alloc(struct kcache* cache) {
	if (!cache->partially_allocated) {
		if (cache->fully_free) {
			cache->partially_allocated = cache->fully_free;
			cache->fully_free = cache->fully_free->next;
			cache->partially_allocated->next = NULL;
		} else {
			cache->partially_allocated = kslab_create(cache->type_size, cache->ctor, cache->dtor);
			if (!cache->partially_allocated)
				return NULL;
		}
	}

	void* slot = kslab_alloc(cache->partially_allocated);
	if (!slot)
		return NULL;

	if (!kslab_has_free_slots(cache->partially_allocated)) {
		struct kslab* temp = cache->partially_allocated;

		cache->partially_allocated = cache->partially_allocated->next;
		temp->next = cache->fully_allocated;

		cache->fully_allocated = temp;
	}

	return slot;
}

void kcache_dealloc(struct kcache* cache, void* ptr) {
	struct kslab* prev = NULL;
	for (struct kslab* curr = cache->partially_allocated; curr; prev = curr, curr = curr->next) {
		if (!kslab_dealloc(curr, ptr))
			continue;

		if (!kslab_has_allocated_slots(curr)) {
			if (prev)
				prev->next = curr->next;
			else
				cache->partially_allocated = curr->next;

			curr->next = cache->fully_free;
			cache->fully_free = curr;
		}

		return;
	}

	prev = NULL;
	for (struct kslab* curr = cache->fully_allocated; curr; prev = curr, curr = curr->next) {
		if (prev)
			prev->next = curr->next;
		else
			cache->fully_allocated = curr->next;

		if (!kslab_has_allocated_slots(curr)) {
			curr->next = cache->fully_free;
			cache->fully_free = curr;
		} else {
			curr->next = cache->partially_allocated;
			cache->partially_allocated = curr;
		}

		return;
	}
}

void kcache_shrink(struct kcache* cache) {
	for (struct kslab* curr = cache->fully_free; curr;) {
		struct kslab* next = curr->next;
		kslab_destroy(curr);

		curr = next;
	}
	cache->fully_free = NULL;
}