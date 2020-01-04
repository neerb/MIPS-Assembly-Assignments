# Nathan Breen
# NLB170000
# CS3340.005
#
#
# Homework 5
#
#
# This program reads in a text file containing integers in the form of ASCII characters.
# It reads the integers in as a string, but converts them to integers after being put into a buffer.
# Then the program displays the user the integers in their original order, and then displays them
# in their sorted order after being sorted using a selection sort.
# The program will then display the mean, median, and standard deviation of the integer array.
# After this, the program will exit.
# If the file is empty, the program will notify the user to use a file that is not empty.
# The median is dependent on whether or not the length of the array is odd or even.  If it is
# odd, then it will return an integer, otherwise, it will return a float.


.data
	array: .space 80
	mean: .float 0
	median: .float 0
	medianWord: .word 0
	standardDeviation: .float 0
	newLine: .asciiz "\n"
	spaceCharacter: .asciiz " "
	errorMessage: .asciiz "The file cannot be empty.  Please run the program again."
	arrayBeforeMessage: .asciiz "The array before:  "
	arrayAfterMessage: .asciiz "The array after:   "
	meanMessage: .asciiz "The mean is: "
	medianMessage: .asciiz "The median is: "
	standardDeviationMessage: .asciiz "The standard deviation is: "
	arrayLength: .float 20.0
	
	medianPosOne: .word 0
	medianPosTwo: .word 0
	
	two: .float 2.0
	zero: .float 0.0
	nineteen: .float 19.0
	
	fileName: .asciiz "input.txt"
	buffer: .space 80
