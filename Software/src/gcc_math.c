unsigned long __udivmoddi4 (unsigned long a, unsigned long b, unsigned long *c) {
	unsigned long count = 0;
	while (a >= b) {
		a -= b;
		count++;
	}

	*c = a;
	return count;
}

unsigned long long __udivmodti4 (unsigned long long a, unsigned long long b, unsigned long long *c) {
	unsigned long long count = 0;
	while (a >= b) {
		a -= b;
		count++;
	}

	*c = a;
	return count;
}

unsigned long __udivdi3 (unsigned long a, unsigned long b) {
	unsigned long remainder;
	return __udivmoddi4(a, b, &remainder);
}

unsigned int __udivsi3 (unsigned int a, unsigned int b) {
	return __udivdi3(a, b);
}

unsigned long long __udivti3 (unsigned long long a, unsigned long long b) {
	unsigned long long remainder;
	return __udivmodti4(a, b, &remainder);
}

unsigned long __umoddi3 (unsigned long a, unsigned long b) {
	unsigned long result;
	__udivmoddi4(a, b, &result);
	return result;
}

unsigned int __umodsi3 (unsigned int a, unsigned int b) {
	return __umoddi3(a, b);
}

unsigned long long __umodti3 (unsigned long long a, unsigned long long b) {
	unsigned long long result;
	__udivmodti4(a, b, &result);
	return result;
}

long __divdi3 (long a, long b) {
	if ((a < 0 && b < 0) || (a > 0 && b > 0))
		return __udivdi3(a, b);
	else
		return -__udivdi3(-a, b);
}

int __divsi3 (int a, int b) {
	return __divdi3(a, b);
}

long long __divti3 (long long a, long long b) {
	if ((a < 0 && b < 0) || (a > 0 && b > 0))
		return __udivti3(a, b);
	else
		return -__udivti3(-a, b);
}

long __moddi3 (long a, long b) {
	if ((a < 0 && b < 0) || (a > 0 && b > 0))
		return __umoddi3(a, b);
	else
		return -__umoddi3(-a, b);
}

int __modsi3 (int a, int b) {
	return __moddi3(a, b);
}

long long __modti3 (long long a, long long b) {
	if ((a < 0 && b < 0) || (a > 0 && b > 0))
		return __umodti3(a, b);
	else
		return -__umodti3(-a, b);
}