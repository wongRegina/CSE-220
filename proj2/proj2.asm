# CSE 220 Programming Project #2
# Regina Wong
#  REWONG
#  112329774

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text

strlen:
	li $t0, 0 #counter
	loopToCountLength:
		lb $t1, 0($a0) #stores the first bit of the string
		beqz $t1, endOfString # To see if you are at the end of the String
		addi $t0, $t0, 1 # increment the length counter
		addi $a0, $a0, 1 #moves the pointer to the next bit
		j loopToCountLength
	endOfString:
	move $v0, $t0 # moves the string length to the return value
    jr $ra

index_of:
	li $t0, 0 #Counter
	beqz $a1, done
	li $t0, -1 # Return Value
	li $t1, 0 # Counter
	loopToCheckIfValueInString:
		lb $t2, 0($a0) #stores the first bit of the string
		beqz $t2, done # To see if you are at the end of the String
		bne $t2, $a1, notEqual # If the char at that bit isn't equal it would jump to not Equal
			move $t0, $t1 # moves the counter value to the return value
			j done # Ends the program
		notEqual: 
		addi $t1, $t1, 1 # imcrements the counter
		addi $a0, $a0,1 # moves the pointer to the next bit
		j loopToCheckIfValueInString
	done:
	move $v0, $t0 # moves the temp return value to the  real return value
    jr $ra

bytecopy: # lw for length
	lw $t0, 0($sp) # length of the ammount you carry
	li $t1, -1 # stores the return value
	blez $t0, return # If the length less then or equal to zero, it would jump to return
	bltz $a1, return # If the sorce position is less than zero
	bltz $a3, return # If the des position is less than zero
	li $t1, 0 # Moves 0 to the return value 
	findFirstInSource: # moves down the source until the first element to copy is found
		beqz $a1, findFirstInDest # See if we reach the first element
		addi $a1, $a1, -1 # Decreaase the source counter
		addi $a0, $a0, 1 # moves up one in the string
		j findFirstInSource
	findFirstInDest: # moves to the first element to replace in dest
		beqz $a3, enterValuesInDest # See if we reach the first element
		addi $a3, $a3, -1 # Decrease the counter
		addi $a2, $a2, 1 # Moves up one in the string
		j findFirstInDest
	enterValuesInDest: # replaces values of the string
		beqz $t0, return # Check if all the values that need to be replaced was replaced
		lb $t2, 0($a0) # Loads the byte of the source
		sb $t2, ($a2) # Stores the byte into dest from the source
		addi $a2, $a2, 1 
		addi $a0, $a0, 1
		addi $t0, $t0, -1
		addi $t1, $t1,1 
		j enterValuesInDest
	return:
	move $v0, $t1 # moves the return value
	jr $ra

scramble_encrypt:
	li $t1, 0 # Counter for the number characters encrypted
	cipherLoop:
		lb $t0, ($a1) # get a single byte
		beqz $t0, cipherDone # checks if null terminator
		move $t3, $a2 # copy of alph 
		li $t2, 65
		blt $t0, $t2, notALetter # If the values is less than 65 is it not a letter
		li $t2, 90
		bgt $t0, $t2, lowerCase # If the value is greater than 90 it is not a uppercase
		upperCase:
			addi $t0, $t0, -65 # subtract 65 to get the index of the alph
			upperAlph: # moves the pointer to the index of the alph
				beqz $t0, upperDone 
				addi $t3, $t3, 1
				addi $t0, $t0, -1
				j upperAlph
			upperDone:
			lb $t4, ($t3) # loads the index of $t3 into $t4
			sb $t4, ($a0) # pus $t4 into the cipher string
			addi $t1, $t1, 1 # adds one to the counter
			j cipherLetterDone
		lowerCase:
			li $t2, 97 # If the value is less than 97, then it isn't a letter
			blt $t0, $t2, notALetter
			li $t2, 122 # If the value is greater than 122, then it isn't a letter
			bgt $t0, $t2, notALetter
			addi $t0, $t0, -71 # Subtract 70 to get the value of the index in alph
			lowerAlph: #  moves the pointer to the index of the alph
				beqz $t0, lowerDone
				addi $t3, $t3, 1
				addi $t0, $t0, -1
				j lowerAlph
			lowerDone:
				lb $t4, ($t3) # loads the index of $t3 into $t4
				sb $t4, ($a0) # pus $t4 into the cipher string
			addi $t1, $t1, 1 # adds one to the counter
			j cipherLetterDone
		notALetter: # If it isn't a letter, it would move the bit from the plain text
			lb $t0, ($a1) 
			sb $t0, ($a0)
		cipherLetterDone:
			addi $a0, $a0, 1
			addi $a1, $a1, 1
			j cipherLoop	
	cipherDone:
	sb $0, ($a0) # adds a null terminator to the string
	move $v0, $t1
	jr $ra