.text
	# Load file name and buffer for populating the buffer
	la $a0, fileName
	la $a1, buffer
	jal load_array_from_file	# Populate the buffer
	
	
	# Check if file is empty
	bgt $v0, $zero, continue_main
	li $v0, 4
	la $a0, errorMessage	# Display error message if file is empty
	syscall
	j exit
	
	continue_main:
	
	# Load address of array into $a0, $a1 = 20, and $a2 is the address where the buffer begins
	la $a0, array
	li $a1, 20
	la $a2, buffer
	jal 	convert_string_to_int_array
	
	# Print array before being sorted
	li $v0, 4
	la $a0, arrayBeforeMessage
	syscall
	
	la $a0, array
	li $a1, 20	# load length variable $a1
	jal print_array
	
	
	# Print newline character
	li $v0, 4
	la $a0, newLine
	syscall
	
	
	# Sort array using selection sort
	la $a0, array
	li $a1, 20	# load length variable $a1
	jal selection_sort
	
	# Print array after being sorted
	li $v0, 4
	li $a1, 20	# load length variable $a1
	la $a0, arrayAfterMessage
	syscall
	
	la $a0, array
	li $a1, 20	# load length variable $a1
	jal print_array
	
	
	# Print newline character
	li $v0, 4
	la $a0, newLine
	syscall
	
	
	# Print out mean to user
	la $a0, array
	li $a1, 20	# load length variable $a1
	jal calculate_mean
	
	li $v0, 4
	la $a0, meanMessage
	syscall	# syscall prints meanMessage
	
	s.s $f0, mean	# store mean in memory
	
	li $v0, 2
	l.s $f12, mean
	syscall 
	
	
	# Print newline character
	li $v0, 4
	la $a0, newLine
	syscall
	
	
	# Print out median to user
	la $a0, array
	li $a1, 20	# load length variable $a1
	jal calculate_median
	
	sw $v0, medianWord	# save integer median
	
	li $v0, 4
	la $a0, medianMessage
	syscall	# syscall prints medianMessage
	
	bnez $v1, print_word
	print_float:
	s.s $f0, median	# store median in memory
	
	li $v0, 2
	l.s $f12, median
	syscall 
	j continue_to_sd
	
	print_word:

	lw $a0, medianWord
	li $v0, 1
	syscall
	
	continue_to_sd:
	# Print newline character
	li $v0, 4
	la $a0, newLine
	syscall
	
	
	# Print out standard deviation to user
	la $a0, array
	li $a1, 20	# load length variable $a1
	jal calculate_standard_deviation
	
	li $v0, 4
	la $a0, standardDeviationMessage
	syscall	# syscall prints standardDeviationMessage
	
	s.s $f0, standardDeviation	# store standard deviation in memory
	
	li $v0, 2
	l.s $f12, standardDeviation
	syscall 
	
	# Jump to the exit label of the program and exit safely
	j exit
	

	load_array_from_file:	# returns $v0 = with total bytes read
		move $s1, $a1 # Save buffer address into $s1
	
		# Open file syscall
		li $v0, 13
		la $a0, fileName
		li $a1, 0
		li $a2, 0
		syscall
		
		move $s0, $v0	# save file descriptor
		
		# Read from file syscall
		li $v0, 14
		move $a0, $s0	# move file descriptor from previous syscall into $a0
		move $a1, $s1	# move address of saved buffer into $a1
		li $a2, 80
		syscall
		
		move $s4, $v0	# move number of characters read in to $s4
		
		li $v0, 16
		move $a0, $s0	# move file descriptor from $s0 into $a0
		syscall
		
		# Check if file is empty
		bgt $v0, $zero, returnFunct
		li $v0, 4
		la $a0, errorMessage	# Display error message if file is empty
		syscall
		
		returnFunct:
		move $v0, $s4	# return $v0 - the length of total bytes read in
		jr $ra
		
	convert_string_to_int_array:
		move $s0, $a0	# move address of array into $s0
		move $s1, $a2	# move address of buffer into $s1
		li $t9, 0	# counts total integers read into array
		
		loop:
			lb $t0, ($s1)	# load current byte
			
			blt $t0, 48, ignore
			bgt $t0, 57, ignore
			
			# Convert ascii digit to integer
			subi $t0, $t0, 48
			
			# Temporary value check
			move $t1, $t0
			
			# Get next byte, it may be a double-digit number
			addi $s1, $s1, 1
			
			lb $t0, ($s1)
			
			blt $t0, 48, ignore_but_store
			bgt $t0, 57, ignore_but_store
			j skip_single_digit_store
			
			ignore_but_store:	# ignores next newline, this is used to store single digits in the file
				sw $t1, ($s0)
				addi $s0, $s0, 4
				addi $t9, $t9, 1
				j ignore
			
			skip_single_digit_store:
			# Convert ascii digit to integer
			subi $t0, $t0, 48
			
			mul $t1, $t1, 10
			
			add $t1, $t1, $t0
			
			sw $t1, ($s0)
			
			addi $s0, $s0, 4
			addi $t9, $t9, 1
			ignore:
			addi $s1, $s1, 1
			blt $t9, $a1, loop
			
		jr $ra
		
	selection_sort:	# $a0 contains array address
		li $a1, 20	# max size of array
		li $t0, 0	# save current iterations for outer loop
		li $t1, 0	# save current iterations for inner loop
		
		outer_loop:	# loops until 20
			
			mul $s6, $t0, 4
			add $s6, $a0, $s6
			lw $t6, ($s6)	# get current value
			
			# Store smallest number's address in $s3 and smallest number in $s4
			move $s3, $s6
			move $s4, $t6
			
			move $t1, $t0	# set $t1 to current iteration value
			inner_loop: 	 # loops until 20, finding smallest integer in array
				mul $s7, $t1, 4
				add $s7, $a0, $s7
				lw $t7, ($s7)	# get current value
				
				blt $t7, $s4, save_new_smallest
				j continue_inner
				
				save_new_smallest:
					move $s3, $s7	# save smallest address
					move $s4, $t7	# save smallest number
				
				continue_inner:
				addi $t1, $t1, 1
				blt $t1, $a1, inner_loop
				
			# Swap elements
			sw $t6, ($s3)
			sw $s4, ($s6)
			
			addi $t0, $t0, 1
			blt $t0, $a1, outer_loop
		jr $ra
		
		
	print_array: # $a0 is the array address
		move $s0, $a0	# save array address in $s0
		li $a1, 20
		li $t9, 0
	
		loop_print:
			# Load next array location
			lw $a0, ($s0)
			
			# Print array element
			li $v0, 1
			syscall
			
			# Print a space between each element
			la $a0, spaceCharacter
			li $v0, 4
			syscall
			
			addi $s0, $s0, 4
			addi $t9, $t9, 1
			blt $t9, $a1, loop_print
		jr $ra

	calculate_mean:	# $a0 contains array address, $a1 contains array length, and $f0 returns/contains mean
		li $t0, 0	# $t0 is the summation variable for the mean
		li $t9, 0	# load count variable $t9
		move $s0, $a0 	# $s0 holds copy of array address
	
		loop_sum:
			# Load next array location
			lw $a0, ($s0)
			
			add $t0, $t0, $a0	# add to summation variable
			
			addi $s0, $s0, 4	# point to next location in memory in array
			addi $t9, $t9, 1	# count total elements being read
			blt $t9, $a1, loop_sum
		
		mtc1 $t0, $f0	# move $t0 into $f0
		cvt.s.w $f0, $f0	# convert $f0 into a float
		
		l.s $f1, arrayLength	# load 20.0 into $f1 for division
		
		div.s $f0, $f0, $f1	# divide sum of array by total length
		
		mfc1 $v0, $f0	# return integer $v0
		
		jr $ra
		
	calculate_median:	# $a0 contains array address, $a1 is length of array, and $f0 contains median, $v1 = 1 if int is returned and 0 otherwise
		move $s5, $a1	# save temporary array length value
		
		and $t4, $s5, 1	# check if $s5 is an even number/length
		
		bnez $t4, odd_length
		j even_length
		odd_length:
			move $s0, $a0 	# $s0 holds copy of array address
			div $s5, $s5, 2
			mul $s5, $s5, 4
		
			add $s0, $s0, $s5
	
			lw $t0, ($s0)	# load first number for median
			
			move $v0, $t0
			
			li $v1, 1	# return $v1 as 1 for an int
			j exit_median
	
		even_length:
		move $s0, $a0 	# $s0 holds copy of array address
		
		div $s5, $s5, 2
		mul $s5, $s5, 4
		sub $s5, $s5, 4
		
		add $s0, $s0, $s5
	
		lw $t0, ($s0)	# load first number for median (since it's even there's an extra step)
		
		addi $s0, $s0, 4
		lw $t1, ($s0) 	# load element right next to the first number
		
		mtc1 $t0, $f0	# move $t0 to $f0
		mtc1 $t1, $f1	# move $t1 to $f1
		
		cvt.s.w $f0, $f0	# convert $f0 to float
		cvt.s.w $f1, $f1	# convert $f1 to float
		
		add.s $f0, $f0, $f1	# add two floats together
		
		l.s $f2, two	# load number 2 into $f2 for division below
		
		div.s $f0, $f0, $f2	# divide summation by 2 to get the median	
		
		li $v1, 0	# the number being returned is a float
		
		exit_median:
		jr $ra
		
	calculate_standard_deviation:		# $a0 contains array address, $a1 is length of array, and $f0 contains standard deviation
		move $s0, $a0	# save array address in $s0
		li $t9, 0
		l.s $f8, zero	# $f8 is summation variable
		
		l.s $f0, mean	# f0 contains the mean value from memory
		
		loop_deviation:
			# Load next array location
			lw $a0, ($s0)
			
			mtc1 $a0, $f1
			cvt.s.w $f1, $f1	# $f1 contains current element from memory
			
			sub.s $f1, $f1, $f0	# subtract mean from number
			
			mul.s $f1, $f1, $f1	# square the difference
			
			add.s $f8, $f8, $f1	# add to summation
			
			addi $s0, $s0, 4
			addi $t9, $t9, 1
			blt $t9, $a1, loop_deviation
			
		l.s $f19, nineteen	# load 19.0 into $f19
		
		div.s $f0, $f8, $f19	# sum((rsubi - ravg)^2) / (n - 1)
		
		sqrt.s $f0, $f0	# square root of $f0
			
		mfc1 $v0, $f0	# return integer $v0
			
		jr $ra

	exit:
	# Exit safely
	li $v0, 10
	syscall
