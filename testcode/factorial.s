# Abigail Wezelis
# Created: Sep 17 2020
# Modified: Sep 17 2020
# Fall 2020 ECE 385
# Factorial program for MP2

factorial.s:
.align 4
.section .text
.globl _star

_start:
    lw  x2, input
    ori x3, x2, 0
    
fact_loop:
    addi x2, x2, -1
    beq x2, x0, end_fact
    addi x4, x2, 0
    ori x6, x3, 0

mult_loop: 
    addi x4, x4, -1
    beq x4, x0, end_mult
    add x3, x3, x6
    jal x0, mult_loop
   
end_mult:
    jal x0, fact_loop

end_fact:
    la x10, result
    sw x3, 0(x10)

halt:
    beq x0, x0, halt

.section .rodata

bad:        .word 0xdeadbeef
threshold:  .word 0x00000040
input:      .word 0x0000000a # input for factorial
result:     .word 0x00000000 # output of factorial
good:       .word 0x600d600d
