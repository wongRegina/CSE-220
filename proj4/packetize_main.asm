.data
.align 2
packets: .space 189  # adjust as needed to store all bytes of the packets
msg: .asciiz "Grace Murray Hopper was one of the first computer programmers to work on the Harvard Mark I."
.align 2
payload_size: .word 12
version: .word 5
msg_id: .word 154
priority: .word 7
protocol: .word 289
src_addr: .word 161
dest_addr: .word 89
v0: .asciiz "v0: "

.text
.globl main
main:
la $a0, packets
la $a1, msg
lw $a2, payload_size
lw $a3, version
lw $t4, msg_id
lw $t5, priority
lw $t6, protocol
lw $t7, src_addr
lw $t8, dest_addr
addi $sp, $sp, -20
sw $t4, 0($sp)  # msg_id
sw $t5, 4($sp)  # priority
sw $t6, 8($sp)  # protocol
sw $t7, 12($sp) # src_addr
sw $t8, 16($sp) # dest_addr

jal packetize
addi $sp, $sp, 20
move $s0, $v0  # number of packets

la $a0, v0
li $v0, 4
syscall

move $a0, $s0 
li $v0, 1
syscall

li $a0, '\n'
li $v0, 11
syscall

# You should consider writing some code here to print out the contents of the packets[] array.

li $v0, 10
syscall

.include "proj4.asm"

.data
# Expected array of packets:
.align 2
.byte 0x18 0x00 0x9A 0x50 0x00 0x10 0x52 0x07 0x59 0xA1 0xDA 0x02 0x47 0x72 0x61 0x63 0x65 0x20 0x4D 0x75 0x72 0x72 0x61 0x79
.align 2
.byte 0x18 0x00 0x9A 0x50 0x0C 0x10 0x52 0x07 0x59 0xA1 0xE6 0x02 0x20 0x48 0x6F 0x70 0x70 0x65 0x72 0x20 0x77 0x61 0x73 0x20
.align 2
.byte 0x18 0x00 0x9A 0x50 0x18 0x10 0x52 0x07 0x59 0xA1 0xF2 0x02 0x6F 0x6E 0x65 0x20 0x6F 0x66 0x20 0x74 0x68 0x65 0x20 0x66
.align 2
.byte 0x18 0x00 0x9A 0x50 0x24 0x10 0x52 0x07 0x59 0xA1 0xFE 0x02 0x69 0x72 0x73 0x74 0x20 0x63 0x6F 0x6D 0x70 0x75 0x74 0x65
.align 2
.byte 0x18 0x00 0x9A 0x50 0x30 0x10 0x52 0x07 0x59 0xA1 0x0A 0x03 0x72 0x20 0x70 0x72 0x6F 0x67 0x72 0x61 0x6D 0x6D 0x65 0x72
.align 2
.byte 0x18 0x00 0x9A 0x50 0x3C 0x10 0x52 0x07 0x59 0xA1 0x16 0x03 0x73 0x20 0x74 0x6F 0x20 0x77 0x6F 0x72 0x6B 0x20 0x6F 0x6E
.align 2
.byte 0x18 0x00 0x9A 0x50 0x48 0x10 0x52 0x07 0x59 0xA1 0x22 0x03 0x20 0x74 0x68 0x65 0x20 0x48 0x61 0x72 0x76 0x61 0x72 0x64
.align 2
.byte 0x15 0x00 0x9A 0x50 0x54 0x10 0x12 0x07 0x59 0xA1 0x2A 0x03 0x20 0x4D 0x61 0x72 0x6B 0x20 0x49 0x2E 0x00