scramble_decrypt:
	addi $sp, $sp, -8
	sw $s0, 4($sp)
	sw $s1, ($sp)
	li $t5, 0 # Counter for the letters decrypted
	decryptLoop:
		lb $t1, ($a1) # Gets a bit of the decrypted text
		beqz $t1, decryptDone # Checks if the bit is a null terminator
		move $t2, $a2 # A copy of the alphabet
		# get index of the bit in alph using index_of
			move $s0, $a0 
			move $s1, $a1
			addi $sp, $sp, -4 # make space on the stack
			sw $ra, ($sp) # saves $ ra on the stack
			move $a0, $t2
			move $a1, $t1
			jal index_of
			lw $ra, ($sp) # restores $s0 from the stack
			addi, $sp, $sp,4 # deallocate stack space
			move $a0, $s0
			move $a1, $s1
		move $t3, $v0 # stores the index of the char in the alph
		bltz $t3, decryptNotALetter # if the index is less than zero then it is not a letter
		li $t4, 25 # The point of difference in upper and lower case letters
		bgt $t3, $t4, decryptLowerCase
			addi $t3, $t3, 65 # Upper case letters: add 65 to get true ascii value
			sb $t3, ($a0)
			addi $t5, $t5, 1
			j decryptLetterDone
		decryptLowerCase:
			addi $t3, $t3, 71 # Lower case letters: add 71 to get true ascii value
			sb $t3, ($a0)
			addi $t5, $t5, 1
			j decryptLetterDone
		decryptNotALetter:
			lb $t1, ($a1) # If it isn't a letter, it would take the bit from the decrypted text
			sb $t1, ($a0)
		decryptLetterDone:
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		j decryptLoop
	decryptDone:
	sb $0, ($a0) # adds a null terminator to the string
	move $v0, $t5
	lw $s0, 4($sp)
	lw $s1, ($sp)
	addi $sp, $sp, 8
	jr $ra

