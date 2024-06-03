#pragma once

static inline int isalnum(int c) { return (c >= '0' && c <= '9') || (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z'); }
static inline int isalpha(int c) { return (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z'); }
static inline int islower(int c) { return c >= 'a' && c <= 'z'; }
static inline int isupper(int c) { return c >= 'A' && c <= 'Z'; }
static inline int isdigit(int c) { return c >= '0' && c <= '9'; }
static inline int isxdigit(int c) {	return (c >= '0' && c <= '9') || (c >= 'A' && c <= 'F') || (c >= 'a' && c <= 'f'); }
static inline int iscntrl(int c) { return (c >= 0 && c <= 31) || c == 127; }
static inline int isgraph(int c) { return c >= 33 && c <= 126; }
static inline int isspace(int c) { return c >= 9 && c <= 13; }
static inline int isblank(int c) { return c == ' ' || c == '\t'; }
static inline int isprint(int c) { return c >= 32 && c <= 126; }
static inline int ispunct(int c) {
	return (c >= 33 && c <= 47) || (c >= 58 && c <= 64) || (c >= 91 && c <= 96) || (c >= 123 && c <= 126);
}

static inline int tolower(int c) { return isupper(c) ? c + 32 : c; }
static inline int toupper(int c) { return islower(c) ? c - 32 : c; }