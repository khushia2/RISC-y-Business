#  mp4-cp1.s version 4.0
.align 4
.section .text
.globl _start
_start:

test_fA_mem:
    addi x1, x0, 3          #x1 <= 3
    addi x2, x1, 2          #x2 <= 5
    bne  x1, x2, test_fA_wb
    lw   x8, BADD
    nop
    nop
    nop

test_fA_wb:
    addi x3, x0, 7          #x3 <= 7
    addi x20, x0, 11        #filler, x20 <= 11
    addi x4, x3, 4          #x4 <= 11
    beq  x4, x20, test_fA_both
    lw   x8, BADD
    nop
    nop

test_fA_both:
    add  x5, x0, x3         #x5 <= 7
    addi x5, x0, 8          #x5 <= 8
    add  x6, x5, x1         #x6 <= 11
    beq  x6, x20, test_fB_mem
    lw   x8, BADD
    nop
    nop

test_fB_mem:
    add  x10, x1, x2        #x10 <= 8
    add  x11, x1, x10       #x11 <= 11
    beq  x20, x11, test_fB_wb
    lw   x8, BADD
    nop
    nop
    nop

test_fB_wb:
    add  x12, x1, x2        #x12 <= 8
    addi x20, x0, 13        #filler, x20 <= 13
    add  x13, x2, x12       #x13 <= 13
    beq  x13, x20, test_fB_both
    lw   x8, BADD
    nop
    nop

test_fB_both:
    add  x14, x1, x2        #x14 <= 8
    add  x14, x5, x6        #x14 <= 19
    sub  x15, x11, x14      #x15 <= -8
    blt  x15, x0, test_load_use
    lw   x8, BADD
    nop
    nop

test_load_use:
    addi x3, x0, 12         #x3 <= 12
    lw   x1, FOUR           #x1 <= 4
    sub  x2, x1, x15        #x2 <= 12
    beq  x3, x2, test_f_br
    lw   x8, BADD
    nop

test_f_br:
    addi x6, x0, 8          #x6 <= 8
    beq  x12, x6, test_store
    lw   x8, BADD
    nop
    nop
    nop
    nop

test_store:
    la x16, SWADDR
    sw x6, 0(x16)
    beq x0, x0, test_load
    lw   x8, BADD
    nop
    nop

test_load:
    la x17, SWADDR
    lw  x7, 0(x17)
    beq x7, x6, test_slt_mem
    lw   x8, BADD

test_slt_mem:
    addi x1, x0, 1          #x1 <= 1
    slt x2, x15, x0         #x2 <= 1
    add x3, x2, x0          #x3 <= 1
    beq x1, x3, test_slt_wb
    lw   x8, BADD
    nop
    nop

test_slt_wb:
    slt x4, x15, x0         #x4 <= 1
    addi x3, x1, 1          #x3 <= 2
    add x5, x4, x0          #x5 <= 1
    beq x1, x5, test_auipc_mem
    lw   x8, BADD
    nop
    nop

test_auipc_mem:
    auipc x1, test_auipc_mem #x1 <= test_auipc_mem
    add x2, x1, x0           #x2 <= test_auipc_mem
    beq x1, x2, test_auipc_wb
    lw   x8, BADD
    nop
    nop
    nop

test_auipc_wb:
    auipc x3, test_auipc_wb  #x3 <= test_auipc_wb
    addi x4, x1, 1          #x4 <= test_auipc_mem + 1
    add x5, x3, x0          #x5 <= test_auipc_wb
    beq x5, x3, halt
    lw   x8, BADD
    nop
    nop

halt:
    beq x0, x0, halt  
    
DONEb:
    beq x0, x0, DONEb

.section .rodata
.balign 256
BADD:   .word 0xbaddbadd
FOUR:   .word 0x00000004
SWADDR: .word 0xFFFFFFFF


