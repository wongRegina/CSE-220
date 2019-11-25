# CSE 220 Programming Project #4
# Regina Wong
# rewong
# 112329774

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text

compute_checksum: #(version + msg id + total length + priority + flags + protocol + frag offset + src addr + dest addr) mod 2^16
li $v0, 0 # the sum
# Line one
lw $t0, ($a0)
# The total length
andi $t1, $t0, 0xFFFF
add $v0, $t1, $v0
# The msg ID 
andi $t1, $t0, 0x0FFF0000
srl $t1, $t1, 16
add $v0, $t1, $v0
# The version
andi $t1, $t0, 0xF0000000
srl $t1, $t1, 28
add $v0, $t1, $v0
# Second line
lw $t0, 4($a0)
# The Frag Offset
andi $t1, $t0, 0xFFF
add $v0, $t1, $v0
# The protocol
andi $t1, $t0, 0x3FF000
srl $t1, $t1, 12
add $v0, $t1, $v0
# The Flags(in binary)
andi $t1, $t0, 0xC00000
srl $t2, $t1, 22
	li $t3, 1
	beq $t3, $t2, onlyOne
	li $t1, 2
	li $t3, 2
	beq $t3, $t2, doneWithFlag
	li $t1, 3 
	j doneWithFlag
	onlyOne:
	li $t1, 1
	doneWithFlag:
add $v0, $t1, $v0
# The priority
andi $t1, $t0, 0xFF000000
srl $t1, $t1, 24
add $v0, $t1, $v0
# Third Line 
lw $t0, 8($a0)
# The Dest Addr
andi $t1, $t0, 0xFF
add $v0, $t1, $v0
# The Sorc Addr
andi $t1, $t0, 0xFF00
srl $t1, $t1, 8
add $v0, $t1, $v0
jr $ra

compare_to:
jr $ra

packetize:
jr $ra

clear_queue:
jr $ra

enqueue:
jr $ra

dequeue:
jr $ra

assemble_message:
jr $ra


#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
