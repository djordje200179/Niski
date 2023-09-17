#include <string.h>
#include <stdint.h>
#include "devices/dma.h"

void* memchr(const void* ptr, int ch, size_t count) {
	unsigned char* cptr = (unsigned char*)ptr;

	for (size_t i = 0; i < count; i++) {
		if (cptr[i] == ch)
			return &cptr[i];
	}

	return NULL;
}

int memcmp(const void* lhs, const void* rhs, size_t count) {
	unsigned char* clhs = (unsigned char*)lhs;
	unsigned char* crhs = (unsigned char*)rhs;

	for (size_t i = 0; i < count; i++) {
		if (clhs[i] < crhs[i])
			return -1;
		else if (clhs[i] > crhs[i])
			return 1;
	}

	return 0;
}

void* memset(void* dest, int ch, size_t count) {
	dma_fill((char*)dest, count, ch);

	return dest;
}

void* memset_explicit(void* dest, int ch, size_t count) {
	return memset(dest, ch, count);
}

void* memcpy(void* restrict dest, const void* restrict src, size_t count) {
	dma_copy((char*)src, (char*)dest, count);

	return dest;
}

void* memccpy(void* restrict dest, const void* restrict src, int c, size_t count) {
	unsigned char* cdest = (unsigned char*)dest;
	unsigned char* csrc = (unsigned char*)src;

	for (size_t i = 0; i < count; i++) {
		cdest[i] = csrc[i];

		if (csrc[i] == c)
			return &cdest[i];
	}

	return NULL;
}

void* memmove(void* dest, const void* src, size_t count) {
	unsigned char* cdest = (unsigned char*)dest;
	unsigned char* csrc = (unsigned char*)src;

	if (cdest < csrc)
		return memcpy(dest, src, count);

	for (size_t i = count; i > 0; i--)
		cdest[i - 1] = csrc[i - 1];

	return dest;
}