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
	
	sev_seg_displays_set_digit(0, 0);
	sev_seg_displays_set_digit(1, 1);
	sev_seg_displays_set_digit(2, 2);
	sev_seg_displays_set_digit(3, 3);
}

void start() {
	int value = calculate();
	show(value);
}