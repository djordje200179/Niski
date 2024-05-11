#pragma once

#include <stdint.h>

static inline struct imaxdiv_t { intmax_t quot, rem; } imaxdiv(intmax_t numer, intmax_t denom) {
	return (struct imaxdiv_t){ numer / denom, numer % denom };
}

static inline intmax_t imaxabs(intmax_t n) { return n < 0 ? -n : n; }