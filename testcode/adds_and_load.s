.align 4
.section .text
.globl _start
_start:

pcrel_SEVEN: auipc x10, %pcrel_hi(SEVEN)
addi x1, x0, 1
addi x2, x0, 2
addi x3, x0, 3
addi x10, x10, %pcrel_lo(pcrel_SEVEN)
addi x4, x0, 4
addi x5, x0, 5
addi x6, x0, 6
lw   x7, 0(x10)
addi x8, x0, 8
halt: beq x0, x0, halt  

.section .rodata
.balign 256
SEVEN:   .word 0x00000007


