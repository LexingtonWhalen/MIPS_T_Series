# Written (with love) by Lex Whalen, 09/25/21
# A program to calculate sine, cosine, e^x, x!, x^n.
# All in MIPS!

.data
	welcome:	.asciiz "Welcome!\n"
	instructions:	.asciiz "0: Sine(x)\n1: Cosine(x)\n2: e^x\n3: Factorial(x)\n4: Exponential(x)\n-1: quit\n"
	goodbye:	.asciiz "\nGoodbye!"
	radConversion:	.asciiz "In radians, this is: "
	newLine:	.asciiz "\n"
	
	degPrompt:	.asciiz "Enter a degree amount:\n"
	sinePrompt:	.asciiz "Welcome to sine.\n"
	cosinePrompt:	.asciiz "Welcome to cosine.\n"
	ePrompt:	.asciiz "Welcome to e^x.\n"
	factPrompt:	.asciiz "Enter an integer for the factorial: "
	expPrompt:	.asciiz "This function returns x^n.\n"
	getXPrompt:	.asciiz "Enter a double for x: "
	getNPrompt:	.asciiz "Enter an integer for n: "
	
	factOutput:	.asciiz "The factorial is: "
	sineOutput:	.asciiz "The sine is: "
	cosineOutput:	.asciiz "The cosine is: "
	exponentiationOutput:	.asciiz "The exponentiation is: "
	eOutput:	.asciiz "The e^x value is: "
	
	zeroDouble:	.double	0.0
	oneDouble: 	.double 1.0
	negOneDouble:	.double -1.0
	twoDouble: 	.double 2.0
	piDouble: 	.double 3.1415927
	oneEightyDouble: .double 180.0
	
	termCountDouble: .double 100.0
