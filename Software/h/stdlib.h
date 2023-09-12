#pragma once

#include <stddef.h>

void* malloc(size_t size);
void* calloc(size_t num, size_t size);

void free(void* ptr);