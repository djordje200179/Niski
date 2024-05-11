#pragma once

#include <stddef.h>

void* malloc(size_t size);
void* calloc(size_t num, size_t size);

void free(void* ptr);

int rand(void);
void srand(unsigned int seed);
#define RAND_MAX 32767