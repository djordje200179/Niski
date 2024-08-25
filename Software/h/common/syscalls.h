#pragma once

#include <stddef.h>
#include <stdbool.h>
#include "common/threads.h"
#include "common/signals.h"
#include "common/io.h"

void* __memory_allocate(size_t size);
void __memory_free(void* ptr);
bool __memory_try_expand(void* ptr, size_t size);

enum __thread_status __thread_create(struct __thrd** thread, int (*func)(void*), void* arg);
[[ noreturn ]] void __thread_exit(int res);
enum __thread_status __thread_detach(struct __thrd* thread);
void __thread_dispatch();
struct __thrd* __thread_get_current();

enum __thread_status __mutex_create(struct __mutex** mutex, enum __mutex_mode mode);
enum __thread_status __mutex_lock(struct __mutex* mutex);
enum __thread_status __mutex_unlock(struct __mutex* mutex);
enum __thread_status __mutex_destroy(struct __mutex* mutex);
enum __thread_status __mutex_try_lock(struct __mutex* mutex);

enum __thread_status __condition_create(struct __condition** cond);
enum __thread_status __condition_wait(struct __condition* cond, struct __mutex* mutex);
enum __thread_status __condition_signal(struct __condition* cond);
enum __thread_status __condition_signal_all(struct __condition* cond);
enum __thread_status __condition_destroy(struct __condition* cond);

enum __thread_status __thread_storage_create(struct __thread_storage** ts, void (*dtor)(void*));
enum __thread_status __thread_storage_destroy(struct __thread_storage* ts);
void* __thread_storage_get(struct __thread_storage* ts);
enum __thread_status __thread_storage_set(struct __thread_storage* ts, void* data);

void (*__signal_set_handler(enum __signal sig, void (*handler)(enum __signal)))(enum __signal);
void __signal_raise(enum __signal sig);

size_t __file_write(enum __file file, const char* buffer, size_t size);
size_t __file_read(enum __file file, char* buffer, size_t size);