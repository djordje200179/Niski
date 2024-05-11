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

static inline struct div_t { int quot, rem; } div(int numer, int denom) {
	return (struct div_t){ numer / denom, numer % denom };
}

static inline struct ldiv_t { long quot, rem; } ldiv(long numer, long denom) {
	return (struct ldiv_t){ numer / denom, numer % denom };
}

static inline struct lldiv_t { long long quot, rem; } lldiv(long long numer, long long denom) {
	return (struct lldiv_t){ numer / denom, numer % denom };
}

static inline int abs(int n) { return n < 0 ? -n : n; }
static inline long labs(long n) {	return n < 0 ? -n : n; }
static inline long long llabs(long long n) { return n < 0 ? -n : n; }

long strtol(const char* restrict str, char** restrict str_end, int base);
long long strtoll(const char* restrict str, char** restrict str_end, int base);
unsigned long strtoul(const char* restrict str, char** restrict str_end, int base);
unsigned long long strtoull(const char* restrict str, char** restrict str_end, int base);

static inline int atoi(const char* str) { return strtol(str, NULL, 10); }
static inline long atol(const char* str) { return strtol(str, NULL, 10); }
static inline long long atoll(const char* str) { return strtoll(str, NULL, 10); }