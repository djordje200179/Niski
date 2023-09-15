#include "devices/lcd.h"
#include <stdint.h>

extern volatile uint8_t LCD_DATA_REG;
extern volatile uint8_t LCD_CMD_REG;

void lcd_init() {
	lcd_send_command(LCD_CMD_INIT);
	lcd_send_command(LCD_CMD_DISPLAY_ON_CURSOR_OFF);

	lcd_clear();
}

void lcd_clear() {
	lcd_send_command(LCD_CMD_CLEAR_SCREEN);
	lcd_send_command(LCD_CMD_RETURN_HOME);
}

void lcd_move_to(unsigned short x, unsigned short y) {
	x &= 0x0F;
	y &= 0x01;

	uint8_t addr = 0x80 | (y << 6) | x;
	lcd_send_command(addr);
}

void lcd_send_command(enum lcd_command cmd) {
	LCD_CMD_REG = cmd;
}

void lcd_write_char(char ch) {
	LCD_DATA_REG = ch;
}

void lcd_register_char(char code, const char* data) {
	code &= 0x07;
	uint8_t addr = 0x40 | (code << 3);

	lcd_send_command(addr);
	for (uint8_t i = 0; i < 8; i++)
		lcd_write_char(data[i]);
}