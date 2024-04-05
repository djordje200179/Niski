#pragma once

#include <stdint.h>

typedef uint32_t jmp_buf [4];

int setjmp(jmp_buf env);
void longjmp(jmp_buf env, int val);