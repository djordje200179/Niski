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