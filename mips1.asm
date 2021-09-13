.data
	goodbye:	.asciiz "\nGoodbye!"
	promptDeg:	.asciiz "Enter a degree amount: "
	newLine:	.asciiz "\n"
	zeroFloat:	.float	0.0
.text

	main:
		
		la $a0, promptDeg
		jal printText
		
		jal getFloat
		
		
		j exit
		
	printFloat:
		# prints the float found in $f0, the argument float
		addi $sp, $sp, -16
		sw $ra, 0($sp)
		swc1 $f2, 4($sp)
		sw $v0, 8($sp)
		swc1 $f12, 12($sp)
		
		# get a float of 0.0
		lwc1 $f2, zeroFloat
		
		# display value
		li $v0, 2
		add.s $f12, $f0, $f2
		syscall
		
		lw $ra, 0($sp)
		lwc1 $f2, 4($sp)
		lw $v0, 8($sp)
		lwc1 $f12, 12($sp)
		addi $sp, $sp, 16
		
		jr $ra

		
		
	getFloat:
		# gets a float from user, returns in $f0
		
		# 8 bc 2*4 due to double
		addi $sp, $sp, -4
		swc1 $f2, 0($sp)
		
		# load a double that is only for zeros
		lwc1 $f2, zeroFloat
		
		# read user input
		li $v0, 6
		syscall
		
		jal printFloat

		lwc1 $f2, 0($sp)
		addi $sp, $sp, 4
		
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
	
		
		