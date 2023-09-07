#pragma once

#define CLOCKS_PER_SEC 50000000

struct tm {
	int tm_sec, tm_min, tm_hour;
	int tm_mday, tm_mon, tm_year;
	int tm_wday, tm_yday;
	int tm_isdst;
};

typedef long time_t;
typedef long long clock_t;

struct timespec {
	time_t tv_sec, tv_nsec;
};

static inline double difftime(time_t time_end, time_t time_beg) {
	return time_end - time_beg;
}

time_t time(time_t* arg);
clock_t clock(void);

#define TIME_UTC 1
#define TIME_MONOTONIC 2

int timespec_get(struct timespec* ts, int base);
int timespec_getres(struct timespec* ts, int base);

// errno_t asctime_s(char* buf, rsize_t bufsz, const struct tm* time_ptr);
// errno_t ctime_s(char* buf, rsize_t bufsz, const time_t* timer);
// size_t strftime(char* restrict str, size_t count, const char* restrict format, const struct tm* restrict tp);

// struct tm* gmtime(const time_t *timer);
// struct tm* gmtime_r(const time_t *timer, struct tm *buf);
// struct tm* gmtime_s(const time_t *restrict timer, struct tm *restrict buf);

// struct tm* localtime(const time_t* timer);
// struct tm* localtime_r(const time_t* timer, struct tm* buf);
// struct tm* localtime_s(const time_t* restrict timer, struct tm* restrict buf);

// time_t mktime( struct tm *arg );