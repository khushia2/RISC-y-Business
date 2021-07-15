#  mp4-cp1.s version 4.0
.align 4
.section .text
.globl _start
_start:

lui x20, 0xFFFFF
addi x1, x0, 7 #7
nop
nop
nop
nop
nop
slli x2, x1, 29 #e0000000
xori x3, x1, 9 #ea
ori  x4, x1, 9 #f
andi x5, x1, 3 #4
nop
nop
slti x6, x2, 0 #1
sltiu x7, x2, 0 #0
srli x8, x2, 16 #0000e000
srai x9, x2, 16 #ffffe000

DONEb:
    beq x0, x0, DONEb

.section .rodata
.balign 256
BYTE:    .word 0x030201FE
HALF:    .word 0xFEDCBA98


