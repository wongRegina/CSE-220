.data
.align 2
packet1: 
.byte  0x18 0x00 0x9A 0x50 0x24 0x10 0x52 0x07 0x59 0xA1 0xFE 0x02 0x69 0x72 0x73 0x74 0x20 0x63 0x6F 0x6D 0x70 0x75 0x74 0x65
.align 2
packet2: 
.byte 0x15 0x00 0x9A 0x50 0x54 0x10 0x12 0x07 0x59 0xA1 0x2A 0x03 0x20 0x4D 0x61 0x72 0x6B 0x20 0x49 0x2E 0x00
v0: .asciiz "v0: "

.text
.globl main
main:
la $a0, packet2
la $a1, packet1
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
