#  mp4-cp1.s version 4.0
.align 4
.section .text
.globl _start
_start:

addi x1, x0, 7 #7
addi x20, x0, 0xe #e
nop
nop
nop
nop
add x2, x1, x1 #e
sll x3, x1, x1 #00000380
xor x4, x1, x20 #9
or  x5, x1, x20 #f
and x6, x1, x20 #6
nop
sub x7, x1, x2 #FFFFFFF9
nop
nop
nop
nop
nop
slt x8, x7, x0 #1
sltu x9, x7, x0 #0
sltu x10, x0, x7 #1
srl x11, x7, x5 #0000FFFF
sra x12, x7, x5 #FFFFFFFF

DONEb:
    beq x0, x0, DONEb

.section .rodata
.balign 256
BYTE:    .word 0x030201FE
HALF:    .word 0xFEDCBA98


