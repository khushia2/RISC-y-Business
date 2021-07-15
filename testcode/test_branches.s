#  mp4-cp1.s version 4.0
.align 4
.section .text
.globl _start
_start:

addi x4, x0, 4
loop: addi x1, x1, 1
addi x4, x4, -1
addi x2, x0, 14
bge x4, x0, loop
addi x5, x0, 5
addi x6, x0, 6
addi x7, x0, 7
addi x8, x0, 8
addi x9, x0, 9
halt: beq x0, x0, halt



