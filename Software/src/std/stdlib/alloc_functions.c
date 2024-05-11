#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

void* calloc(size_t num, size_t size) {
	size_t bytes = num * size;

	void* ptr = malloc(bytes);
	if (!ptr)
		return NULL;

	memset(ptr, 0, bytes);

	return ptr;
}

void* realloc(void* ptr, size_t size) {
	if (!ptr)
		return malloc(size);

	if (!size) {
		free(ptr);
		return NULL;
	}

	bool __try_realloc(void* ptr, size_t size);
	if (__try_realloc(ptr, size))
		return ptr;

	void* new_ptr = malloc(size);
	if (!new_ptr)
		return NULL;

	memcpy(new_ptr, ptr, size);
	free(ptr);

	return new_ptr;
}