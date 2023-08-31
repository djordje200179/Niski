OUTPUT_ARCH("riscv")

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
        *(.rodata)
    } > ROM

    .ram.bss : {
        *(.bss)
    } > RAM

    .ram.data : {
        *(.data)
    } > RAM

    .ram.stack : {
        STACK_START_ADDR = .;
        . += 4K;
        STACK_END_ADDR = .;
    } > RAM
}