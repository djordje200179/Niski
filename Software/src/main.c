#include <stdio.h>
#include <devices/lcd.h>

static char heartChar[] = {
	0b00000,
	0b01010,
	0b11111,
	0b11111,
	0b11111,
	0b01110,
	0b00100,
	0b00000
};

void main() {
	puts("Hello, world!\n");
	puts("Za Janu: <3 ");

	for(volatile i = 0; i < 500000; i++);

	lcd_clear();

	puts("Kosovo je\nSrbija!!!");
}