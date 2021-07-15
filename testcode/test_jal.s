#  mp4-cp1.s version 4.0
.align 4
.section .text
.globl _start
_start:

pcrel_BAD: auipc x10, %pcrel_hi(BAD)
pcrel_GOOD: auipc x11, %pcrel_hi(GOOD)
    nop
    nop
    nop
    nop
    addi x10, x10, %pcrel_lo(pcrel_BAD)
    addi x11, x11, %pcrel_lo(pcrel_GOOD)
    jal x5, JUMP
    nop
    nop
    nop
    lw x1, 0(x10)
    nop
    nop
    nop
    nop
JUMP: bne x1, x0, OOPS
    nop
    nop
    nop
    nop
    lw x2, 0(x11)

DONEgood:
    beq x0, x0, DONEgood

OOPS:
    lw x8, 0(x10)
DONEbad:
    beq x0, x0, DONEbad
    

.section .rodata
.balign 256
BAD:     .word 0xBADDBADD
GOOD:    .word 0x600D600D


