#pragma once

#include <stddef.h>
#include "common/io.h"

struct kfile {
	size_t (*write)(struct kfile* file, const char* buffer, size_t size);
	size_t (*read)(struct kfile* file, char* buffer, size_t size);
};

size_t kfile_write(enum __file id, const char* buffer, size_t size);
size_t kfile_read(enum __file id, char* buffer, size_t size);