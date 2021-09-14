.data
	welcome:	.asciiz "Welcome!\n"
	instructions:	.asciiz "0: Sine(x)\n1: Cosine(x)\n2: e^x\n3: ln(x)\n-1: quit\n"
	goodbye:	.asciiz "\nGoodbye!"
	degPrompt:	.asciiz "Enter a degree amount:\n"
	radConversion:	.asciiz "In radians, this is: "
	newLine:	.asciiz "\n"
	
	sinePrompt:	.asciiz "Welcome to sine\n"
	cosinePrompt:	.asciiz "Welcome to cosine\n"
	ePrompt:	.asciiz "Welcome to e\n"
	lnPrompt:	.asciiz "Welcome to ln\n"
	
	zeroDouble:	.double	0.0
	piDouble: 	.double 3.1415927
	oneEightyDouble: .double 180.0
.text

	main:	la $a0, welcome
		jal printText
		while:
		
			la $a0, instructions
			jal printText
		
			jal getInt
		
			# check the value returned in $v0
			li $t0, 0
			beq $t0, $v0, handleSine
			
			li $t0, 1
			beq $t0, $v0, handleCosine
			
			li $t0, 2
			beq $t0, $v0, handleE
			
			li $t0, 3
			beq $t0, $v0, handleLn
		
			li $t0, -1
			beq $t0, $v0, exit
		
			j while
		endoperation:
			j while
	
	getDegree:
		# returns the degree amount in $f0
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		la $a0, degPrompt
		jal printText
		
		# get double in $f0
		jal getDouble
		
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra
		
	convertDegRad:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		la $a0, radConversion
		jal printText
		
		# NOTE: PUSH TO STACK
		ldc1 $f10, piDouble
		# rad = (pi/180)*deg
		
		# pi * deg
		mul.d $f0, $f0, $f10
		
		ldc1 $f10, oneEightyDouble
		# 1/180
		
		li $v0, 3
		ldc1 $f10, zeroDouble
		add.d $f12, $f0, $f10
		syscall
		
		jal printNewLine
		
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra
		
	handleSine:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		la $a0, sinePrompt
		jal printText
		# get the degree in $f0
		jal getDegree
		# convert $f0 degree into radians
		jal convertDegRad
		
		lw $ra, 0($sp)
		addi $sp,$sp, 4
		
		j endoperation
			
	handleLn:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		la $a0, lnPrompt
		jal printText
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		j endoperation
			
	handleE:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		la $a0, ePrompt
		jal printText
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		j endoperation
			
	handleCosine:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		la $a0, cosinePrompt
		jal printText
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		j endoperation
		
	
	getInt:
		# get the int,  store in $v0 
		li $v0, 5
		syscall
		
		jr $ra
		
	getDouble:
		# returns a double in $f0
	
		# get the double, store in $f0
		li $v0, 7
		syscall
		
		jr $ra
		
	printText:
		# Shows the text passed into $a0.
		addi $sp, $sp, -4
		sw $v0, 0($sp)
		
		# Display "Enter a degree amount"
		li $v0, 4
		syscall
	
		lw $v0, 0($sp)
		addi $sp, $sp 4
		
		jr $ra
		
	printNewLine:
		# prints new line character
		addi $sp, $sp, -8
		sw $ra, 0($sp)
		sw $a0, 4($sp)
		
		la $a0, newLine
		jal printText
		
		lw $ra, 0($sp)
		lw $a0, 4($sp)
		addi $sp, $sp, 8
		jr $ra
	
	# end the prog
	exit:
		la $a0, goodbye
		jal printText
		
	li $v0, 10
	syscall
	
		
		
