#include "devices/lcd.h"
#include <stdint.h>

extern volatile struct {
	uint32_t data;
	uint32_t cmd;
} LCD;

void lcd_init() {
	lcd_send_command(LCD_CMD_INIT, 0);
	lcd_send_command(LCD_CMD_DISPLAY_ON_CURSOR_OFF, 0);

	lcd_clear();
}

void lcd_clear() {
	lcd_send_command(LCD_CMD_CLEAR_SCREEN, 0);
	lcd_send_command(LCD_CMD_RETURN_HOME, 0);
}

void lcd_move_to(unsigned short x, unsigned short y) {
	x &= 0x0F;
	y &= 0x01;

	lcd_send_command(LCD_CMD_SET_CURSOR_POSITION, (y << 6) | x);
}

void lcd_send_command(enum lcd_command cmd, uint8_t data) {
	LCD.cmd = cmd | data;
}

void lcd_write_char(char ch) {
	LCD.data = ch;
}

void lcd_register_char(char code, const char* data) {
	code &= 0x07;

	lcd_send_command(LCD_CMD_REGISTER_CHAR, code << 3);
	for (uint8_t i = 0; i < 8; i++)
		lcd_write_char(data[i]);
}