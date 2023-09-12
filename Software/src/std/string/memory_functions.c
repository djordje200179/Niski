#include <string.h>
#include <stdint.h>

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
	unsigned char* cdest = (unsigned char*)dest;

	while ((uintptr_t)cdest % 4 != 0 && count > 0) {
		*cdest = ch;
		cdest++;
		count--;
	}

	uint32_t* dest32 = (uint32_t*)cdest;

	uint32_t ch32 = 0;
	for (uint8_t i = 0; i < 4; i++)
		ch32 |= (uint32_t)ch << (i * 8);
	
	while (count >= 4) {
		*dest32 = ch32;
		dest32++;
		count -= 4;
	}

	cdest = (unsigned char*)dest32;

	while (count > 0) {
		*cdest = ch;
		cdest++;
		count--;
	}

	return dest;
}

void* memset_explicit(void* dest, int ch, size_t count) {
	return memset(dest, ch, count);
}

void* memcpy(void* restrict dest, const void* restrict src, size_t count) {
	unsigned char* cdest = (unsigned char*)dest;
	unsigned char* csrc = (unsigned char*)src;

	for (size_t i = 0; i < count; i++)
		cdest[i] = csrc[i];

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

	if (cdest < csrc) {
		for (size_t i = 0; i < count; i++)
			cdest[i] = csrc[i];
	} else {
		for (size_t i = count; i > 0; i--)
			cdest[i - 1] = csrc[i - 1];
	}

	return dest;
}