base64_encode:
	addi $sp, $sp, -4
	sw $s0, ($sp)
	li $t7, 0 # counter for the number of char that was encoded
		move $s0, $a0
		addi $sp, $sp, -4 # make space on the stack
		sw $ra, ($sp) # saves $ ra on the stack
		move $a0, $a1
		jal strlen
		lw $ra, ($sp) # restores $sp from the stack
		addi, $sp, $sp,4 # deallocate stack space
		move $t2, $v0 # stores the length of the string
		move $a0, $s0
	li $t1, 3
	div $t2, $t1 # divides the string length by 3
	mflo $t4 # the quotient when divided
	#All the encoding but the last 
	li $t0, 0xFFFFFF # the masking needed to obtain three letters
	loop64Encoding:
		beqz $t4, last4Encoding
		lbu $t1, ($a1)
		sll $t1, $t1, 16
		lbu $t2, 1($a1) 
		sll $t2, $t2, 8
		lbu $t3, 2($a1)
		li $t5, 0
		or $t5, $t5, $t1
		or $t5, $t5, $t2
		or $t5, $t5, $t3
		# First Letter
			li $t1, 0xFC0000
			and $t2, $t5, $t1
			srl $t2, $t2, 18
			move $t1, $a2 # copy alph
			firstLetter64:
				beqz $t2, firstLetterDone
				addi $t1, $t1, 1
				addi $t2, $t2, -1
				j firstLetter64
			firstLetterDone:
			lb $t2, ($t1)
			sb $t2, ($a0)
			addi $a0, $a0, 1
		# Second Letter
			li $t1, 0x3F000
			and $t2, $t5, $t1
			srl $t2, $t2, 12
			move $t1, $a2 # copy alph
			secondLetter64:
				beqz $t2, secondLetterDone
				addi $t1, $t1, 1
				addi $t2, $t2, -1
				j secondLetter64
			secondLetterDone:
			lb $t2, ($t1)
			sb $t2, ($a0)
			addi $a0, $a0, 1
		# Third Letter
			li $t1, 0xFC0
			and $t2, $t5, $t1
			srl $t2, $t2, 6
			move $t1, $a2 # copy alph
			thirdLetter64:
				beqz $t2, thirdLetterDone
				addi $t1, $t1, 1
				addi $t2, $t2, -1
				j thirdLetter64
			thirdLetterDone:
			lb $t2, ($t1)
			sb $t2, ($a0)
			addi $a0, $a0, 1
		# Last Letter
			li $t1, 0x3F
			and $t2, $t5, $t1
			move $t1, $a2 # copy alph
			lastLetter64:
				beqz $t2, lastLetterDone
				addi $t1, $t1, 1
				addi $t2, $t2, -1
				j lastLetter64
			lastLetterDone:
			lb $t2, ($t1)
			sb $t2, ($a0)
			addi $a0, $a0, 1
		addi $t7, $t7, 4
		addi $t4, $t4, -1
		addi $a1, $a1, 3
		j loop64Encoding
	#Last 4 encoding
	last4Encoding:
		mfhi $t3 # the remainder when divided
		beqz $t3, rem0
		li $t1, 1
		beq $t3, $t1, rem1
		li $t1, 2
		beq $t3, $t1, rem2
		rem0: #nothing special 
			j finish64Encoding
		rem1: # Norm. two bits shift to the left. Then two equal signs
			lbu $t1, ($a1)
			move $t5, $t1
			li $t1, 0xFC
			and $t2, $t5, $t1
			srl $t2, $t2, 2
				move $t1, $a2 # copy alph
				firstRem1Letter64:
					beqz $t2, firstRem1LetterDone
					addi $t1, $t1, 1
					addi $t2, $t2, -1
					j firstRem1Letter64
				firstRem1LetterDone:
			lb $t2, ($t1)
			sb $t2, ($a0)
			addi $a0, $a0, 1
				li $t1, 0x3
				and $t2, $t5, $t1
				sll $t2, $t2, 4
				move $t1, $a2 # copy alph
				secondRem1Letter64:
					beqz $t2, secondRem1LetterDone
					addi $t1, $t1, 1
					addi $t2, $t2, -1
					j secondRem1Letter64
				secondRem1LetterDone:
				lb $t2, ($t1)
				sb $t2, ($a0)
			addi $a0, $a0, 1
				li $t1, '='
				sb $t1, ($a0)
			addi $a0, $a0, 1
				li $t1, '='
				sb $t1, ($a0)
			addi $a0, $a0, 1
			addi $t7, $t7, 4
			j finish64Encoding
		rem2: # Norm. Norm. 4 buts shift to the left. Then equals sign
			lbu $t1, ($a1)
			sll $t1, $t1, 16
			lbu $t2, 1($a1) 
			sll $t2, $t2, 8
			li $t3, 0
			li $t5, 0
			or $t5, $t5, $t1
			or $t5, $t5, $t2
			or $t5, $t5, $t3
		# First Letter
			li $t1, 0xFC0000
			and $t2, $t5, $t1
			srl $t2, $t2, 18
			move $t1, $a2 # copy alph
			firstRem2Letter64:
				beqz $t2, firstRem2LetterDone
				addi $t1, $t1, 1
				addi $t2, $t2, -1
				j firstRem2Letter64
			firstRem2LetterDone:
			lb $t2, ($t1)
			sb $t2, ($a0)
			addi $a0, $a0, 1
		# Second Letter
			li $t1, 0x3F000
			and $t2, $t5, $t1
			srl $t2, $t2, 12
			move $t1, $a2 # copy alph
			secondRem2Letter64:
				beqz $t2, secondRem2LetterDone
				addi $t1, $t1, 1
				addi $t2, $t2, -1
				j secondRem2Letter64
			secondRem2LetterDone:
			lb $t2, ($t1)
			sb $t2, ($a0)
			addi $a0, $a0, 1
		# Third Letter
			li $t1, 0xFC0
			and $t2, $t5, $t1
			srl $t2, $t2, 6
			move $t1, $a2 # copy alph
			thirdRem3Letter64:
				beqz $t2, thirdRem3LetterDone
				addi $t1, $t1, 1
				addi $t2, $t2, -1
				j thirdRem3Letter64
			thirdRem3LetterDone:
			lb $t2, ($t1)
			sb $t2, ($a0)
			addi $a0, $a0, 1
					li $t1, '='
					sb $t1, ($a0)
				addi $a0, $a0, 1
			addi $t7, $t7, 4
			j finish64Encoding
	finish64Encoding:
	lw $s0, ($sp)
	addi $sp, $sp, 4
	sb $0, ($a0) # adds a null terminator to the string
	move $v0, $t7
	jr $ra

