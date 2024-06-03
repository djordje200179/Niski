#include <stdio.h>
#include "devices/lcd.h"

int putchar(int ch) {
	switch (ch) {
	case '\n':
		lcd_move_cursor(1, 0);
		break;
	case '\r':
		lcd_move_cursor(0, 0);
		break;
	default:
		lcd_write_ch(ch);
		break;
	}

	return ch;
}

int puts(const char* str) {
	for (; *str; str++)
		putchar(*str);	

	return 0;
}