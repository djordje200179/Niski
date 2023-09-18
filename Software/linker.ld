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

	.ram.tbss : {
		MAIN_THREAD_TDATA_START = .;
		*(.tbss*)
		. = ALIGN(4);
	} > RAM

	.ram.tdata : {
		*(.tdata*)
		. = ALIGN(4);
	} > RAM

	. = ALIGN(16);
	MAIN_THREAD_STACK_START = .;
	. += 0x1000;
	MAIN_THREAD_STACK_END = .;

	. = ALIGN(64);
	HEAP_START = .;
	. = ORIGIN(RAM) + LENGTH(RAM);
	HEAP_END = .;
}

LEDS_CTRL_REG = 0x70000000;
LEDS_DATA_REG = 0x70000004;

BUZZER_CTRL_REG = 0x70000010;
BUZZER_DATA_REG = 0x70000014;

SSDS_CTRL_REG		 = 0x70000020;
SSDS_DATA_DIGITS_REG = 0x70000024;
SSDS_DATA_DOTS_REG	 = 0x70000028;

LCD_DATA_REG = 0x70000030;
LCD_CMD_REG  = 0x70000034;

DMA_CTRL_REG = 0x70000040;
DMA_SRC_REG  = 0x70000044;
DMA_DEST_REG = 0x70000048;
DMA_CNT_REG  = 0x7000004C;

PENDING_INTR_REG = 0x70000050;
ENABLE_INTR_REG  = 0x70000054;
CLAIM_INTR_REG   = 0x70000058;