#pragma once

#include "common/syscalls.h"
#include "common/threads.h"

typedef int (*thrd_start_t)(void*);

typedef struct __thrd* thrd_t;

enum {
    thrd_success = __THREAD_STATUS_SUCCESS,
    thrd_nomem = __THREAD_STATUS_NO_MEMORY,
    thrd_timedout = __THREAD_STATUS_TIMED_OUT,
    thrd_busy = __THREAD_STATUS_BUSY,
    thrd_error = __THREAD_STATUS_ERROR
};

static inline int thrd_create(thrd_t* thr, thrd_start_t func, void* arg) { return __thread_create(thr, func, arg); }
static inline int thrd_equal(thrd_t lhs, thrd_t rhs) { return lhs == rhs; }
static inline thrd_t thrd_current(void) {
	// TODO: Implement
	return NULL;
}
// int thrd_sleep(const struct timespec* duration, struct timespec* remaining);
static inline void thrd_yield(void) { __thread_dispatch(); }
[[noreturn]] static inline void thrd_exit(int res) { __thread_exit(res); }
static inline int thrd_detach(thrd_t thr) { return __thread_detach(thr); }
// int thrd_join(thrd_t thr, int* res);

typedef struct __mutex* mtx_t;

enum {
    mtx_plain = __MUTEX_MODE_NORMAL,
    mtx_timed = __MUTEX_MODE_TIMED,
    mtx_recursive = __MUTEX_MODE_RECURSIVE
};

//TODO: Deref mutex and cond

static inline int mtx_init(mtx_t* mutex, int type) { return __mutex_create(mutex, type); }
static inline int mtx_lock(mtx_t* mutex) { return __mutex_lock(*mutex); }
// int mtx_timedlock(mtx_t *restrict mutex, const struct timespec *restrict time_point);
static inline int mtx_trylock(mtx_t* mutex) { return __mutex_try_lock(*mutex); }
static inline int mtx_unlock(mtx_t* mutex) { return __mutex_unlock(*mutex); }
static inline void mtx_destroy(mtx_t* mutex) { __mutex_destroy(*mutex); }

typedef struct __condition* cnd_t;

static inline int cnd_init(cnd_t* cond) { return __condition_create(cond); }
static inline int cnd_signal(cnd_t* cond) { return __condition_signal(*cond); }
static inline int cnd_broadcast(cnd_t* cond) { return __condition_signal_all(*cond); }
static inline int cnd_wait(cnd_t* cond, mtx_t* mutex) { return __condition_wait(*cond, *mutex); }
//int cnd_timedwait(cnd_t* cond, mtx_t* mutex, const struct timespec* time_point);
static inline void cnd_destroy(cnd_t* cond) { __condition_destroy(*cond); }

typedef struct __thread_storage* tss_t;

#define TSS_DTOR_ITERATIONS 1

typedef void (*tss_dtor_t)(void*);

static inline int tss_create(tss_t* key, tss_dtor_t dtor) { return __thread_storage_create(key, dtor); }
static inline void* tss_get(tss_t key) { return __thread_storage_get(key); }
static inline int tss_set(tss_t key, void* val) { return __thread_storage_set(key, val); }
static inline void tss_delete(tss_t key) { __thread_storage_destroy(key); }