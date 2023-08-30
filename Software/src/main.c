void _start() {
	char* leds_ctrl_addr = (char*) 0x70000000;
	char* leds_data_addr = (char*) 0x70000008;

	*leds_ctrl_addr = 0b0001;
	*leds_data_addr = 0b1011;

	while (1);
}