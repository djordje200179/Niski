#pragma once

#include "common/signals.h"
#include "common/syscalls.h"

static inline void (*signal(int sig, void (*func)(int)))(int) { 
	return (void (*)(int))__signal_set_handler(sig, (void (*)(enum __signal))func);
}
static inline int raise(int sig) { __signal_raise(sig); return 0; }

typedef volatile int sig_atomic_t;

#define SIG_DFL ((void (*)(int))0)
#define SIG_IGN ((void (*)(int))0)
#define SIG_ERR ((void (*)(int))1)

#define SIGTERM __SIGNAL_ABORT
#define SIGSEGV __SIGNAL_MEM_ACCESS
#define SIGINT __SIGNAL_INTERRUPT
#define SIGILL __SIGNAL_ILLEGAL
#define SIGABRT __SIGNAL_ABORT
#define SIGFPE __SIGNAL_ILLEGAL