#pragma once

#include <stddef.h>
#include <stdbool.h>

void kheap_init();

void* kheap_alloc(size_t bytes);
void kheap_dealloc(void* ptr);
bool kheap_try_expand(void* ptr, size_t bytes);