#pragma once

#include <stddef.h>
#include <stdbool.h>
#include <stdint.h>

typedef void (*kslab_ctor)(void* ptr);
typedef void (*kslab_dtor)(void* ptr);

struct kslab {
	kslab_ctor ctor;
	kslab_dtor dtor;

	size_t type_size;
	size_t num_slots;
	size_t free_slot;

	struct kslab* next;

	uint16_t free_slots[];
};

struct kslab* kslab_create(size_t type_size, kslab_ctor ctor, kslab_dtor dtor);
void kslab_destroy(struct kslab* slab);

void* kslab_alloc(struct kslab* slab);
bool kslab_dealloc(struct kslab* slab, void* ptr);

bool kslab_has_free_slots(struct kslab* slab);
bool kslab_has_allocated_slots(struct kslab* slab);