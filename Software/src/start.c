#include "devices/sev_seg_displays.h"

static int a = 0;
static int b = 1;

void start() {
	sev_seg_displays_on();

	for (int i = 0; i < 20; i++) {
		int c = a + b;
		a = b;
		b = c;

		volatile int j;
		for (j = 0; j < 200000; j++);

		sev_seg_displays_set_number(a);
	}
}