#pragma once

#include "kernel/signals.h"

void (*signal(int sig, void (*func)(int)))(int);
int raise(int sig);

typedef volatile int sig_atomic_t;

#define SIG_DFL ((void (*)(int))0)
#define SIG_IGN ((void (*)(int))0)
#define SIG_ERR ((void (*)(int))1)

#define SIGTERM KSIGNAL_ABORT
#define SIGSEGV KSIGNAL_MEM_ACCESS
#define SIGINT KSIGNAL_INTERRUPT
#define SIGILL KSIGNAL_ILLEGAL
#define SIGABRT KSIGNAL_ABORT
#define SIGFPE KSIGNAL_ILLEGAL