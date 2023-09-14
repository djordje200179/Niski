#pragma once

void lcd_init();
void lcd_clear();

void lcd_send_command(char command);
void lcd_write_char(char ch);
void lcd_write_string(char* str);