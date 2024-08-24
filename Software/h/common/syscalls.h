#pragma once

#include <stddef.h>
#include <stdbool.h>
#include "common/threads.h"
#include "common/signals.h"

void* __mem_alloc(size_t size);
void __mem_free(void* ptr);
bool __mem_try_realloc(void* ptr, size_t size);

enum __thread_status __thread_create(struct __thrd** thread, int (*func)(void*), void* arg);
[[ noreturn ]] void __thread_exit(int res);
enum __thread_status __thread_detach(struct __thrd* thread);
void __thread_dispatch();

enum __thread_status __mutex_create(struct __mutex** mutex, enum __mutex_mode mode);
enum __thread_status __mutex_lock(struct __mutex* mutex);
enum __thread_status __mutex_unlock(struct __mutex* mutex);
enum __thread_status __mutex_destroy(struct __mutex* mutex);
enum __thread_status __mutex_try_lock(struct __mutex* mutex);

enum __thread_status __cond_create(struct __condition** cond);
enum __thread_status __cond_wait(struct __condition* cond, struct __mutex* mutex);
enum __thread_status __cond_signal(struct __condition* cond);
enum __thread_status __cond_signal_all(struct __condition* cond);
enum __thread_status __cond_destroy(struct __condition* cond);

enum __thread_status __ts_create(struct __thread_storage** ts, void (*dtor)(void*));
enum __thread_status __ts_destroy(struct __thread_storage* ts);
void* __ts_get(struct __thread_storage* ts);
enum __thread_status __ts_set(struct __thread_storage* ts, void* data);

void (*__sig_set(enum __signal sig, void (*handler)(enum __signal)))(enum __signal);
void __sig_raise(enum __signal sig);