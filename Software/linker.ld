OUTPUT_ARCH("riscv")

ENTRY(_entry)

MEMORY {
	ROM (rx) : ORIGIN = 0x40000000, LENGTH = 4 * 2K
	RAM (w!x) : ORIGIN = 0x50000000, LENGTH = 4 * 4K
}

SECTIONS {
	.rom.text : { 
		obj/entry.o(.text)
		*(.text)
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

	.ram.stack : {
		STACK_START_ADDR = .;
		. += 4K;
		STACK_END_ADDR = .;
	} > RAM
}

LEDS_CTRL_REG = 0x70000000;
LEDS_DATA_REG = 0x70000008;

BUZZER_CTRL_REG = 0x70000010;
BUZZER_DATA_REG = 0x70000018;

SEV_SEG_DISPLAYS_CTRL_REG = 0x70000020;
SEV_SEG_DISPLAYS_DATA_DIGITS_REG = 0x70000028;
SEV_SEG_DISPLAYS_DATA_DOTS_REG = 0x7000002C;