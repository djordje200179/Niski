#pragma once

enum __thread_status {
	__THREAD_STATUS_SUCCESS,
	__THREAD_STATUS_NO_MEMORY,
	__THREAD_STATUS_TIMED_OUT,
	__THREAD_STATUS_BUSY,
	__THREAD_STATUS_ERROR
};	

struct __thrd;
struct __mutex;
struct __condition;
struct __thread_storage;

enum __mutex_mode {
	__MUTEX_MODE_NORMAL,
	__MUTEX_MODE_TIMED,
	__MUTEX_MODE_RECURSIVE
};