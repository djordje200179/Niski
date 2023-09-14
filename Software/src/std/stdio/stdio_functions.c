#include <stdio.h>
#include "devices/lcd.h"

int putchar(int ch) {
	lcd_write_char(ch);
	return ch;
}

int puts(const char* str) {
	lcd_write_string(str);
	return 0;
}