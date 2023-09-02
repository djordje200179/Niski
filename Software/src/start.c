#include "devices/sev_seg_displays.h"

static int a = 0;
static int b = 1;

void start() {
	sev_seg_displays_on();

	for (int i = 0; i < 10; i++) {
		int c = a + b;
		a = b;
		b = c;

		sev_seg_displays_set_number(c);
	}
}