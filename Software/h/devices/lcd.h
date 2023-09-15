#pragma once

#include <stdint.h>

enum lcd_command {
	LCD_CMD_CLEAR_SCREEN = 0x01,
	LCD_CMD_RETURN_HOME = 0x02,
	LCD_CMD_DECREMENT_CURSOR = 0x04,
	LCD_CMD_INCREMENT_CURSOR = 0x06,
	LCD_CMD_SHIFT_DISPLAY_RIGHT = 0x05,
	LCD_CMD_SHIFT_DISPLAY_LEFT = 0x07,
	LCD_CMD_DISPLAY_OFF_CURSOR_OFF = 0x08,
	LCD_CMD_DISPLAY_OFF_CURSOR_ON = 0x0A,
	LCD_CMD_DISPLAY_ON_CURSOR_OFF = 0x0C,
	LCD_CMD_DISPLAY_ON_CURSOR_BLINK = 0x0E,
	LCD_CMD_DISPLAY_ON_CURSOR_BLINK_BLOCK = 0x0F,
	LCD_CMD_SHIFT_CURSOR_LEFT = 0x10,
	LCD_CMD_SHIFT_CURSOR_RIGHT = 0x14,
	LCD_CMD_SHIFT_ENTIRE_DISPLAY_LEFT = 0x18,
	LCD_CMD_SHIFT_ENTIRE_DISPLAY_RIGHT = 0x1C,
	LCD_CMD_INIT = 0x38
};

void lcd_init();
void lcd_clear();
void lcd_move_to(unsigned short x, unsigned short y);

void lcd_send_command(enum lcd_command cmd);
void lcd_write_char(char ch);
//void lcd_register_char(char code, const char* data);