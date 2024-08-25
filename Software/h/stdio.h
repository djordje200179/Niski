#pragma once

#include "common/io.h"
#include "common/syscalls.h"

#define EOF (-1)

typedef struct FILE FILE;

#define stdin  ((FILE*)__FILE_KEYBOARD)
#define stdout ((FILE*)__FILE_LCD)
#define stderr ((FILE*)__FILE_LCD)

static inline int fputs(const char* str, FILE* restrict stream) {
	size_t len = 0;
	while (str[len] != '\0') len++;
	
	size_t chars = __file_write((enum __file)stream, str, len);
	if (chars != len) {
		// TODO: set ferror
		return EOF;
	}

	return chars;
}

static inline int fputc(int ch, FILE* stream) {
	char c = ch;
	size_t res = __file_write((enum __file)stream, &c, 1);
	if (res != 1)
		return EOF;
	
	return ch;
}

#define putc(ch, stream) fputc(ch, stream)

static inline int puts(const char* str) {
	int res = fputs(str, stdout);
	if (res == EOF)
		return EOF;

	if (fputc('\n', stdout) == EOF)
		return EOF;

	return res + 1;
}

static inline int putchar(int ch) { return fputc(ch, stdout); }
