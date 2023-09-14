#include <devices/lcd.h>
#include <devices/ssds.h>

void main() {
	lcd_init();
	ssds_on();

	lcd_write_string("Tartalja je Bog\ni batina");
	lcd_write_char('.');

	for (int i = 0; i < 10000; i++) {
		ssds_set_number(i);
		for (volatile int j = 0; j < 150000; j++);
	}
}