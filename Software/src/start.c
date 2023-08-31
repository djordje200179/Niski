#include "devices/sev_seg.h"

void calculate() {
	int a = 0, b = 1;

	for (int i = 0; i < 10; i++) {
		int c = a + b;
		a = b;
		b = c;
	}

	asm ("mv s1, %0" : : "r" (a));
}

void show() {
	sev_seg_on();
	
	char value;
	asm ("mv %0, s1" : "=r" (value));

	sev_seg_set_number(value);
}

void start() {
	void (*fun)() = &calculate;
	fun();

	fun = &show;
	fun();
}