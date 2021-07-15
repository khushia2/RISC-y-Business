#  mp4-cp1.s version 4.0
.align 4
.section .text
.globl _start
_start:
	addi x1, x0, 1
    beq x0, x0, label 
    addi x2, x0, 2
    addi x3, x0, 3
label: addi x4, x0, 4
    
DONEb:
    beq x0, x0, DONEb

.section .rodata
.balign 256
ONE:    .word 0x00000001
TWO:    .word 0x00000002
NEGTWO: .word 0xFFFFFFFE
TEMP1:  .word 0x00000001
GOOD:   .word 0x600D600D
BADD:   .word 0xBADDBADD
BYTES:  .word 0x04030201
HALF:   .word 0x0020FFFF