.text
	# set the stack pointer to a multiple of 8
	andi $sp, $sp, 0xfffffff8
	
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
			beq $t0, $v0, handleFact
			
			li $t0, 4
			beq $t0, $v0, handleExp
		
			li $t0, -1
			beq $t0, $v0, exit
		
			j while
		endoperation:
			j while
	
	handleFact:
		
		la $a0, factPrompt
		jal printText
		
		jal getDouble
		
		jal doubleFact
		
		la $a0, factOutput
		jal printText
		
		jal printDouble
		jal printNewLine

		j endoperation

	handleSine:
		addi $sp, $sp, -40
		lw $s0, 0($sp)
		sdc1 $f4, 8($sp)
		sdc1 $f6, 16($sp)
		sdc1 $f10, 24($sp)
		

		
		la $a0, sinePrompt
		jal printText
		# get the degree in $f0
		jal getDegree
		# convert $f0 degree into radians
		jal convertDegRad
		
		# n = 0 start
		ldc1 $f2, zeroDouble
		
		# loop bound
		ldc1 $f4, termCountDouble
		
		# sum
		ldc1 $f6, zeroDouble
		
		# the value 1
		ldc1 $f10, oneDouble
		
		# store x
		sdc1 $f0, 32($sp)

		sineLoop:
			# if n >= termCount exit
			c.le.d $f2, $f4
			# x is $f0, n is $f2s
			# load x:
			ldc1 $f0, 32($sp)
			bc1f sineLoopExit
			# get sine term in $f0
			jal getSineTerm
			#jal printDouble
			#jal printNewLine
			# add to sum
			add.d $f6, $f6, $f0
			
			# n += 1
			add.d $f2, $f2, $f10
			j sineLoop
			
		sineLoopExit:
		mov.d $f0, $f6
		
		la $a0, sineOutput
		jal printText
		jal printDouble
		jal printNewLine
		
		lw $s0, 0($sp)
		ldc1 $f4, 8($sp)
		ldc1 $f6, 16($sp)
		ldc1 $f8, 24($sp)
		
		ldc1 $f0, 32($sp)
		addi $sp, $sp, 40
		
		j endoperation
	
	handleExp:
		addi $sp,$sp, -16
		sdc1 $f2, 0($sp)
		
		la $a0, expPrompt
		jal printText
		
		la $a0, getNPrompt
		jal printText
		
		# get n
		jal getDouble
		# store n in f2
		mov.d $f2, $f0
		
		la $a0, getXPrompt
		jal printText
		
		# get x in f0
		jal getDouble
		
		jal doubleExp
		# print the exp
		la $a0, exponentiationOutput
		jal printText
		jal printDouble
		# print the double x^n
		jal printNewLine
		
		lwc1 $f2, 0($sp)
		addi $sp, $sp, 8
		
		j endoperation
	
	getSineTerm:
		addi $sp, $sp, -32
		sw $ra, 0($sp)
		sdc1 $f0, 8($sp)
		sdc1 $f2, 16($sp)
		sdc1 $f10, 24($sp)
	
		# gets a term for the sin T series
		# x = $f0, n = $f2
		# return in $f0
		
		# (-1)^n * x^(2n+1) / (2n+1)!
		
		# exp: $f0 is x, $f2 is n
		ldc1 $f0, negOneDouble

		# -1^n in $f0
		jal doubleExp

		# get 2
		ldc1 $f10, twoDouble
		# get 2n
		mul.d $f2, $f2, $f10
		# get one
		ldc1 $f10, oneDouble
		# compute 2n+1
		add.d $f2, $f2, $f10
		
		# move -1^n to $f10 for storage
		mov.d $f10, $f0

		# call x^2n+1, note $f10 is 2n+1 already.Just load x from prior
		ldc1 $f0, 8($sp)

		jal doubleExp

		# mult -1^n times x^(2n+1). Now we have the numerator!
		mul.d $f10, $f10,$f0
	
		# recall $f2 has (2n+1)
		# thus just get the factorial of that
		# factorial argument in $f0, return $f0
		# numerator in $f4
		mov.d $f0, $f2
		jal doubleFact

		# now just divide!
		div.d $f0, $f10, $f0
	
		lw $ra, 0($sp)
		#ldc1 $f0, 8($sp)
		ldc1 $f2, 16($sp)
		ldc1 $f10, 24($sp)
		
		addi $sp, $sp, 32
		
		jr $ra
		
	handleCosine:
		
		addi $sp, $sp, -40
		lw $s0, 0($sp)
		sdc1 $f4, 8($sp)
		sdc1 $f6, 16($sp)
		sdc1 $f10, 24($sp)
		
		la $a0, cosinePrompt
		jal printText
		# get the degree in $f0
		jal getDegree
		# convert $f0 degree into radians
		jal convertDegRad
		
		# n = 0 start
		ldc1 $f2, zeroDouble
		
		# loop bound
		ldc1 $f4, termCountDouble
		
		# sum
		ldc1 $f6, zeroDouble
		
		# the value 1
		ldc1 $f10, oneDouble
		
		# store x
		sdc1 $f0, 32($sp)

		
		cosLoop:
			# if n >= termCount exit
			c.le.d $f2, $f4
			# x is $f0, n is $f2s
			# load x:
			ldc1 $f0, 32($sp)
			bc1f cosLoopExit
			# get cosine term in $f0
			jal getCosineTerm
			#jal printDouble
			#jal printNewLine
			# add to sum
			add.d $f6, $f6, $f0
			
			# n += 1
			add.d $f2, $f2, $f10
			j cosLoop
			
		cosLoopExit:
		mov.d $f0, $f6
		
		la $a0, cosineOutput
		jal printText
		jal printDouble
		jal printNewLine
		
		lw $s0, 0($sp)
		ldc1 $f4, 8($sp)
		ldc1 $f6, 16($sp)
		ldc1 $f8, 24($sp)
		
		ldc1 $f0, 32($sp)
		addi $sp, $sp, 40
		
		j endoperation
		
	getCosineTerm:
		addi $sp, $sp, -32
		sw $ra, 0($sp)
		sdc1 $f0, 8($sp)
		sdc1 $f2, 16($sp)
		sdc1 $f10, 24($sp)
	
		# gets a term for the cos T series
		# x = $f0, n = $f2
		# return in $f0
		
		# (-1)^n * x^(2n) / (2n)!
		
		# exp: $f0 is x, $f2 is n
		ldc1 $f0, negOneDouble

		
		# -1^n in $f0
		jal doubleExp

		
		# get 2
		ldc1 $f10, twoDouble
		# get 2n
		mul.d $f2, $f2, $f10
		
		# move -1^n to $f10 for storage
		mov.d $f10, $f0


		# call x^2n, note $f10 is 2n already.Just load x from prior
		ldc1 $f0, 8($sp)

		jal doubleExp


		# mult -1^n times x^(2n). Now we have the numerator!
		mul.d $f10, $f10,$f0
	
		# recall $f2 has (2n)
		# thus just get the factorial of that
		# factorial argument in $f0, return $f0
		# numerator in $f4
		mov.d $f0, $f2
		jal doubleFact

		# now just divide!
		div.d $f0, $f10, $f0

	
		lw $ra, 0($sp)
		#ldc1 $f0, 8($sp)
		ldc1 $f2, 16($sp)
		ldc1 $f10, 24($sp)
		
		addi $sp, $sp, 32
		
		jr $ra
			
			
	handleE:
		
		addi $sp, $sp, -40
		lw $s0, 0($sp)
		sdc1 $f4, 8($sp)
		sdc1 $f6, 16($sp)
		sdc1 $f10, 24($sp)
		

		
		la $a0, ePrompt
		jal printText
		# get the x
		la $a0, getXPrompt
		jal printText
		jal getDouble
		
		# n = 0 start
		ldc1 $f2, zeroDouble
		
		# loop bound
		ldc1 $f4, termCountDouble
		
		# sum
		ldc1 $f6, zeroDouble
		
		# the value 1
		ldc1 $f10, oneDouble
		
		# store x
		sdc1 $f0, 32($sp)

		
		eLoop:
			# if n >= termCount exit
			c.le.d $f2, $f4
			# x is $f0, n is $f2s
			# load x:
			ldc1 $f0, 32($sp)
			bc1f eLoopExit
			# get cosine term in $f0
			jal getETerm
			#jal printDouble
			#jal printNewLine
			# add to sum
			add.d $f6, $f6, $f0
			
			# n += 1
			add.d $f2, $f2, $f10
			j eLoop
			
		eLoopExit:
		mov.d $f0, $f6
		
		la $a0, eOutput
		jal printText
		jal printDouble
		jal printNewLine
		
		lw $s0, 0($sp)
		ldc1 $f4, 8($sp)
		ldc1 $f6, 16($sp)
		ldc1 $f8, 24($sp)
		
		ldc1 $f0, 32($sp)
		addi $sp, $sp, 40
		
		j endoperation
		
	getETerm:
		addi $sp, $sp, -16
		sw $ra, 0($sp)
		sdc1 $f4, 8($sp)
		
		# call x ^ n
		# x in f0, n in f2 already
		jal doubleExp
		# now f0 = x^n
		# move f0 to $f4 for storage
		
		mov.d $f4,$f0
		
		# get n!
		# fact's arg is $f0, move n into f0
		mov.d $f0, $f2
		
		jal doubleFact
		# now n! in $f0
		
		# just divide!
		div.d $f0, $f4, $f0
		
		lw $ra, 0($sp)
		ldc1 $f4, 8($sp)
		addi $sp, $sp, 16
		
		jr $ra
		
	getInt:
		# get the int,  store in $v0 
		li $v0, 5
		syscall
		
		jr $ra
		
	getDouble:
		# returns a double in $f0
	
		# get the double, store in $f10
		li $v0, 7
		syscall
		
		jr $ra
		
	getDegree:
		# returns the degree amount in $f0
		addi $sp, $sp, -8
		sw $ra, 0($sp)
		
		la $a0, degPrompt
		jal printText
		
		# get double in $f0
		jal getDouble
		
		lw $ra, 0($sp)
		addi $sp, $sp, 8
		
		jr $ra
	
	doubleExp:
		# reads in $f0 (x) and $f2 (n)
		# returns x^n in $f0
		# res = 1
		# double exp = x;
		# for(int i=1;i<=n;i++){
		# res *= x
		
		# WSDC1 NOT SWC1!!!
		
		addi $sp, $sp, -32
		sw $ra, 0($sp)
		sdc1 $f4, 8($sp)
		sdc1 $f6, 16($sp)
		sdc1 $f8, 24($sp)
		
		
		# int i=1
		ldc1 $f4, oneDouble
		
		# for adding 1
		ldc1 $f6, oneDouble
		
		# result
		ldc1 $f8, oneDouble
		
		# loop
		doubleExpLoop:
			# i > a terminates
			c.le.d $f4, $f2
			bc1f doubleExpLoopEnd

			
			mul.d $f8, $f8, $f0
		
			# i + 1
			add.d $f4, $f4,$f6
			j doubleExpLoop

		doubleExpLoopEnd: mov.d $f0, $f8
			
		# NOTE: use ldc1!
		
		lw $ra, 0($sp)
		ldc1 $f4, 8($sp)
		ldc1 $f6, 16($sp)
		ldc1 $f8, 24($sp)
		addi $sp, $sp, 32
		
		jr $ra
		
	doubleFact:
		# reads in $f0, returns in $f0 as well
		
		addi $sp, $sp,-32
		sw $ra, 0($sp)
		sdc1 $f2, 8($sp)
		sdc1 $f4, 16($sp)
		sdc1 $f6, 24($sp)
		
		# load the value 1 into f2, "count"
		ldc1 $f2, oneDouble
		
		# load the value of 1 into f4, to keep track of n
		ldc1 $f4, oneDouble
		
		# fact
		ldc1 $f6, oneDouble
		
		doubleFactLoop:
			# set less than equal to 
			c.le.d $f2,$f0
			# if not less than , end loop
			bc1f doubleFactLoopEnd
			# else, fact = fact * count
			mul.d $f6, $f6, $f2
			# i+=1
			add.d $f2, $f2, $f4
			
			j doubleFactLoop
			
		doubleFactLoopEnd:
		# need a zero for add next
		ldc1 $f4, zeroDouble
		
		add.d $f0, $f6, $f4
		
		lw $ra, 0($sp)
		ldc1 $f2, 8($sp)
		ldc1 $f4, 16($sp)
		ldc1 $f6, 24($sp)
		addi $sp, $sp, 32
		
		jr $ra
		
	convertDegRad:
		# read in $f0, out in $f0
		addi $sp, $sp, -24
		sw $ra, 0($sp)
		sdc1 $f10, 8($sp)
		sdc1 $f12, 16($sp)
		
		ldc1 $f10, piDouble
		# rad = (pi/180)*deg
		
		# pi * deg
		mul.d $f0, $f0, $f10
		
		ldc1 $f10, oneEightyDouble
		# 1/180
		div.d $f0, $f0, $f10
		
		
		lw $ra, 0($sp)
		ldc1 $f10,8($sp)
		ldc1 $f12, 16($sp)
		addi $sp, $sp, 24
		
		jr $ra
	printDouble:
		# prints the double found in $f0
		addi $sp, $sp, -24
		sw $ra, 0($sp)
		sdc1 $f10, 8($sp)
		sdc1 $f12,16($sp)
		
		li $v0, 3
		ldc1 $f10, zeroDouble
		add.d $f12, $f0, $f10
		syscall
		
		lw $ra, 0($sp)
		ldc1 $f10, 8($sp)
		ldc1 $f10, 16($sp)
		addi $sp, $sp, 24
		
		jr $ra
		
	printText:
		# Shows the text passed into $a0.
		addi $sp, $sp, -8
		sw $v0, 0($sp)
		
		# Display "Enter a degree amount"
		li $v0, 4
		syscall
	
		lw $v0, 0($sp)
		addi $sp, $sp 8
		
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
	
		
		
