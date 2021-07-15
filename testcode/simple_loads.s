#  mp4-cp1.s version 4.0
.align 4
.section .text
.globl _start
_start:

pcrel_BYTE: auipc x10, %pcrel_hi(BYTE)
pcrel_HALF: auipc x11, %pcrel_hi(HALF)
    nop
    nop
    nop
    nop
    addi x10, x10, %pcrel_lo(pcrel_BYTE)
    addi x11, x11, %pcrel_lo(pcrel_HALF)
    nop
    nop
    nop
    nop
    lb x1, 0(x10)
    lb x2, 1(x10)
    lb x3, 2(x10)
    lb x4, 3(x10)
    lh x5, 0(x11)
    lh x6, 2(x11)
    lbu x7, 3(x11)
    lhu x8, 2(x11)

DONEb:
    beq x0, x0, DONEb

.section .rodata
.balign 256
BYTE:    .word 0x030201FE
HALF:    .word 0xFEDCBA98


