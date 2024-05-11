#include <stdlib.h>
#include <string.h>

void* calloc(size_t num, size_t size) {
	size_t bytes = num * size;

	void* ptr = malloc(bytes);
	if (!ptr)
		return NULL;

	memset(ptr, 0, bytes);

	return ptr;
}

static unsigned int seed = 0;

int rand(void) {
	seed = seed * 1103515245 + 12345;
	return (unsigned int)(seed / 65536) % 32768;
}

void srand(unsigned int new_seed) {
	seed = new_seed;
}

void* bsearch(const void* key, const void* base, size_t num, size_t size, int (*comp)(const void*, const void*)) {
	size_t left = 0;
	size_t right = num - 1;

	while (left <= right) {
		size_t middle = left + (right - left) / 2;
		int comparison = comp(key, (char*)base + middle * size);

		if (comparison == 0)
			return (char*)base + middle * size;
		else if (comparison < 0)
			right = middle - 1;
		else
			left = middle + 1;
	}

	return NULL;
}

errno_t bsearch_s(const void* key, const void* base, size_t num, size_t size, int (*compare)(void*, const void*, const void*), void* context) {
	size_t left = 0;
	size_t right = num - 1;

	while (left <= right) {
		size_t middle = left + (right - left) / 2;
		int comparison = compare(context, key, (char*)base + middle * size);

		if (comparison == 0)
			return 0;
		else if (comparison < 0)
			right = middle - 1;
		else
			left = middle + 1;
	}

	return 1;
}