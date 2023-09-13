#include <devices/lcd.h>

void main() {
	lcd_init();

	lcd_write('H');
	lcd_write('e');
	lcd_write('l');
}