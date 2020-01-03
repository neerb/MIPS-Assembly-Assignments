# Nathan Breen
# Homework 3
# CS3340.005
#
#
# This program will prompt the user for their name, height, and weight.
# It will then display back to them their name and BMI.
# Likewise, it will tell them whether they are underweight, normal weight, overweight, or obese.


.data
	height: .word 0
	weight: .word 0
	bmi: .float 0
	multiplier: .float 703.0
	compare1: .float 18.5
	compare2: .float 25.0
	compare3: .float 30.0
	
	getNamePrompt: .asciiz "What is your name? "
	getHeightPrompt: .asciiz "Please enter your height in inches: "
	getWeightPrompt: .asciiz "Now enter your weight in pounds (round to a whole number): "
	outputNameandBMI: .asciiz ", your bmi is: "
	
	underweight: .asciiz "This is considered underweight."
	normalweight: .asciiz "This is a normal weight."
	overweight: .asciiz "This is considered overweight"
	obeseweight: .asciiz "This is considered obese."
	
	newline: .asciiz "\n"
	
	.align 4
	name: .space 64
	
.text
	# Prompt user for their name
	li $v0, 4
	la $a0, getNamePrompt
	syscall

	# Get user's name
	li $v0, 8
	la $a0, name
	li $a1, 64
	syscall
	
	# Remove newline character from name
	li $t0, 0
	loop:
		lb $a3, name($t0)
		addi $t0, $t0, 1
		bnez $a3, loop
	
	subiu $t0, $t0, 2
	sb $zero, name($t0)
	
	# Prompt user for their height in inches
	li $v0, 4
	la $a0, getHeightPrompt
	syscall
	
	# Get user's height in inches
	li $v0, 5
	syscall
	# Store user's height
	sw $v0, height
	
	
	# Prompt user for their weight in pounds
	li $v0, 4
	la $a0, getWeightPrompt
	syscall
	
	# Get uer's weight in pounds
	li $v0, 5
	syscall
	# Store user's weight
	sw $v0, weight
	
	
	# Load height into $t0 and weight into $t1
	lw $t0, height
	lw $t1, weight	
	
	# Convert $t0 and $t1 to floating point precision
	mtc1 $t0, $f0
	cvt.s.w $f0, $f0
	
	mtc1 $t1, $f1
	cvt.s.w $f1, $f1
	
	
	# Calculate BMI
	l.s $f8, multiplier	#Store immediate in $f8
	mul.s $f1, $f1, $f8	# Multiply weight by 703
	mul.s $f0, $f0, $f0	# Square height
	
	# Store bmi in $f2
	div.s $f2, $f1, $f0
	
	# Store bmi in variable
	s.s $f2, bmi
	
	# Print user's name entered earlier
	li $v0, 4
	la $a0, name
	syscall
	
	# Print following text to user
	li $v0, 4
	la $a0, outputNameandBMI
	syscall
	
	# Print BMI to user
	li $v0, 2
	l.s $f12, bmi
	syscall 
	
	# Print new line
	li $v0, 4
	la $a0, newline
	syscall
	
	
	# Load comparison values
	l.s $f10, compare1
	l.s $f11, compare2
	l.s $f12, compare3
	
	# Display to user what BMI area they are in
	c.lt.s $f2, $f10	# If BMI is less than 18.5
	bc1t else_if_1
	
	c.lt.s $f2, $f11	# Else If BMI is less than 25
	bc1t else_if_2
	
	c.lt.s $f2, $f12	# Else if BMI is less than 30
	bc1t else_if_3
	
	j else	# Else
	
	
	else_if_1:
		# BMI is underweight
		li $v0, 4
		la $a0, underweight
		syscall
		j exit
		
	else_if_2:
		# BMI is normal weight
		li $v0, 4
		la $a0, normalweight
		syscall
		j exit
		
	else_if_3:
		# BMI is over weight
		li $v0, 4
		la $a0, overweight
		syscall
		j exit
		
	else:
		# BMI is obese
		li $v0, 4
		la $a0, obeseweight
		syscall
		j exit
	
	exit:
	# Exit program
	li $v0, 10
	syscall
