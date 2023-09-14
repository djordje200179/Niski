#include "devices/lcd.h"
#include <stdint.h>
#include <stddef.h>

extern volatile uint8_t LCD_DATA_REG;
extern volatile uint8_t LCD_CMD_REG;

void lcd_init() {
	lcd_send_command(0x38);
	lcd_send_command(0x0C);
	
	lcd_clear();
}

void lcd_clear() {
	lcd_send_command(0x01);
}

void lcd_send_command(char cmd) {
	LCD_CMD_REG = cmd;
}

void lcd_write_char(char ch) {
	switch (ch) {
	case '\n':
		lcd_send_command(0xC0);
		return;
	case '\r':
		lcd_send_command(0x80);
		return;
	default:
		LCD_DATA_REG = ch;
		break;
	}
}

void lcd_write_string(char* str) {
	for (size_t i = 0; str[i]; i++)
		lcd_write_char(str[i]);
}