#include "kernel/io.h"
#include "devices/lcd.h"

struct klcd {
	char buffer[16][2];
	int cursor_y, cursor_x;
};

size_t klcd_write(struct kfile* file, const char* buffer, size_t size) {
	struct klcd* lcd = (struct klcd*)file;

	for (size_t i = 0; i < size; i++) {
		char ch = buffer[i];
		
		// TODO: Fix this
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
	}

	return size;
}

struct kfile klcd = {
	.write = klcd_write,
	.read = NULL
};