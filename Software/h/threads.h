#pragma once

typedef int (*thrd_start_t)(void*);

struct kthread;
typedef struct kthread* thrd_t;

enum {
    thrd_success,
    thrd_nomem,
    thrd_timedout,
    thrd_busy,
    thrd_error
};

int thrd_create(thrd_t* thr, thrd_start_t func, void* arg);
int thrd_equal(thrd_t lhs, thrd_t rhs);
thrd_t thrd_current(void);
// int thrd_sleep(const struct timespec* duration, struct timespec* remaining);
void thrd_yield(void);
[[noreturn]] void thrd_exit(int res);
// int thrd_detach(thrd_t thr);
// int thrd_join(thrd_t thr, int* res);
