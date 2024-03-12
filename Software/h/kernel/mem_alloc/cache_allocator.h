#pragma once

#include "slab_allocator.h"

struct kcache {
	size_t type_size;

	kslab_ctor ctor;
	kslab_dtor dtor;

	struct kslab* fully_allocated;
	struct kslab* partially_allocated;
	struct kslab* fully_free;
};

void* kcache_alloc(struct kcache* cache);
void kcache_dealloc(struct kcache* cache, void* ptr);

void kcache_shrink(struct kcache* cache);