.global _entry
.extern start

.data
.align 16
.space 0x1000
_main_stack:

.text
_entry:
    la sp, _main_stack

    call start
spin:
    j spin
