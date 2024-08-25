#include "kernel/io.h"

extern struct kfile klcd;

struct kfile* files[] = {
	[__FILE_LCD] = &klcd
};

size_t kfile_write(enum __file id, const char* buffer, size_t size) {
	struct kfile* file = files[id];
	return file->write(file, buffer, size);
}

size_t kfile_read(enum __file id, char* buffer, size_t size) {
	struct kfile* file = files[id];
	return file->read(file, buffer, size);
}