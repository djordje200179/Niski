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