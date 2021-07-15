#  mp4-cp1.s version 4.0
.align 4
.section .text
.globl _start
_start:

pcrel_TEST: auipc x10, %pcrel_hi(TEST)
    addi x1, x0, 1
    ori x2, x0, 2
    xori x3, x0, 3
    addi x4, x0, 4
    sw x1, %pcrel_lo(pcrel_TEST)(x10)
    nop
    slt x5, x1, x2
    srli x6, x3, 1
    slli x7, x3, 1
    lw x8, %pcrel_lo(pcrel_TEST)(x10)

DONEb:
    beq x0, x0, DONEb

.section .rodata
.balign 256
TEST:    .word 0xFFFFFFFF