base64_decode:
 	addi $sp, $sp, -12
 	sw $s2, 8($sp)
	sw $s0, 4($sp)
	sw $s1, ($sp)
	move $s2, $a0
 	decode64Loop:
		lbu $t6, ($a1)
		beqz $t6, decoding64LoopDone
		li $t0, '='
		bne $t6, $t0, notEquals1
		li $t6, 0
		j skip1search
		notEquals1:
			move $s0, $a0 
			move $s1, $a1
			addi $sp, $sp, -4 # make space on the stack
			sw $ra, ($sp) # saves $ ra on the stack
			move $a0, $a2
			move $a1, $t6
			jal index_of
			lw $ra, ($sp) # restores $s0 from the stack
			addi, $sp, $sp,4 # deallocate stack space
			move $a0, $s0
			move $a1, $s1
		sll $t6, $v0, 18
		skip1search:
		lbu $t7, 1($a1)
		li $t0, '='
		bne $t7, $t0, notEquals2
		li $t7, 0
		j skip2search
		notEquals2:
			move $s0, $a0 
			move $s1, $a1
			addi $sp, $sp, -4 # make space on the stack
			sw $ra, ($sp) # saves $ ra on the stack
			move $a0, $a2
			move $a1, $t7
			jal index_of
			lw $ra, ($sp) # restores $s0 from the stack
			addi, $sp, $sp,4 # deallocate stack space
			move $a0, $s0
			move $a1, $s1
		sll $t7, $v0, 12
		skip2search:
		lbu $t3, 2($a1)
		li $t0, '='
		bne $t3, $t0, notEquals3
		li $t3, 0
		j skip3search
		notEquals3:
			move $s0, $a0 
			move $s1, $a1
			addi $sp, $sp, -4 # make space on the stack
			sw $ra, ($sp) # saves $ ra on the stack
			move $a0, $a2
			move $a1, $t3
			jal index_of
			lw $ra, ($sp) # restores $s0 from the stack
			addi, $sp, $sp,4 # deallocate stack space
			move $a0, $s0
			move $a1, $s1
		sll $t3, $v0, 6
		skip3search:
		lbu $t4, 3($a1)
		li $t0, '='
		bne $t4, $t0, notEquals4
		li $t4, 0
		j skip4search
		notEquals4:
			move $s0, $a0 
			move $s1, $a1
			addi $sp, $sp, -4 # make space on the stack
			sw $ra, ($sp) # saves $ ra on the stack
			move $a0, $a2
			move $a1, $t4
			jal index_of
			lw $ra, ($sp) # restores $s0 from the stack
			addi, $sp, $sp,4 # deallocate stack space
			move $a0, $s0
			move $a1, $s1
		move $t4, $v0
		skip4search:
		li $t5, 0
		or $t5, $t5, $t6
		or $t5, $t5, $t7
		or $t5, $t5, $t3
		or $t5, $t5, $t4
			
		Start64Encoding:
		li $t0, 0xFF0000
		beqz $t0, decoding64LoopDone
		and $t0, $t5, $t0
		srl $t0, $t0, 16
		sb $t0, ($a0)
		addi $a0, $a0, 1
		li $t0, 0xFF00
		beqz $t0, decoding64LoopDone
		and $t0, $t5, $t0
		srl $t0, $t0, 8
		sb $t0, ($a0)
		addi $a0, $a0, 1
		beqz $t0, decoding64LoopDone
		li $t0, 0xFF
		and $t0, $t5, $t0
		sb $t0, ($a0)
		
		addi $a0, $a0, 1
		addi $a1, $a1, 4	
		j decode64Loop
	decoding64LoopDone:
	sb $0, ($a0) # adds a null terminator to the string
		move $s0, $a0
		addi $sp, $sp, -4 # make space on the stack
		sw $ra, ($sp) # saves $ ra on the stack
		move $a0, $s2
		jal strlen
		lw $ra, ($sp) # restores $sp from the stack
		addi, $sp, $sp,4 # deallocate stack space
		move $a0, $s0
	lw $s0, 4($sp)
	lw $s1, ($sp)
	lw $s2, 8($sp)
	addi $sp, $sp, 8
	jr $ra

