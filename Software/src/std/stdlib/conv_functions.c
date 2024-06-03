#include <stdlib.h>
#include <ctype.h>
#include <limits.h>

long strtol(const char* restrict str, char** restrict str_end, int base) {
	long long result = strtoll(str, str_end, base);
	if (result > LONG_MAX) {
		errno = ERANGE;
		result = LONG_MAX;
	} else if (result < LONG_MIN) {
		errno = ERANGE;
		result = LONG_MIN;
	}

	return result;
}

long long strtoll(const char* restrict str, char** restrict str_end, int base) {
	while (isspace(*str))
		str++;

	int sign = 1;
	if (*str == '-') {
		sign = -1;
		str++;
	} else if (*str == '+')
		str++;

	if (base == 0) {
		if (*str == '0') {
			if (str[1] == 'x' || str[1] == 'X') {
				base = 16;
				str += 2;
			} else
				base = 8;
		} else
			base = 10;
	}

	long long result = 0;
	while (*str) {
		int digit;
		if (*str >= '0' && *str <= '9')
			digit = *str - '0';
		else if (*str >= 'a' && *str <= 'z')
			digit = *str - 'a' + 10;
		else if (*str >= 'A' && *str <= 'Z')
			digit = *str - 'A' + 10;
		else
			break;

		if (digit >= base)
			break;

		if (result > (LLONG_MAX - digit) / base) {
			errno = ERANGE;
			result = LLONG_MAX;
			break;
		} else if (result < (LLONG_MIN + digit) / base) {
			errno = ERANGE;
			result = LLONG_MIN;
			break;
		}

		result = result * base + digit;
		str++;
	}

	if (str_end)
		*str_end = (char*)str;

	return result * sign;
}

unsigned long strtoul(const char* restrict str, char** restrict str_end, int base) {
	long long result = strtoull(str, str_end, base);
	if (result > ULONG_MAX) {
		errno = ERANGE;
		result = ULONG_MAX;
	}

	return result;
}

unsigned long long strtoull(const char* restrict str, char** restrict str_end, int base) {
	while (isspace(*str))
		str++;

	int sign = 1;
	if (*str == '-') {
		sign = -1;
		str++;
	} else if (*str == '+')
		str++;

	if (base == 0) {
		if (*str == '0') {
			if (str[1] == 'x' || str[1] == 'X') {
				base = 16;
				str += 2;
			} else
				base = 8;
		} else
			base = 10;
	}

	unsigned long long result = 0;
	while (*str) {
		int digit;
		if (*str >= '0' && *str <= '9')
			digit = *str - '0';
		else if (*str >= 'a' && *str <= 'z')
			digit = *str - 'a' + 10;
		else if (*str >= 'A' && *str <= 'Z')
			digit = *str - 'A' + 10;
		else
			break;

		if (digit >= base)
			break;

		if (result > (ULLONG_MAX - digit) / base) {
			errno = ERANGE;
			result = LLONG_MAX;
			break;
		}

		result = result * base + digit;
		str++;
	}

	if (str_end)
		*str_end = (char*)str;

	return result * sign;
}