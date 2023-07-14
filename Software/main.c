void _start() {
	char* leds_addr = (char*) 0x70000008;
	*leds_addr = 0b1111;
}