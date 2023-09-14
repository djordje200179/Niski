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
	} > ROM

	.rom.rodata : {
		*(.srodata*)
		*(.rodata*)
	} > ROM

	.ram.bss : {
		*(.sbss*)
		*(.bss*)
	} > RAM

	.ram.data : {
		*(.sdata*)
		*(.data*)
	} > RAM

	. = ALIGN(16);
	STACK_START = .;
	. += 0x1000;
	STACK_END = .;

	. = ALIGN(64);
	HEAP_START = .;
	. = ORIGIN(RAM) + LENGTH(RAM);
	HEAP_END = .;
}

LEDS_CTRL_REG = 0x70000000;
LEDS_DATA_REG = 0x70000004;

BUZZER_CTRL_REG = 0x70000010;
BUZZER_DATA_REG = 0x70000014;

SSDS_CTRL_REG = 0x70000020;
SSDS_DATA_DIGITS_REG = 0x70000024;
SSDS_DATA_DOTS_REG = 0x70000028;

LCD_DATA_REG = 0x70000030;
LCD_CMD_REG = 0x70000034;