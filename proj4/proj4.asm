# CSE 220 Programming Project #4
# Regina Wong
# rewong
# 112329774

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text

compute_checksum: #(version + msg id + total length + priority + flags + protocol + frag offset + src addr + dest addr) mod 2^16
	# Line one
		lw $t0, ($a0)
		# The total length
			andi $v0, $t0, 0xFFFF
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
			srl $t1, $t1, 22
			add $v0, $v0, $t1
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
# mod 2^16(0x10000)
li $t0, 0x10000
div $v0, $t0
mfhi $v0
jr $ra

compare_to: 
	lw $t0, ($a0)
	lw $t1, ($a1)
	# MSG ID
		andi $t2, $t0, 0xFFF0000 # msgID of the first packet
		andi $t3, $t1, 0xFFF0000 # msgID of the second packet
		srl $t2, $t2, 16
		srl $t3, $t3, 16
		bge $t2, $t3, notLessThanMsgID
			li $v0, -1
			j doneCompareTo		
		notLessThanMsgID:
			beq $t2, $t3, EqualMsgID
			li $v0, 1
			j doneCompareTo	
		EqualMsgID:
		# Frag Off
			lw $t0, 4($a0)
			lw $t1, 4($a1)
			andi $t2, $t0, 0xFFF # Frag Off of the first packet
			andi $t3, $t1, 0xFFF # Frag Off of the second packet
				bge $t2, $t3, notLessThanFragOff
				li $v0, -1
				j doneCompareTo		
			notLessThanFragOff:
				beq $t2, $t3, EqualFragOff
				li $v0, 1
				j doneCompareTo	
			EqualFragOff:
				lb $t0, 9($a0)
				lb $t1, 9($a1)
					bge $t2, $t3, notLessThanSrcAddr
					li $v0, -1
					j doneCompareTo		
				notLessThanSrcAddr:
					beq $t2, $t3, EqualSrcAddr
					li $v0, 1
					j doneCompareTo	
				EqualSrcAddr:
					li $v0, 0
	doneCompareTo:
jr $ra

packetize: 
lw $t4, 0($sp)  # msg_id
lw $t5, 4($sp)  # priority
lw $t6, 8($sp)  # protocol
lw $t7, 12($sp) # src_addr
lw $t8, 16($sp) # dest_addr
# Save the Save register values into the stack
	addi $sp, $sp, -36
	sw $s0, ($sp) 
	sw $s1, 4($sp) 
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	sw $ra, 32($sp) # return address
#Put things into the save registers
	move $s0, $a0 # Packet
	move $s1, $t4 # msg_id
	move $s2, $t5  # priority
	move $s3, $t6  # protocol
	move $s4, $t7 # src_addr
	move $s5, $t8 # dest_addr
	li $s6, 0 # Stores the remainder(for the last packet)
	li $s7, 0 # store the $v0 values
# Find the length of the msg
	li $t2, 0 # counter for the length of the string
	move $t3, $a1 # moves the value of the address of the msg
	strLen:
		lb $t4, 0($t3) #stores a bit of the string
		beqz $t4, strLenDone # To see if you are at the end of the String
		addi $t2, $t2, 1 # increment the length counter
		addi $t3, $t3, 1 #moves the pointer to the next bit
		j strLen
	strLenDone:
	div $t2, $a2
	mflo $t2 # Counter for the loop 
	mflo $s7
	mfhi $s6
# Loops to make the packets
sll $s1, $s1, 16 # msg ID
sll $s2, $s2, 24 # priority
sll $s3, $s3, 12 # protocol
sll $s4, $s4, 8  # src_addr
addi $t3, $a2, 12 # Total length 
li $t4, 0 # Fragment Offset
sll $a3, $a3, 28 # Version
li $t5, 4
div $a2, $t5
mflo $t5 # how many times it needs to go to word
LoopForMakingPackets:
	beqz $t2, DoneMakingFullPackets 
	move $t9, $t3 # stores the total length for the full packets
	or $t9, $t9, $s1 # store the message ID
	or $t9, $t9, $a3 # Store the version
	sw $t9, ($a0)
	move $t9, $t4 # Stores the fragment offset
	or $t9,$t9, $s3 # Stores the protocol
	ori $t9, $t9, 0x400000 # stores the flag
	or $t9, $t9, $s2 # Stores the priority
	sw $t9, 4($a0)
	move $t9, $s5 # Stores the des_addr
	or $t9, $t9, $s4 #Stores the src_addr
	sw $t9, 8($a0)
		jal compute_checksum
	sll $v0, $v0, 16
	or $t9, $t9, $v0
	sw $t9, 8($a0)
	move $t6, $t5
	addi $a0, $a0, 12
	loopToCopyToPayload:
		beqz $t6, doneCopyingToPayload
		lb $t7, ($a1)
		sb $t7, ($a0)
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		lb $t7, ($a1)
		sb $t7, ($a0)
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		lb $t7, ($a1)
		sb $t7, ($a0)
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		lb $t7, ($a1)
		sb $t7, ($a0)
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		addi $t6, $t6, -1	
		j loopToCopyToPayload	
	doneCopyingToPayload:	
	add $t4, $t4, $a2
	addi $t2, $t2, -1
	j LoopForMakingPackets
