#include <devices/ssds.h>
#include <stddef.h>
#include <stdbool.h>
#include <threads.h>

mtx_t mtx;
bool flag[4];
cnd_t cond[5];

int digit_thread(void* arg) {
	uintptr_t id = (uintptr_t)arg;

	mtx_lock(&mtx);

	if (!flag[id])
		cnd_wait(&cond[id], &mtx);

	ssds_set_digit(id, id);

	if (id < 3) {
		flag[id + 1] = true;
		cnd_signal(&cond[id + 1]);
	}

	mtx_unlock(&mtx);
	
	return 0;
}

void main() {
	ssds_on();

	thrd_t threads[4];

	mtx_init(&mtx, mtx_plain);
	for (int i = 0; i < 4; i++) {
		flag[i] = false;
		cnd_init(&cond[i]);
		thrd_create(&threads[i], digit_thread, (void*)(uintptr_t)i);
	}
	
	flag[0] = true;
	cnd_signal(&cond[0]);

	thrd_yield();
}