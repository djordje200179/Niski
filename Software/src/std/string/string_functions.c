#include <string.h>
#include <stdint.h>
#include <stdlib.h>

char* strcpy(char* restrict dest, const char* restrict src) {
	size_t i;
	for (i = 0; src[i]; i++)
		dest[i] = src[i];
	dest[i] = '\0';
	
	return dest;
}


char* strncpy(char* restrict dest, const char* restrict src, size_t count) {
	size_t i;
	for (i = 0; i < count && src[i]; i++)
		dest[i] = src[i];
	for (; i < count; i++)
		dest[i] = '\0';
	
	return dest;
}

char* strcat(char* restrict dest, const char* restrict src) {
	return strncat(dest, src, SIZE_MAX);
}

char* strncat(char* restrict dest, const char* restrict src, size_t count) {
	size_t i = strlen(dest);

	size_t j;
	for (j = 0; j < count && src[j]; j++)
		dest[i + j] = src[j];
	dest[i + j] = '\0';

	return dest;
}

char* strdup(const char* src) {
	size_t len = strlen(src);
	char* dest = malloc(len + 1);
	if (!dest)
		return NULL;
	
	return strcpy(dest, src);
}

char* strndup(const char* src, size_t count) {
	size_t len = strlen(src);
	if (len > count)
		len = count;

	char* dest = malloc(len + 1);
	if (!dest)
		return NULL;
	
	return strncpy(dest, src, len);
}

size_t strlen(const char* str) {
	size_t len = 0;
	while (str[len])
		len++;

	return len;
}

int strcmp(const char* lhs, const char* rhs) {
	size_t i;
	for (i = 0; lhs[i] && rhs[i]; i++) {
		if (lhs[i] < rhs[i])
			return -1;
		else if (lhs[i] > rhs[i])
			return 1;
	}

	if (lhs[i] < rhs[i])
		return -1;
	else if (lhs[i] > rhs[i])
		return 1;
	else
		return 0;
}

int strncmp(const char* lhs, const char* rhs, size_t count) {
	size_t i;
	for (i = 0; i < count && lhs[i] && rhs[i]; i++) {
		if (lhs[i] < rhs[i])
			return -1;
		else if (lhs[i] > rhs[i])
			return 1;
	}

	if (i == count)
		return 0;

	if (lhs[i] < rhs[i])
		return -1;
	else if (lhs[i] > rhs[i])
		return 1;
	else
		return 0;
}

char* strchr(const char* str, int ch) {
	for (size_t i = 0; str[i]; i++) {
		if (str[i] == ch)
			return &str[i];
	}

	return NULL;
}

char* strrchr(const char* str, int ch) {
	char* last = NULL;
	for (size_t i = 0; str[i]; i++) {
		if (str[i] == ch)
			last = &str[i];
	}

	return last;
}

char* strstr(const char* str, const char* substr) {
	size_t len = strlen(substr);
	for (size_t i = 0; str[i]; i++) {
		if (strncmp(&str[i], substr, len) == 0)
			return &str[i];
	}

	return NULL;
}

char* strtok(char* restrict str, const char* restrict delim) {
	static char* last = NULL;

	if (!str)
		str = last;

	if (!str)
		return NULL;

	size_t i;
	for (i = 0; str[i]; i++) {
		if (strchr(delim, str[i]))
			break;
	}

	if (str[i]) {
		str[i] = '\0';
		last = &str[i + 1];
	} else
		last = NULL;

	return str;
}