bifid_encrypt: 
	li $v0, -1
	blez $a3, bidfidEncrpytDone3
	
	lw $t0, ($sp)
	lw $t1, 4($sp)
	addi $sp, $sp, 8
	
	addi $sp, $sp, -36
	sw $s0, ($sp) 
	sw $s1, 4($sp) 
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	sw $ra, 32($sp) 

	move $s0, $a0 #cipher text
	move $s1, $a1 # plain text
	move $s2, $a2 # key_square
	move $s3, $a3 # period
	move $s4, $t0 # index_buffer
	move $s5, $t1 # block_buffer

	# finds the length of the string
		move $a0, $a1
		jal strlen
		move $a0, $s0
		move $s6, $v0 # Length of string
		move $s7, $s6
	
	li $t3, 0 # Counter
	bidfidEncrpytLoop:
		lb $t4, 0($s1) #stores the first bit of the string
		beqz $t4, bidfidRowColDone
		# find index of byte in key_square
			move $t2, $s2 # copy of key
			move $a0, $t2
			move $a1, $t4
			jal index_of
			move $a0, $s0
			move $a1, $s1
		move $t2, $v0 # moves the psn to $v0
		li $t0, 9
		div $t2, $t0
		mflo $t2
		add $s4, $s4, $t3
		addi $t2, $t2, 48
		sb $t2, ($s4) # stores the row
		sub $s4, $s4, $t3
		add $s4, $s4, $s6
		mfhi $t2
		addi $t2, $t2, 48		
		sb $t2, ($s4) # stores the col
		sub $s4, $s4, $s6
		addi $s6, $s6, 1
		addi $s1, $s1, 1
		addi $t3, $t3, 1
		j bidfidEncrpytLoop
		# Use blockbuffer -> change $a0 as we go
		# bytecopy $t0 - $t3
	 bidfidRowColDone:
	 	move $s6, $s7
		div $s6, $a3
		li $t6, 0
		mflo $t4
	bidfidRowColDone1:
	#s4 = index buffer
	# Use blockbuffer -> change $a0 as we go
		# bytecopy $t0 - $t3
		beqz $t4, RemLoop
		
		move $a0, $s4 #src
		move $a1,  $t6 #src_pos
		move $a2, $s5	#dest
		li $t0, 0
		move $a3, $t0 #dest_pos
		move $t0, $s3 # period
		addi $sp, $sp, -4
		sw $t0, ($sp)	
			
		jal bytecopy
		
		move $a0, $s0
		move $a1, $s1
		move $a2, $s2
		move $a3, $s3		
	
		addi $sp, $sp, -4
		move $t0, $s3
		sw $t0, ($sp)	
		
		add $t0, $t6, $s7 
		move $a0, $s4 #src
		move $a1, $t0 #src_pos
		move $a2, $s5	#dest
		move $a3, $s3 #dest_pos
		
		jal bytecopy
		
		addi $sp, $sp, 8
		move $a0, $s0
		move $a1, $s1
		move $a2, $s2
		move $a3, $s3		
		
		# s5 is block buffer
		move $t0, $s3
		add $t6, $t6, $s3
		loopForStep3:
			beqz $t0, loopForStep3Done
			lb $t1, ($s5)
			lb $t2, 1($s5)
			addi $t1, $t1, -48
			addi $t2, $t2, -48
			li $t3, 9
			mul $t3, $t3, $t1
			add $t3, $t3, $t2
			li $t5, 0 # counter
			charAt:
				beqz $t3, doneSearching
				addi $t5, $t5, 1
				addi $t3, $t3, -1
				j charAt
			doneSearching:
			move $t7, $s2
			add $t7, $t5, $t7 
			lb $t5, ($t7)
			sb $t5,($a0)
			addi $a0, $a0, 1
			addi $s5, $s5, 2
			addi $t0, $t0, -1
			j loopForStep3
		loopForStep3Done:
		move $s0, $a0
		sub $s5, $s5, $s3
		sub $s5, $s5, $s3
		addi $t4, $t4, -1
		j bidfidRowColDone1
	RemLoop:
		div $s6, $a3
		mfhi $t8
		move $a0, $s4 #src
		move $a1,  $t6 #src_pos
		move $a2, $s5	#dest
		li $t0, 0
		move $a3, $t0 #dest_pos
		move $t0, $t8 # period
		addi $sp, $sp, -4
		sw $t0, ($sp)	
			
		jal bytecopy
		
		move $a0, $s0
		move $a1, $s1
		move $a2, $s2
		move $a3, $t8		
	
		addi $sp, $sp, -4
		move $t0, $s3
		sw $t0, ($sp)	
		
		add $t0, $t6, $s7 
		move $a0, $s4 #src
		move $a1, $t0 #src_pos
		move $a2, $s5	#dest
		move $a3, $t8 #dest_pos
		
		jal bytecopy
		
		addi $sp, $sp, 8
		move $a0, $s0
		move $a1, $s1
		move $a2, $s2
		move $a3, $s3
	mfhi $t0
	RealRemLoop:
		beqz $t0, bidfidEncrpytDone
			lb $t1, ($s5)
			lb $t2, 1($s5)
			addi $t1, $t1, -48
			addi $t2, $t2, -48
			li $t3, 9
			mul $t3, $t3, $t1
			add $t3, $t3, $t2
			li $t5, 0 # counter
			charAt1:
				beqz $t3, doneSearching1
				addi $t5, $t5, 1
				addi $t3, $t3, -1
				j charAt1
			doneSearching1:
			move $t7, $s2
			add $t7, $t5, $t7 
			lb $t5, ($t7)
			sb $t5,($a0)
			addi $a0, $a0, 1
			addi $s5, $s5, 2
			addi $t0, $t0, -1
		j RealRemLoop
		
	bidfidEncrpytDone:
	div $s6, $a3
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
	bidfidEncrpytDone3:
	sb $0, ($a0) # adds a null terminator to the string
	mfhi $t1
	li $t3, 0
	beqz $t1, nothing
	li $t3, 1
	nothing:
	mflo $t2
	add $v0, $t3, $t2
	jr $ra
	
