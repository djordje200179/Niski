#include <stdlib.h>

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