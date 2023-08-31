void calculate() {
	int a = 0, b = 1;

	for (int i = 0; i < 10; i++) {
		int c = a + b;
		a = b;
		b = c;
	}

	asm ("mv s1, %0" : : "r" (a));
}

void show() {
	char* leds_ctrl_addr = (char*) 0x70000000;
	char* leds_data_addr = (char*) 0x70000008;

	*leds_ctrl_addr = 0b1;

	char value;
	asm ("mv %0, s1" : "=r" (value));

	*leds_data_addr = value;
}

void start() {
	void (*fun)() = &calculate;
	fun();

	fun = &show;
	fun();
}