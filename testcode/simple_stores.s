#  mp4-cp1.s version 4.0
.align 4
.section .text
.globl _start
_start:

pcrel_BYTE: auipc x10, %pcrel_hi(BYTE)
pcrel_HALF: auipc x11, %pcrel_hi(HALF)
    addi x1, x0, 0x12
    addi x2, x0, 0xaa
    addi x12, x0, 0x12
    addi x10, x10, %pcrel_lo(pcrel_BYTE)
    addi x11, x11, %pcrel_lo(pcrel_HALF)
    addi x13, x0, 0x34
    slli x1, x1, 8
    slli x2, x2, 8
    addi x14, x0, 0x56
    addi x15, x0, 0xaa
    nop
    nop
    ori x1, x1, 0x34
    ori x2, x2, 0xaa
    slli x15, x15, 8
    nop
    nop
    nop
    slli x1, x1, 8
    slli x2, x2, 8
    ori x15, x15, 0xaa
    nop
    nop
    nop
    ori x1, x1, 0x56
    ori x2, x2, 0xbb
    nop
    nop
    nop
    nop
    slli x1, x1, 8
    slli x2, x2, 8
    nop
    nop
    nop
    nop
    ori x1, x1, 0x78
    ori x2, x2, 0xbb
    nop
    nop
    nop
    nop
    sb x1, 0(x10)
    sb x14, 1(x10)
    sb x13, 2(x10)
    sb x12, 3(x10)
    sh x2, 0(x11)
    sh x15, 2(x11)
    nop
    nop
    nop
    lw x3, 0(x10)
    lw x4, 0(x11)
    nop
    nop
    nop
    nop
    bne x3, x1, BAD
    nop
    nop
    nop
    nop
    bne x4, x2, BAD
    nop
    nop
    nop
    nop

DONEgood:
    beq x0, x0, DONEgood

BAD:
    nop
pcrel_BADD: auipc x20, %pcrel_hi(BADD)
    nop
    nop
    nop
    nop
    nop
    addi x20, x20, %pcrel_lo(pcrel_BADD)
    nop
    nop
    nop
    nop
    nop
    lw x1, 0(x20)
DONEbad:
    beq x0, x0, DONEbad
    

.section .rodata
.balign 256
BYTE:   .word 0xbaddbadd
HALF:   .word 0xbaddbadd
SB:     .word 0xbaddbadd
SH:     .word 0xbaddbadd
SBU:    .word 0xbaddbadd
SHU:    .word 0xbaddbadd
BADD:   .word 0xbaddbadd

