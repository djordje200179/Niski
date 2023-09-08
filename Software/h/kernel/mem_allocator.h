#pragma once

#include <stddef.h>

void kmem_init();

void* kmem_alloc(size_t bytes);
void kmem_dealloc(void* ptr);