#include "devices/lcd.h"
#include <stdint.h>

extern volatile struct {
	uint32_t data;
	uint32_t cmd;
} LCD;

void lcd_send_cmd(enum lcd_command cmd, uint8_t data) {
	LCD.cmd = cmd | data;
}

void lcd_write_ch(char ch) {
	LCD.data = ch;
}

void lcd_register_char(char code, const char* data) {
	code &= 0x07;

	lcd_send_cmd(LCD_CMD_REGISTER_CHAR, code << 3);
	for (uint8_t i = 0; i < 8; i++)
		lcd_write_ch(data[i]);
}