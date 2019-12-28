# Nathan Breen - Homework Assignment 1
# CS3340: Professor Mazidi

.data
	# Input values
	a: .word 0
	b: .word 0
	c: .word 0
	
	# Output values
	ans1: .word 0
	ans2: .word 0
	ans3: .word 0
	
	# Variable for user's name
	name: .space 20
	
	# Message variables
	namePrompt: .asciiz "What is your name? "
	integerPrompt: .asciiz "Please enter an integer between 1-100: "
	resultsNotification: .asciiz "your answers are: "
	space: .asciiz " "
.text
	# Prompt for user's name
	la $a0, namePrompt
	li $v0, 4
	syscall
	
	# Obtain user input
	li $v0, 8
	la $a0, name
	li $a1, 20
	syscall
	
	# Prompt for first integer(a)
	la $a0, integerPrompt
	li $v0, 4
	syscall
	
	# Obtain input for first integer(a)
	li $v0, 5
	syscall
	
	# Store new input value
	sw $v0, a
	
	# Prompt for first integer(b)
	la $a0, integerPrompt
	li $v0, 4
	syscall
	
	# Obtain input for second integer(b)
	li $v0, 5
	syscall
	
	# Store new input value
	sw $v0, b
	
	# Prompt for first integer(c)
	la $a0, integerPrompt
	li $v0, 4
	syscall
	
	# Obtain input for third integer(c)
	li $v0, 5
	syscall
	
	# Store new input value
	sw $v0, c
	
	# Load three variables into registers for calulations
	# $t0, $t1, and $t2 correspond to a, b, and c respectively
	lw $t0, a
	lw $t1, b
	lw $t2, c
	
	# Calculation of 2a - b + 9
	add $t4, $t0, $t0
	sub $t4, $t4, $t1
	add $t4, $t4, 9
	
	# Store calcuation back into ans1
	sw $t4, ans1
	
	# Zero out calculation register
	li $t4, 0
	
	# Calculation of c - b + (a - 5)
	sub $t4, $t2, $t1
	add $t4, $t4, $t0
	sub $t4, $t4, 5
	
	# Store calculation in ans2
	sw $t4, ans2
	
	# Zero out calculation register
	li $t4, 0
	
	# Calculation of (a - 3) + (b + 4) - (c + 7)
	sub $t4, $t0, 3
	add $t4, $t4, $t1
	add $t4, $t4, 4
	add $t5, $t2, 7
	sub $t4, $t4, $t5
	
	# Store calculation in ans3
	sw $t4, ans3
	
	# Zero out calculation register
	li $t4, 0
	
	# Display user's name back to them
	la $a0, name
	li $v0, 4
	syscall
	
	# Display answers to user
	la $a0, resultsNotification
	li $v0, 4
	syscall
	
	# Display answer 1
	lw $a0, ans1
	li $v0, 1
	syscall
	
	# Display space character
	la $a0, space
	li $v0, 4
	syscall
	
	# Display answer 2
	lw $a0, ans2
	li $v0, 1
	syscall
	
	# Display space character
	la $a0, space
	li $v0, 4
	syscall
	
	# Display answer 3
	lw $a0, ans3
	li $v0, 1
	syscall
	
	
	# Exit the program
	li $v0, 10
	syscall
	
	
# a, b, and c test values

# Test case 1
# a = 10
# b = 20
# c = 30
# ans1 = 9
# ans2 = 15
# ans3 = -6

# Test case 2
# a = 2
# b = -4
# c = 8
# ans1 = 17
# ans2 = 9
# ans3 = -16

# Test case 3
# a = 29
# b = 31
# c = 17
# ans1 = 36
# ans2 = 10
# ans3 = 37

# Test case 4
# a = 1000
# b = 100
# c = 10
# ans1 = 1909
# ans2 = 905
# ans3 = 1084

# Test case 5
# a = 3
# b = 3
# c = -3
# ans1 = 12
# ans2 = -8
# ans3 = 3