bifid_decrypt:
	li $v0, -1
	blez $a3, bidfidDecryptDone
	
		li $v0, -1
	blez $a3, bidfidEncrpytDone3
	
	lw $t0, ($sp)
	lw $t1, 4($sp)
	addi $sp, $sp, 8
	
	addi $sp, $sp, -36
	sw $s0, ($sp) 
	sw $s1, 4($sp) 
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	sw $ra, 32($sp) 

	move $s0, $a0 #plain text
	move $s1, $a1 # cipher text
	move $s2, $a2 # key_square
	move $s3, $a3 # period
	move $s4, $t0 # index_buffer
	move $s5, $t1 # block_buffer

		# finds the length of the string
		move $a0, $a1
		jal strlen
		move $a0, $s0
		move $s6, $v0 # Length of string
		move $s7, $s6
		
	li $t3, 0 # Counter
	bidfidDecrpytLoop:
		lb $t4, 0($s1) #stores the first bit of the string
		beqz $t4, bidfidRowColDoneDec
		# find index of byte in key_square
			move $t2, $s2 # copy of key
			move $a0, $t2
			move $a1, $t4
			jal index_of
			move $a0, $s0
			move $a1, $s1
		move $t2, $v0 # moves the psn to $v0
		li $t0, 9
		div $t2, $t0
		mflo $t2
		addi $t2, $t2, 48
		sb $t2, ($s4) # stores the row
		mfhi $t2
		addi $t2, $t2, 48		
		sb $t2, 1($s4) # stores the col
		
		addi $s4, $s4, 2
		addi $s1, $s1, 1
		addi $t3, $t3, 2 
		j bidfidDecrpytLoop
	 bidfidRowColDoneDec:
	
	sub $s4, $s4, $s6
	sub $s4, $s4, $s6
	
	move $t9, $s4
	div $s6, $a3
	mflo $t0
	li $t4, 9
	bigLoop:
		beqz $t0, DeDone
		move $t1, $a3
		smallLoop:
			beqz $t1, BacktoBigLoop
				lb $t2, ($t9)
				addi $t2, $t2, -48
				add $t9, $t9, $a3
				lb $t3, ($t9)
				addi $t3, $t3, -48
				sub $t9, $t9, $a3
				mul $t5, $t2, $t4
				add $t5, $t5, $t3
				li $t6, 0 # counter
					charAt2:
						beqz $t5, doneSearching2
						addi $t6, $t6, 1
						addi $t5, $t5, -1
						j charAt2
					doneSearching2:
					move $t7, $s2
					add $t7, $t6, $t7 
					lb $t6, ($t7)
					sb $t6,($a0)
					addi $a0, $a0, 1
					addi $t9, $t9, 1
			addi $t1, $t1, -1
			j smallLoop	
		BacktoBigLoop:
		add $t9, $t9, $a3
		addi $t0, $t0, -1
		j bigLoop
		DeDone:
	mfhi $t0
	
			move $t1, $a3
		smallLoop1:
beqz $t0, DeDone1
				lb $t2, ($t9)
				addi $t2, $t2, -48
				add $t9, $t9, $a3
				lb $t3, ($t9)
				addi $t3, $t3, -48
				sub $t9, $t9, $a3
				mul $t5, $t2, $t4
				add $t5, $t5, $t3
				li $t6, 0 # counter
					charAt21:
						beqz $t5, doneSearching21
						addi $t6, $t6, 1
						addi $t5, $t5, -1
						j charAt21
					doneSearching21:
					move $t7, $s2
					add $t7, $t6, $t7 
					lb $t6, ($t7)
					sb $t6,($a0)
					addi $a0, $a0, 1
					addi $t9, $t9, 1
			addi $t1, $t1, -1
			j smallLoop1	
			
	DeDone1:
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
	bidfidDecryptDone:
	sb $0, ($a0) # adds a null terminator to the string
	jr $ra
	

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
