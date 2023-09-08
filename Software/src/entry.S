.global _entry
.extern start
.extern STACK_END_ADDR

.text
_entry:
    la sp, STACK_END_ADDR

    la a0, _trap
    csrw stvec, a0

    ecall

    call start
spin:
    j spin

_trap:
    li a7, 0x10
    
    csrr a1, sepc
    addi a1, a1, 4
    csrw sepc, a1

    sret
