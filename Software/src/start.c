#include "devices/leds.h"

static int calculate() {
	int a = 0, b = 1;

	for (int i = 0; i < 10; i++) {
		int c = a + b;
		a = b;
		b = c;
	}

	return a;
}

static void show(int value) {
	//sev_seg_displays_on();
	leds_on();
	leds_set(0b0101);
	
	//sev_seg_displays_set_number(value);
	//sev_seg_displays_set_dots(0b1010);
}

void start() {
	// int value = calculate();
	// show(value);
	leds_on();
	leds_set(0b0101);
}