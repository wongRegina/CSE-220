.data
.align 2
packet1: 
.byte 0x24 0x00 0x9A 0x50 0x00 0x10 0x52 0x07 0x59 0xA1 0xE6 0x02 0x47 0x72 0x61 0x63 0x65 0x20 0x4D 0x75 0x72 0x72 0x61 0x79 0x20 0x48 0x6F 0x70 0x70 0x65 0x72 0x20 0x77 0x61 0x73 0x20
.align 2
packet2: 
.byte 0x24 0x00 0x9A 0x50 0x18 0x10 0x52 0x07 0x59 0xA1 0xFE 0x02 0x6F 0x6E 0x65 0x20 0x6F 0x66 0x20 0x74 0x68 0x65 0x20 0x66 0x69 0x72 0x73 0x74 0x20 0x63 0x6F 0x6D 0x70 0x75 0x74 0x65
v0: .asciiz "v0: "

.text
.globl main
main:
la $a0, packet1
la $a1, packet2
jal compare_to
move $s0, $v0

la $a0, v0
li $v0, 4
syscall

move $a0, $s0 
li $v0, 1
syscall

li $a0, '\n'
li $v0, 11
syscall

li $v0, 10
syscall

.include "proj4.asm"
