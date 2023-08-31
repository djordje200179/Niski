OUTPUT_ARCH("riscv")

MEMORY {
    ROM (rx) : ORIGIN = 0x40000000, LENGTH = 4K
    RAM (w!x) : ORIGIN = 0x50000000, LENGTH = 4K
}

SECTIONS {
    .rom.text : { 
        obj/entry.o(.text)
        *(.text)
    } > ROM

    .rom.rodata : {
        *(.rodata)
    } > ROM

    .ram.data : {
        *(.data)
    } > RAM
}