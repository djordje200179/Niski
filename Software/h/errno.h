#pragma once

#ifndef errno

_Thread_local int errno_value = 0;
#define errno errno_value

#endif

typedef int errno_t;

#define EDOM 1
#define ERANGE 2
#define EILSEQ 3