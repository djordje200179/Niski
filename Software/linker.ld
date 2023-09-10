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
		*(.srodata)
		*(.rodata)
	} > ROM

	.ram.bss : {
		*(.sbss)
		*(.bss)
	} > RAM

	.ram.data : {
		*(.sdata)
		*(.data)
	} > RAM

	. = ALIGN(16);
	STACK_START_ADDR = .;
	. += 0x1000;
	STACK_END_ADDR = .;

	. = ALIGN(64);
	HEAP_START_ADDR = .;
	. = ORIGIN(RAM) + LENGTH(RAM);
	HEAP_END_ADDR = .;
	
	/* KERNEL_HEAP_START_ADDR = .;
	. = ORIGIN(RAM) + LENGTH(RAM);
	KERNEL_HEAP_END_ADDR = .; */
}

LEDS_CTRL_REG = 0x70000000;
LEDS_DATA_REG = 0x70000004;

BUZZER_CTRL_REG = 0x70000010;
BUZZER_DATA_REG = 0x70000014;

SSDS_CTRL_REG = 0x70000020;
SSDS_DATA_DIGITS_REG = 0x70000024;
SSDS_DATA_DOTS_REG = 0x70000028;