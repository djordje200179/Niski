#include <stdlib.h>

static unsigned int seed = 0;

int rand(void) {
	seed = seed * 1103515245 + 12345;
	return (unsigned int)(seed / 65536) % 32768;
}

void srand(unsigned int new_seed) {
	seed = new_seed;
}