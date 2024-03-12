#pragma once

#include <stddef.h>

#define KMEM_PAGE_SIZE 1024

void kbuddy_init();

void* kbuddy_alloc(size_t pages);
void kbuddy_dealloc(void* ptr, size_t pages);