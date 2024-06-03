#pragma once

#include "kernel/signals.h"

void (*signal(int sig, void (*func)(int)))(int);
int raise(int sig);

typedef int sig_atomic_t;

#define SIG_DFL ((void (*)(int))0)
#define SIG_IGN ((void (*)(int))1)
#define SIG_ERR ((void (*)(int))2)

#define SIGTERM SIGNAL_ABORT
#define SIGSEGV SIGNAL_MEM_ACCESS
#define SIGINT SIGNAL_INTERRUPT
#define SIGILL SIGNAL_ILLEGAL
#define SIGABRT SIGNAL_ABORT
#define SIGFPE SIGNAL_ILLEGAL