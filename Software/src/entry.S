.global _entry
.extern start
.extern STACK_END_ADDR

.text
_entry:
    la sp, STACK_END_ADDR

    call start
spin:
    j spin