DoneMakingFullPackets:
bgtz $s6, partPacket
	sub $a0, $a0, $t3
	lw $t9, 4($a0)
	xori $t9, $t9, 0x400000
	sw $t9, 4($a0)
j packetizeRestoreValues
partPacket:
addi $s7, $s7, 1
addi $t3, $s6, 12
	move $t9, $t3 # stores the total length for the full packets
	or $t9, $t9, $s1 # store the message ID
	or $t9, $t9, $a3 # Store the version
	sw $t9, ($a0)
	move $t9, $t4 # Stores the fragment offset
	or $t9,$t9, $s3 # Stores the protocol (Flag was ignored)
	or $t9, $t9, $s2 # Stores the priority
	sw $t9, 4($a0)
	move $t9, $s5 # Stores the des_addr
	or $t9, $t9, $s4 #Stores the src_addr
	sw $t9, 8($a0)
		jal compute_checksum
	sll $v0, $v0, 16
	or $t9, $t9, $v0
	sw $t9, 8($a0)
	# copy the word over
	li $t5, 4
	div $s6, $t5
	mflo $t6 # how many times it needs to go to word
	addi $a0, $a0, 12
	loopToCopyToPayloadPart:
		beqz $t6, doneCopyingToPayloadPart
		lb $t7, ($a1)
		sb $t7, ($a0)
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		lb $t7, ($a1)
		sb $t7, ($a0)
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		lb $t7, ($a1)
		sb $t7, ($a0)
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		lb $t7, ($a1)
		sb $t7, ($a0)
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		addi $t6, $t6, -1	
		j loopToCopyToPayloadPart
	doneCopyingToPayloadPart:	
packetizeRestoreValues:
move $v0, $s7
# puts the original saved values back into their registers
	lw $s0, ($sp)
	lw $s1, 4($sp) 
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	lw $s7, 28($sp)
	lw $ra, 32($sp) # return address
	addi $sp, $sp, 36
jr $ra

clear_queue:
li $v0, -1
blez $a1, clearQueueDone
li $v0, 0
sh $0, ($a0)
sh $a1, 2($a0)
loopForClearQueue:
	beqz $a1, clearQueueDone
	addi $a0, $a0, 4
	sw $0, ($a0)	
	addi $a1, $a1, -1
	j loopForClearQueue
clearQueueDone:
jr $ra

