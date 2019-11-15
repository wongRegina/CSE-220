# Regina Wong
# REWONG	
# 112329774

.data
# Command-line arguments
num_args: .word 0
addr_arg0: .word 0
addr_arg1: .word 0
no_args: .asciiz "You must provide at least one command-line argument.\n"

# Error messages
invalid_operation_error: .asciiz "INVALID_OPERATION\n"
invalid_args_error: .asciiz "INVALID_ARGS\n"

# Output strings
royal_flush_str: .asciiz "ROYAL_FLUSH\n"
straight_flush_str: .asciiz "STRAIGHT_FLUSH\n"
four_of_a_kind_str: .asciiz "FOUR_OF_A_KIND\n"
full_house_str: .asciiz "FULL_HOUSE\n"
simple_flush_str: .asciiz "SIMPLE_FLUSH\n"
simple_straight_str: .asciiz "SIMPLE_STRAIGHT\n"
high_card_str: .asciiz "HIGH_CARD\n"

zero_str: .asciiz "ZERO\n"
neg_infinity_str: .asciiz "-INF\n"
pos_infinity_str: .asciiz "+INF\n"
NaN_str: .asciiz "NAN\n"
floating_point_str: .asciiz "_2*2^"

# Put your additional .data declarations here, if any.


# Main program starts here
.text
.globl main
main:
    # Do not modify any of the code before the label named "start_coding_here"
    # Begin: save command-line arguments to main memory
    sw $a0, num_args
    beqz $a0, zero_args
    li $t0, 1
    beq $a0, $t0, one_arg
two_args:
    lw $t0, 4($a1)
    sw $t0, addr_arg1
one_arg:
    lw $t0, 0($a1)
    sw $t0, addr_arg0
    j start_coding_here
zero_args:
    la $a0, no_args
    li $v0, 4
    syscall
    j exit
    # End: save command-line arguments to main memory

