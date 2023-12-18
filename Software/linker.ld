OUTPUT_ARCH("riscv")

ENTRY(entry)

MEMORY {
	ROM (rx) : ORIGIN = 0x40000000, LENGTH = 4 * 2K
	RAM (w!x) : ORIGIN = 0x50000000, LENGTH = 4 * 4K
}

SECTIONS {
	.rom.text : { 
		obj/kernel/entry.o(.text)
		*(.text*)
		. = ALIGN(4);
	} > ROM

	.rom.rodata : {
		*(.srodata*)
		*(.rodata*)
		. = ALIGN(4);
	} > ROM

	.rom.tbss : {
		TBSS_START = .;
		*(.tbss*)
		. = ALIGN(4);
		TBSS_END = .;
	} > ROM

	.rom.tdata : {
		TDATA_START = .;
		*(.tdata*)
		. = ALIGN(4);
		TDATA_END = .;
	} > ROM

	.ram.bss : {
		DATA_START = .;
		*(.sbss*)
		*(.bss*)
		. = ALIGN(4);
	} > RAM

	.ram.data : {
		*(.sdata*)
		*(.data*)
		. = ALIGN(4);
	} > RAM

	. = ALIGN(16);
	. += 0x100;
	KERNEL_STACK_END = .;

	. = ALIGN(64);
	HEAP_START = .;
	. = ORIGIN(RAM) + LENGTH(RAM);
	HEAP_END = .;
}

LEDS = 0x70000000;
BUZZER = 0x70000010;
SSDS = 0x70000020;
LCD = 0x70000030;
DMA = 0x70000040;
PLIC = 0x70000050;
BTNS = 0x70000060;