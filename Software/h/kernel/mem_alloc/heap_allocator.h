#pragma once

#include <stddef.h>
#include <stdbool.h>

void kheap_init();

void* kheap_alloc(size_t bytes);
void kheap_dealloc(void* ptr);
bool kheap_try_realloc(void* ptr, size_t bytes);