start_coding_here:
    # Start the assignment by writing your code here
		lw $t0, num_args
		lw $t1, addr_arg0 # address of the first argument
		check: #Checks if the first argument is only one letter
			lbu $t3, 1($t1) # The second letter of the first argument, if it is empty then it should be 0
			bnez $t3, partOneInvalid # See if the value is 0, if it is isn't 0 it would jump to valid, else the 
			
			lbu $t2, ($t1) # The first letter of the first argument
 			li $t3 , 'F'
 				beq $t2, $t3, caseF
 			li $t3 , 'M'
 				beq $t2, $t3, caseM
 			li $t3 , 'P'
 				beq $t2, $t3, caseP
			j partOneInvalid
		partOneInvalid: # Print out the error message if there is an operation error
			la $a0, invalid_operation_error
 			li $v0, 4
 			syscall
 			j exit
 		partTwoInvalid: # Print out the error message if there is an argument error
 			la $a0, invalid_args_error
 			li $v0, 4
 			syscall
 			j exit 			
 		
 		caseF: #Interpret a String of Four Hexadecimal Digits as a 16-bit Floating-point Number
 			li $t2, 2
 			bne $t0, $t2, partTwoInvalid # Checks if there are two argument
 			lw $t2 , addr_arg1 # The address of the second argument
 			li $t6 , 0 # it would store the decimal value of the hexadecimal value
 			li $t7, 16 # The base of the hexadecimal value	
 			li $t4, 0 # Counter
 			li $t5, 4 # max
 			checkIfHexThenDecimal:
 				beq $t5, $t4, validDecimal
 				mul $t6,$t6, $t7 #multiply the the current value to the base
 				lbu $t3, 0($t2) # stores the value of the digit into $t3
 				li $t1, 48 # the lower bound if the value is between 0 and 9(ASCII)
 				blt $t3, $t1, partTwoInvalid
 				numberRange:
 					li $t1, 57 # The upper bound if the value is between 0 and 9(ASCII)
 					bgt $t3, $t1, letterRange
 						addi $t3, $t3, -48
 						j validHex
 				letterRange:
 					li $t1, 65 # The lower bound if the value is between A and F(ASCII)
 					blt $t3, $t1, partTwoInvalid
 					li $t1, 70 # The upper bound if the value is between A and F(ASCII)
 					bgt $t3, $t1, partTwoInvalid
 						addi $t3, $t3, -55
  						j validHex
				validHex: 	
					add $t6,$t3,$t6 # add the value in that base to the current value
 					addi $t4, $t4,1 # increment the counter
 					addi $t2,$t2,1 # increment the address
 				j checkIfHexThenDecimal
 			validDecimal:
 				andi  $t1, $t6, 0x8000 # The sign  bit
 				srl $t1, $t1 ,15
 				andi $t2, $t6, 0x7C00 # The bits of the exponents
 				srl $t2,$t2, 10
 				andi $t3, $t3, 0xCFF # The bits for mantissa			
 			CheckingValues:
 				li $t4, 0x1F
 				bne $t2, $t4, realNumber # Checks if exponent is all ones, if it is all one, it is not a real number
 					bgtz $t3, notANumber #Checks if the exponent is greater than zero, if it is to goes to not a number to print NaN
 						beqz $t1, posInf
 							la $a0, neg_infinity_str
 							li $v0,4
 							syscall
 							j exit 
 						posInf:
 							la $a0, pos_infinity_str
 							li $v0,4
 							syscall
 							j exit 
 					notANumber: # Prints out NaN
 						la $a0, NaN_str
 						li $v0,4
 						syscall
 						j exit 				
 				realNumber:
 					bnez $t3, non_Zero # If the mantissa is zero, then  it would check if the exponent is a zero
 					bnez $t2, non_Zero # If the exponent is also zero, then it would print a zero, else it would go to a non-zero code
 						la $a0, zero_str # Printing the string stating if it is zero
 						li $v0,4
 						syscall
 						j exit 
 					non_Zero:
 						bnez $t1, negative		# see if the value in negativ
						j signBitDone
 						negative:
							li $a0 , '-'
 							li $v0, 11
							syscall			
 						signBitDone:
 							li $a0 , '1'
 							li $v0, 11
							syscall
							li $a0 , '.'
 							li $v0, 11
							syscall	
					li $t1, 0x400
							li $a0 , '\n'
							li $v0, 11
							syscall
							move $a0 , $t3
							li $v0, 1
							syscall
							li $a0 , '\n'
							li $v0, 11
							syscall
					printingFractions: # it ands throught the fraction bits to see if it a one or a zero
						li $t4, 1
						beq  $t1,  $t4,donePrintingFraction
						and $t4, $t1, $t3
						beqz $t4, zero
							li $a0 , '0' 
							li $v0, 11
							syscall
							j printNum
						zero:
							li $a0 , 1
							li $v0, 1
							syscall
						printNum:
						srl $t1,$t1,1
						j printingFractions 
					donePrintingFraction:
						la $a0, floating_point_str # Prints the floating point string 
 						li $v0, 4
 						syscall
 						addi $t2, $t2, -15 # Subtracts 15 from the exponent value 
 						move $a0,$t2 # Prints the exponent
 						li $v0, 1
 						syscall
 						li $a0, '\n'
 						li $v0, 11
 						syscall
 			j exit
 	
 		caseM: #Interpret a String of Eight Hexadecimal Digits as a MIPS R-type Instruction
 			li $t2, 2
 			bne $t0, $t2, partTwoInvalid  # Checks if there are two argument
 			lw $t2 , addr_arg1 # The address of the second argument
 			li $t6 , 0 # it would store the decimal value of the hexadecimal value
 			li $t7, 16 # The base of the hexadecimal value		
 			li $t4, 0 # Counter
 			li $t5, 8 # max
 			hexToDec:
 				beq $t5, $t4, finishDec # checks if it is done converting from hex to decimal
 				mul $t6,$t6, $t7 #multiply the the current value to the base
 				lbu $t3, 0($t2) # stores the value of the digit into $t3
 				li $t8, 58 # The max bound if the value is a hex in decimal
 				ble $t3,$t8, number # see if the digit is less than 58 to see 
 				letter: # if the value is a letter it would take away 55 to get the value in decimal
 					addi $t3, $t3, -55
  					j continue
 				number: # if the value is a number, it would take away 48 to get the vaule in decimal
 					addi $t3, $t3, -48
 					j continue
 				continue: 
					add $t6,$t3,$t6 # add the value in that base to the current value
 					addi $t4, $t4,1 # increment the counter
 				addi $t2,$t2,1 # increment the address
 				j hexToDec
 			finishDec:
 			
 			seperatesIntoRTypeInstruction:
 				li $t4, 0xFC000000 # The next 3 lines make sure that the opcode is 0, else it would jump to the invalid argument
 				and $t5 , $t4, $t6
 				bne $t5, $zero, partTwoInvalid 
 					move $a0, $t5 # Prints the integer in decimal 
 					li $v0 ,1
 					syscall 
 					li $a0 , ' '
 					li $v0, 11
 					syscall
 				li $t4, 0x3E00000 # The value that would allow you to get the 5 binary digit next to the opcode
 				groupsOfFive:
 					and $t5 , $t4, $t6 # The number for rs
 					srl $t5, $t5, 21 # shifts the values so that there are no unecessay zeros in front
 						move $a0, $t5 # Prints the integer in decimal
 						li $v0 ,1
 						syscall 
 						li $a0 , ' '
 						li $v0, 11
 						syscall	
 					srl $t4, $t4, 5
					
					and $t5 , $t4, $t6 #The number for rt
 					srl $t5, $t5, 16 # shifts the values so that there are no unecessay zeros in front
 						move $a0, $t5 # Prints the integer in decimal
 						li $v0 ,1
 						syscall 
 						li $a0 , ' ' # Prints a space
 						li $v0, 11
 						syscall	
 					srl $t4, $t4, 5
 					
 					and $t5 , $t4, $t6 # The number for rd
 					srl $t5, $t5, 11 # shifts the values so that there are no unecessay zeros in front
 						move $a0, $t5
 						li $v0 ,1
 						syscall 
 						li $a0 , ' '
 						li $v0, 11
 						syscall	
 					srl $t4, $t4, 5
 					
 					and $t5 , $t4, $t6 #The number for shamt(shift)
 					srl $t5, $t5, 6 # shifts the values so that there are no unecessay zeros in front
 						move $a0, $t5 # Prints the integer in decimal
 						li $v0 ,1
 						syscall 
 						li $a0 , ' ' # Prints a space
 						li $v0, 11
 						syscall	
 					srl $t4, $t4, 5
 				FinishGroupOfFives:
 					li $t4, 0x3F 
 					and $t5 , $t4, $t6 #The number for the function
 						move $a0, $t5 # Prints the integer in decimal
 						li $v0 ,1
 						syscall 
 						li $a0 , ' ' # Prints a space
 						li $v0, 11
 						syscall	
 			finishSeperatingIntoRTypeInstruction:
 			j exit
 			
 		caseP: #Identify a Five-card Hand from Draw Poker
 			li $t2, 2
 			bne $t0, $t2, partTwoInvalid  # Checks if there are two argument
			lw $t0 , addr_arg1 # The address of the second argument
			li $t1, 0 #counter
			li $t2, 10 # max for the loop
			li $t5, 0 # the number of spades in the hand
			li $t6, 0 # the number of clubs in the hand
			li $t7, 0 # the number of hearts in the hand
			checkifStringIsValid:
				beq $t1, $t2, endOfLoop
				andi $t3, $t1, 1
				li $t4, 0
				beq  $t3, $t4, valueOfCard # sees if the position of the value or a suit
				suitOfCard:
					lbu $t3, 0($t0) # gets a character of the string
					li $t4, 67
					bne $t3, $t4, not67 # checks if the suit is a club
					addi $t6, $t6, 1
					j valueIsValid
					not67:
						li $t4, 68
						bne $t3, $t4, not68 # checks if the suit is a diamond
						j valueIsValid
					not68:
						li $t4, 72
						bne $t3, $t4, not72 # checks if the suit is a heart
						addi $t7, $t7, 1
						j valueIsValid
					not72:
						li $t4, 83
						bne $t3, $t4, partTwoInvalid # checks if the suit is a spade
						addi $t5, $t5, 1
						j valueIsValid
				valueOfCard:
					lbu $t3, 0($t0) # gets a character of the string
					li $t4, 50
					blt $t3, $t4, partTwoInvalid
					li $t4, 58
					bge  $t3, $t4, notANum
					j valueIsValid
					notANum:
						li $t4, 65
						bne $t3, $t4, notA
						j valueIsValid
						notA:
							li $t4, 74
							bne $t3, $t4, notJ
							j valueIsValid
						notJ:
							li $t4, 81
							bne $t3, $t4, notQ
							j valueIsValid
						notQ:
							li $t4, 75
							bne $t3, $t4, notK
							j valueIsValid
						notK:
							li $t4, 84
							bne $t3,$t4, partTwoInvalid
			valueIsValid:
				addi $t0,$t0, 1
				addi $t1,$t1, 1
				j checkifStringIsValid
			endOfLoop:
			
			li $t1, 0
			bne $t5, $t1, checkIf5
			bne $t6, $t1, checkIf5
			bne $t7, $t1, checkIf5
			li $s0, 1
			j suitchecked
			checkIf5:
				li $t1, 5
				bne $t5, $t1, next1
				li $s0, 1
				j suitchecked
				next1: 
				bne $t6, $t1, next2
				li $s0, 1
				j suitchecked
				next2:
				bne $t7, $t1, suitchecked
				li $s0, 1
			suitchecked:
						
			lw $t0 , addr_arg1 # The address of the second argument
			
			#Makes the value of the so the letters are comparable
			lbu $t1, 0($t0) # The value of the first card
				li $t6, 58
				bgt $t1, $t6, naN
				j else
				naN:
						li $t6, 84
						bne $t1, $t6, notT
						li $t1, 58
						j else
					notT:
						li $t6, 74
						bne $t1, $t6, notJ1
						li $t1, 59
						j else
					notJ1:
						li $t6, 81
						bne $t1, $t6, notQ1
						li $t1, 60
						j else
					notQ1:
						li $t6, 75
						bne $t1, $t6, notK1
						li $t1, 61
						j else	
					notK1:
						li $t1, 62			
				else: 
			addi $t0, $t0, 2
			lbu $t2, 0($t0) # The value of the second card
				li $t6, 58
				bgt $t2, $t6, naNum
				j else2
				naNum:
						li $t6, 84
						bne $t2, $t6, notT2
						li $t2, 58
						j else2
					notT2:
						li $t6, 74
						bne $t2, $t6,notJ2
						li $t2, 59
						j else2
					notJ2:
						li $t6, 81
						bne $t2, $t6, notQ2
						li $t2, 60
						j else2
					notQ2:
						li $t6, 75
						bne $t2, $t6, notK2
						li $t2, 61
						j else2	
					notK2:
						li $t2, 62				
				else2: 
			addi $t0, $t0, 2
			lbu $t3, 0($t0) # The value of the thrid card
			li $t6, 58
				bgt $t3, $t6, naN3
				j else3
				naN3:
						li $t6, 84
						bne $t3, $t6, notT3
						li $t3, 58
						j else3
					notT3:
						li $t6, 74
						bne $t3, $t6, notJ3
						li $t3, 59
						j else3
					notJ3:
						li $t6, 81
						bne $t3, $t6, notQ3
						li $t3, 60
						j else3
					notQ3:
						li $t6, 75
						bne $t3, $t6, notK3
						li $t3, 61
						j else3	
					notK3:
						li $t3, 62			
				else3: 
			addi $t0, $t0, 2
			lbu $t4, 0($t0) # The value of the fourth card
				li $t6, 58
				bgt $t4, $t6, naN4
				j else4
				naN4:
						li $t6, 84
						bne $t4, $t6, notT4
						li $t4, 58
						j else4
					notT4:
						li $t6, 74
						bne $t4, $t6, notJ4
						li $t4, 59
						j else4
					notJ4:
						li $t6, 81
						bne $t4, $t6, notQ4
						li $t4, 60
						j else4
					notQ4:
						li $t6, 75
						bne $t4, $t6, notK4
						li $t4, 61
						j else4
					notK4:
						li $t4, 62				
				else4: 
			addi $t0, $t0, 2
			lbu $t5, 0($t0) # The value of the fifth card
				li $t6, 58
				bgt $t5, $t6, naN5
				j else5
				naN5:
						li $t6, 84
						bne $t5, $t6, notT5
						li $t5, 58
						j else5
					notT5:
						li $t6, 74
						bne $t5, $t6, notJ5
						li $t5, 59
						j else5
					notJ5:
						li $t6, 81
						bne $t5, $t6, notQ5
						li $t5, 60
						j else5
					notQ5:
						li $t6, 75
						bne $t5, $t6, notK5
						li $t5, 61
						j else5	
					notK5:
						li $t5, 62			
				else5: 
				
		beginningOfSorting: # bubble sort
				ble $t1, $t2, twoThree
				move $t6, $t2
				move $t2, $t1
				move $t1, $t6
			twoThree:
				ble $t2, $t3, threeFour
				move $t6, $t3
				move $t3, $t2
				move $t2, $t6
				j beginningOfSorting
			threeFour:
				ble $t3, $t4,  fourFive
				move $t6, $t4
				move $t4, $t3
				move $t3, $t6
				j beginningOfSorting
			 fourFive:
				ble $t4, $t5, sorted
				move $t6, $t5
				move $t5, $t4
				move $t4, $t6
				j beginningOfSorting
		sorted:
		
		li $t6, 1
		beq $t6, $s0, sameSuit
			checkIfFourOfAKind:
				bne $t2, $t3, checkIfFullHouse
				bne $t3, $t4, checkIfFullHouse
				bne $t1, $t2, notTheSameAsFirst
				j printFourOfAKind
				notTheSameAsFirst:
					bne $t4, $t5, notTheSameAsFirst
				printFourOfAKind:
					la $a0, four_of_a_kind_str
 					li $v0,4
 					syscall
 					j exit
			checkIfFullHouse:
				bne $t1, $t2, checkIfSimpleStraight
				bne $t4, $t5, checkIfSimpleStraight
				bne $t2, $t3, tripleNotFirst
				tripleNotFirst:
					bne $t3, $t4, checkIfSimpleStraight
						la $a0, full_house_str
 						li $v0,4
 						syscall
 						j exit
			checkIfSimpleStraight:
			 	addi $t6, $t1, 1
			 	bne $t2, $t6, nothingSpecial
			 	addi $t6, $t2, 1
			 	bne $t3, $t6, nothingSpecial
			 	addi $t6, $t3, 1
			 	bne $t4, $t6, nothingSpecial
			 	addi $t6, $t4, 1
			 	bne $t5, $t6, nothingSpecial
			 		la $a0, simple_straight_str
 					li $v0,4
 					syscall
 					j exit
		sameSuit:
			checkIfRoyalFlush:
				li $t6, 58 # The value that I store J as
				bne $t1, $t6, checkIfStraightFlush
				addi $t6, $t6, 1
				bne $t2, $t6, checkIfFlush
				addi $t6, $t6, 1
				bne $t3, $t6, checkIfFlush
				addi $t6, $t6, 1
				bne $t4, $t6, checkIfFlush
				addi $t6, $t6, 1
				bne $t5, $t6, checkIfFlush
					la $a0, royal_flush_str
 					li $v0,4
 					syscall
 					j exit
			checkIfStraightFlush:
				addi $t6, $t1, 1
				bne $t2, $t6, checkIfFourOfAKind1
				addi $t6, $t6, 1
				bne $t3, $t6, checkIfFourOfAKind1
				addi $t6, $t6, 1
				bne $t4, $t6, checkIfFourOfAKind1
				addi $t6, $t6, 1
				bne $t5, $t6, checkIfFourOfAKind1
					la $a0, straight_flush_str
 					li $v0,4
 					syscall
 					j exit
 			checkIfFourOfAKind1:
				bne $t2, $t3, checkIfFullHouse1
				bne $t3, $t4, checkIfFullHouse1
				bne $t1, $t2, notTheSameAsFirst1
				j printFourOfAKind1
				notTheSameAsFirst1:
					bne $t4, $t5, notTheSameAsFirst1
				printFourOfAKind1:
					la $a0, four_of_a_kind_str
 					li $v0,4
 					syscall
 					j exit
			checkIfFullHouse1:
				bne $t1, $t2, checkIfFlush
				bne $t4, $t5, checkIfFlush
				bne $t2, $t3, tripleNotFirst1
				tripleNotFirst1:
					bne $t3, $t4, checkIfFlush
						la $a0, full_house_str
 						li $v0,4
 						syscall
 						j exit
			checkIfFlush:
				la $a0, simple_flush_str
 				li $v0,4
 				syscall
 				j exit
		nothingSpecial:	
			la $a0, high_card_str
 			li $v0,4
 			syscall
 			j exit
exit:
    li $v0, 10   # terminate program
    syscall
