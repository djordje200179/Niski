#pragma once

#include <stddef.h>
#include <errno.h>

void* malloc(size_t size);
void* calloc(size_t num, size_t size);
void* realloc(void* ptr, size_t size);

void free(void* ptr);

int rand(void);
void srand(unsigned int seed);
#define RAND_MAX 32767

void* bsearch(const void* key, const void* base, size_t num, size_t size, int (*comp)(const void*, const void*));
// errno_t bsearch_s(const void* key, const void* base, size_t num, size_t size, int (*compare)(void*, const void*, const void*), void* context);