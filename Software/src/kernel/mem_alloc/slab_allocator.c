#include "kernel/mem_alloc/slab_allocator.h"
#include "kernel/mem_alloc/buddy_allocator.h"
#include <stdint.h>

#define get_slots(slab) ((void*)((uintptr_t)slab + sizeof(struct kslab) + slab->num_slots * sizeof(uint16_t)))

struct kslab* kslab_create(size_t type_size, kslab_ctor ctor, kslab_dtor dtor) {
	struct kslab* slab = kbuddy_alloc(1);

	slab->ctor = ctor;
	slab->dtor = dtor;

	slab->type_size = type_size;
	slab->num_slots = (KMEM_PAGE_SIZE - sizeof(struct kslab)) / (type_size + sizeof(uint16_t));
	slab->free_slot = 0;

	slab->next = NULL;

	for (size_t i = 0; i < slab->num_slots; i++)
		slab->free_slots[i] = i + 1;
	slab->free_slots[slab->num_slots - 1] = (uint16_t)-1;

	if (ctor) {
		void* slots = get_slots(slab);
		for (size_t i = 0; i < slab->num_slots; i++) {
			void* slot = slots + i * slab->type_size;
			ctor(slot);
		}
	}

	return slab;
}

void kslab_destroy(struct kslab* slab) {
	if (slab->dtor) {
		void* slots = get_slots(slab);
		for (size_t i = 0; i < slab->num_slots; i++) {
			void* slot = slots + i * slab->type_size;
			slab->dtor(slot);
		}
	}

	kbuddy_dealloc(slab, 1);
}

void* kslab_alloc(struct kslab* slab) {
	if (slab->free_slot == (uint16_t)-1)
		return NULL;

	void* slot = get_slots(slab) + slab->free_slot * slab->type_size;
	slab->free_slot = slab->free_slots[slab->free_slot];

	return slot;
}

bool kslab_dealloc(struct kslab* slab, void* ptr) {
	void* slots = get_slots(slab);
	void* last_slot = slots + (slab->num_slots - 1) * slab->type_size;

	if (ptr < slots || ptr > last_slot)
		return false;

	size_t index = ((uintptr_t)ptr - (uintptr_t)slots) / slab->type_size;

	slab->free_slots[index] = slab->free_slot;
	slab->free_slot = index;

	return true;
}

struct kslab* kslab_get_next(struct kslab* slab) { return slab->next; }
void kslab_set_next(struct kslab* slab, struct kslab* next) { slab->next = next; }

bool kslab_has_free_slots(struct kslab* slab) { return slab->free_slot != (uint16_t)-1; }

bool kslab_has_allocated_slots(struct kslab* slab) {
	size_t free_slots = 0;

	for (uint16_t i = slab->free_slot; i != (uint16_t)-1; i = slab->free_slots[i])
		free_slots++;

	return free_slots != slab->num_slots;
}