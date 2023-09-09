#pragma once

#include <stddef.h>

char* strcpy(char* restrict dest, const char* restrict src);
// errno_t strcpy_s(char* restrict dest, rsize_t destsz, const char* restrict src);

char* strncpy(char* restrict dest, const char* restrict src, size_t count);
// errno_t strncpy_s(char* restrict dest, rsize_t destsz, const char* restrict src, rsize_t count);

char* strcat(char* restrict dest, const char* restrict src);
// errno_t strcat_s(char* restrict dest, rsize_t destsz, const char* restrict src);

char* strncat(char* restrict dest, const char* restrict src, size_t count);
// errno_t strncat_s(char* restrict dest, rsize_t destsz, const char* restrict src, rsize_t count);

// size_t strxfrm(char* restrict dest, const char* restrict src, size_t count);

char* strdup(const char* src);
char* strndup(const char* src, size_t size);

size_t strlen(const char* str);
// size_t strnlen_s(const char* str, size_t strsz);

int strcmp(const char* lhs, const char* rhs);
int strncmp(const char* lhs, const char* rhs, size_t count);

// int strcoll(const char* lhs, const char* rhs);

char* strchr(const char* str, int ch);
char* strrchr(const char* str, int ch);

// size_t strspn(const char* dest, const char* src);
// size_t strcspn(const char* dest, const char* src);

// char* strpbrk(const char* dest, const char* breakset);

char* strstr(const char* str, const char* substr);

char* strtok(char* restrict str, const char* restrict delim);
// char* strtok_s(char* restrict str, rsize_t *restrict strmax, const char* restrict delim, char* *restrict ptr);

void* memchr(const void* ptr, int ch, size_t count);

int memcmp(const void* lhs, const void* rhs, size_t count);

void* memset(void* dest, int ch, size_t count);
void* memset_explicit(void* dest, int ch, size_t count);
// errno_t memset_s(void* dest, rsize_t destsz, int ch, rsize_t count);

void* memcpy(void* restrict dest, const void* restrict src, size_t count);
// errno_t memcpy_s(void* restrict dest, rsize_t destsz, const void* restrict src, rsize_t count);
void* memccpy(void* restrict dest, const void* restrict src, int c, size_t count);

void* memmove(void* dest, const void* src, size_t count);
// errno_t memmove_s(void* dest, rsize_t destsz, const void* src, rsize_t count);

// char* strerror(int errnum);
// errno_t strerror_s(char* buf, rsize_t bufsz, errno_t errnum);
// size_t strerrorlen_s(errno_t errnum);