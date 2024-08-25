#pragma once

#include <stddef.h>

enum __file {
	__FILE_LCD,
	__FILE_KEYBOARD,
	__FILE_UART
};

size_t __io_write(enum __file file, const char* buffer, size_t size);
size_t __io_read(enum __file file, char* buffer, size_t size);