enqueue: # Must call  compare_to($t0, $t1, $t2, $t3)
	lh $t4, ($a0) # Size
	lh $t5, 2($a0) # MAX_SIZE
	move $t5, $v0
	beq $t4, $t5, enqueueDone
	#Memory on the stack
		addi $sp, $sp, -12
		sw $s0, ($sp)
		sw $s1, 4($sp)
		sw $s2, 8($sp)
	# Put things into the saved registers
		move $s0, $a0 # Queue
		move $s1, $a1 # Packet
		move $s2, $ra # Return Value
	# Puts the value packet into the heap
		sll $t5, $t4, 2
		add $a0, $a0, $t5
		sw $s1, 4($a0)
		move $a0, $s0
	move $t6, $t4 # pointer to arr
	li $t7, 2
	enqueueLoop:
		blez $t4, enqueueRestoreValues
		addi $t6, $t6, -1
		div $t6, $t7
		mflo $t6
		
		sll $t5, $t4, 2
		add $a1, $s0, $t5
		addi $a1, $a1, 4
		lw $a1, ($a1)
		sll $t5, $t6, 2
		add $a0, $s0, $t5
		addi $a0, $a0, 4
		lw $a0, ($a0)
		jal compare_to
		move $a0, $s0
		move $a1, $s1
		bltz $v0, enqueueRestoreValues
		# Get the values to swap
			sll $t5, $t6, 2
			add $a0, $s0, $t5
			lw $t8, 4($a0)
			sll $t5, $t4, 2
			add $a0, $s0, $t5
			lw $t9, 4($a0)
		# Swap the values
			sll $t5, $t6, 2
			add $a0, $s0, $t5
			sw $t9, 4($a0)
			sll $t5, $t4, 2
			add $a0, $s0, $t5
			sw $t8, 4($a0)
		move $a0, $s0
		move $t4, $t6
		j enqueueLoop
	enqueueRestoreValues:
		move $ra, $s2
		lw $s0, ($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		addi $sp, $sp, 12
# Increment size on the heap
 	lh $v0, ($a0)
  	addi $v0, $v0, 1
 	sh $v0, ($a0)
 	lh $v0, ($a0)
enqueueDone:
jr $ra

dequeue: # Must call  compare_to($t0, $t1, $t2, $t3)
	li $v0, 0
	lh $t4, ($a0) # Size
	beqz $t4, dequeueDone
	#Memory on the stack
		addi $sp, $sp, -16
		sw $s0, ($sp)
		sw $s1, 4($sp)
		sw $s2, 8($sp)
		sw $s3, 12($sp)
		move $s0, $a0
		move $s1, $ra
	# Obtain the last element ($t6) and moving it to the root
		sll $t5, $t4, 2
		add $a0, $s0, $t5
		lw $t6, ($a0)
		sw $0, ($a0)
		move $a0, $s0
		lw $s3, 4($a0)
		sw $t6, 4($a0)
	li $t6, 0 # psn of the last element
	heapifyDown: # fix the heap
		lh $t9, 2($a0) # MAX_SIZE
		sll $t7, $t6, 1 
		addi $t7, $t7, 1 # $t7 is left child
		addi $t8, $t7, 1 # $t8 is right child
		bge $t7, $t9, dequeueRestoreValue
		bge $t8, $t9, moveLeft
		sll $t7, $t7,2
		add $a0, $a0, $t7
		lw $a0, 4($a0)
		sll $t8, $t8, 2
		add $a1, $s0, $t8
		lw $a1, 4($a1)
		jal compare_to
		move $a0, $s0
		bgtz $v0, moveRight # left is greater than right child
		moveLeft:
			sll $t9, $t6,2
			add $a0, $s0, $t9
			lw $a0, 4($a0)
			add $a1, $s0, $t7
			lw $a1, 4($a1)
			jal compare_to
			bltz $v0, dequeueRestoreValue
			# Get The Values to Swap
				add $t8, $s0, $t9
				lw $a0, 4($t8)
				add $t8, $t7, $s0
				lw $a1, 4($t8)
			# Swap the values
				add $t8, $s0, $t9
				sw $a1, 4($t8)
				add $t8, $t8, $s0
				sw $a0, 4($t8)
			sll $t6, $t6, 1
			addi $t6, $t6, 1
			move $a0, $s0
			j heapifyDown
		moveRight:
			sll $t9, $t6,2
			add $a0, $s0, $t9
			lw $a0, 4($a0)
			add $a1, $s0, $t8
			lw $a1, 4($a1)
			jal compare_to
			move $a0, $s0
			bltz $v0, dequeueRestoreValue
			# Get The Values to Swap
				add $a0, $s0, $t9
				lw $a0, 4($a0)
				add $a1, $s0, $t8
				lw $a1, 4($a1)
			# Swap the values
				add $t7, $s0, $t9
				sw $a1, 4($t7)
				add $t7, $t8, $s0
				sw $a0, 4($t7)
			sll $t6, $t6, 1
			addi $t6, $t6, 2
			move $a0, $s0
			j heapifyDown
	dequeueRestoreValue:
		# change the counter
		lh $t0, ($s0)
		addi $t0, $t0, -1
		sh $t0, ($s0)
		move $ra, $s1
		move $v0, $s3 # move the address
		lw $s0, ($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		addi $sp, $sp, 16		
dequeueDone:
jr $ra

assemble_message: # must call compute_checksum($t0, $t1) (la $s0, packet )
# la $a0, msg
# la $a1, queue
# pop out from the queue and put it into msg
	#Memory on the stack
		addi $sp, $sp, -16
		sw $s0, ($sp)
		sw $s1, 4($sp)
		sw $s2, 8($sp)
		sw $s3, 12($sp)
		move $s0, $a0 # msg
		move $s1, $ra # return address
		lh $s2, ($a1) # $v0
		li $s3, 0 # $v1
	lh $t2, ($a1) # Size/ counter for the loop 
	assembleMessageLoop:
		beqz $t2, assembleMessageLoopDone
		sll $t3, $t2, 2
		add $t3, $t3, $a1
		lw $t3, ($t3)  # address of the item from the queue
		lh $t4, 10($t3) # Checksum from the packet
		move $a0, $t3
		jal compute_checksum
			move $a0, $s0
			beq $v0, $t4, checksumEqual
			addi $s3, $s3, 1 # increment the number of packets that fail the checksum test
		checksumEqual: 
			lh $t0, ($t3) # total length
			addi $t0, $t0, -12 # length of the word
			lh $t1, 4($t3)
			andi $t1, $t1, 0xFFF # fragment offset
			add $t4, $t1, $a0 # where the word would go
			addi $t5, $t3, 12 # Payloads starts
			loopForWord:
				beqz $t0, loopForWordDone
				lb $t6, ($t5)
				sb $t6, ($t4)
				addi $t5, $t5, 1
				addi $t4, $t4, 1
				addi $t0, $t0, -1
				j loopForWord
			loopForWordDone:
		addi $t2, $t2, -1
		j assembleMessageLoop
	assembleMessageLoopDone: # move things back
		move $v0, $s2 # move the number of packet dequeue
		move $v1, $s3 # move the packets that failed the check sum test
		move $ra, $s1 # move the return address
		lw $s0, ($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		addi $sp, $sp, 16	
jr $ra


#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
