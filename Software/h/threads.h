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

struct kmutex;
typedef struct kmutex* mtx_t;

enum {
    mtx_plain,
    mtx_recursive,
    mtx_timed
};

int mtx_init(mtx_t* mutex, int type);
int mtx_lock(mtx_t* mutex);
// int mtx_timedlock(mtx_t *restrict mutex, const struct timespec *restrict time_point);
// int mtx_trylock(mtx_t* mutex);
int mtx_unlock(mtx_t* mutex);
void mtx_destroy(mtx_t* mutex);

struct kcond;
typedef struct kcond* cnd_t;

int cnd_init(cnd_t* cond);
int cnd_signal(cnd_t* cond);
int cnd_broadcast(cnd_t* cond);
int cnd_wait(cnd_t* cond, mtx_t* mutex);
//int cnd_timedwait(cnd_t* cond, mtx_t* mutex, const struct timespec* time_point);
void cnd_destroy(cnd_t* cond);