#pragma once

#include <stddef.h>

void kheap_init();

void* kheap_alloc(size_t bytes);
void kheap_dealloc(void* ptr);