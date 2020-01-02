# Nathan Breen
# ------------
# This program prompts the user for input and then will display to them the
# total number of words and characters within the string they put in.
# It will continue to loop this process until the user has clicked
# cancel in the DialogBox or does not enter any data.

.data
	totalChars: .word 0
	totalWords: .word 0
	
	promptString: .asciiz "Enter some text"
	exitString: .asciiz "Goodbye!"
	thanksString: .asciiz "  Thank you for using this program!"
	wordString: .asciiz " words "
	charString: .asciiz " characters"
	input: .space 64
	
.text
	# Loops until user hits cancel from DialogBox
	while_not_cancel:
	# Prompt user for string input
	li $v0, 54
	la $a0, promptString
	la $a1, input
	li $a2, 64
	syscall
			
	# $t5 temporarily holds DialogBox status value
	move $t5, $a1

	# Load input address into $a0 and call function/subroutine
	la $a0, input
	jal count_chars_and_nums
	
	# Exit if no data was entered into DialogBox
	beq $t5, -3, exit
	
	# Store returned data into variable
	sw $v0, totalChars
	sw $v1, totalWords 
	
	bne $t5, 0, check_loop	# used to skip display if they user has already cancelled
	# Call to display data (after execution of function call)
	jal display_data
	
	check_loop:
	bne $t5, -2, while_not_cancel
			
	# Call to properly exit program
	j exit

	
	
	# Function begin **************************************************************************************
	# Store string address in $a0, returns $v0 = number of characters and $v1 = number of words in string
	count_chars_and_nums:
		# store current position of string, also reset return registers
		move $t1, $a0 # t1 holds temporary address
		li $v0, 0
		li $v1, 0
		li $s1, 0
		li $t3, 0 # $t3 holds total spaces - chance to $s0 later
	
	loop:
		# while current character != null-terminator
		lb $t9, 0($t1)
		beqz $t9, done
		addi $t1, $t1, 1
		addi $s1, $s1, 1
	
		# Check for space character
		bne $t9, ' ', skip
		addi $v1, $v1, 1	# Add one to $v1 (total spaces)
		skip: 
		j loop
		
		done:
		# Store $s1 on top of stack
		addi $sp, $sp, -4
		sw $s1, ($sp)
		
		# Load value on top of stack($s1) into $s1
		lw $s1, ($sp)
		
		# Pop $s1 from stack
		addi $sp, $sp, 4
		
		# Move value from $s1 into $v0
		add $v0, $s1, $zero
		
		addi $v0, $v0, -1	# Subtract one from string length (disregards null-terminator)
		addi $v1, $v1, 1	# Add one to total spaces: in turn calculating total words
		jr $ra	# Return to call address
	# Function end ************************************************************************
	
	
	
	# This function displays all the data for the program (total chars and total words)
	display_data:
	
	# Load data into registers
	lw $t0, totalChars
	lw $t1, totalWords
	
	# Display data to user
	li $v0, 4
	la $a0, input
	syscall
	
	# Display total words
	li $v0, 1
	move $a0, $t1
	syscall
	
	# Display word description string
	li $v0, 4
	la $a0, wordString
	syscall
	
	# Display total characters
	li $v0, 1
	move $a0, $t0
	syscall
	
	# Display charString
	la $a0, charString
	li $v0, 4
	syscall
	
	# Create new line for next call, print one character syscall
	li $a0, 0xA
	li $v0, 11
	syscall
	
	# Return to caller
	jr $ra


	exit:
	# Goodbye message to user
	li $v0, 59
	la $a0, exitString
	la $a1, thanksString
	syscall
	
	# Properly exiting program
	li $v0, 10
	syscall
