#pragma once

inline static int* __errno_location(void) {
	static _Thread_local int errno;
	return &errno;
}

#define errno (*(__errno_location()))

typedef int errno_t;

#define EDOM 1
#define ERANGE 2
#define EILSEQ 3