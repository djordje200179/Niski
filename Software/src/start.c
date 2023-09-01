#include "devices/sev_seg_displays.h"

int calculate() {
	int a = 0, b = 1;

	for (int i = 0; i < 10; i++) {
		int c = a + b;
		a = b;
		b = c;
	}

	return a;
}

void show(int value) {
	sev_seg_displays_on();
	
	sev_seg_displays_set_number(value);
}

void start() {
	int value = calculate();
	show(value);
}