#String to int
#Ronny Valtonen
#12/7/2020

 
#***Start of Code***#


.data
#------Testing stuff--------#
#string: .asciiz "-AB"      #  
#baseValue:        .byte 16 #
#---------------------------#
 
   
errorReport:  .asciiz "\nNot a legal digit for the base given."

.text
#----Testing--------#
#    la $a0, string #
#    li $a1, 16     #
#    jal stringToInt#
#    move $a0, $v0  #
#    li $v0, 1      #
#    syscall        #
#    li $v0, 10     #
#    syscall        #
#-------------------#
    
stringToInt: 
    move $t0, $a0		#String value
    li $t2, 0       
    li $t8, 1       
    move $a2, $a1         #Base value
    bgt $a2, 16, wrong    #checks if base is valid

    move $s5, $a1        #Loads base to $s5
    addi $s5, $s5, 48   #converts to ascii
    lb $s0, ($t0)   
    move $t5, $a0		#Loads string to $t5
    beq $s0, '-', negSet    #checks is theres a negative sign
    j check         #jump to check
    

# Checks if the nubmer is negative.     
negSet:
    addi $s2, $zero, 1 
    addi $t0, $t0, 1
    addi $t5, $t5, 1


     
#Checks until it is at the end of the input
check:
    lb $t9, ($t0)
    beq $t9, '\n', endCheck
    beq $t9, '\0', endCheck
    add $t0, $t0, 1
    b check

endCheck:
#Checks the char backwards while decrementing the address. If the...
#highest ascii value is less than start address go to 4. 
loop:
    sub $t0, $t0, 1
    blt $t0, $t5 , valid     #Branch if less than strating address.
    lb $t9, ($t0)
    bgt $s5, 57, leave   #Branch if greater than s6
    bge $t1, $s5, wrong    #Branch if $t1 is >= $s6
    j values


leave:
	#Nothing to see here just an exit.

#Only use required values.    
values:  
    bge $t9, 'g', wrong       
    bge $t9, 'a', lowerCase
    bge $t9, 'G', wrong
    bge $t9, 'A', upperCase
    bge $t9, '9', wrong
    bge $t9 , '0', digit

#Error Message.
wrong:
    li $v0,1
    li $a0,0
    syscall
    
    li $v0, 4
    la $a0, errorReport         
    syscall
    
    b exit

#Checks if valid. 
#Use twosComplement to check for negative.
valid:
    addi $t9, $zero, 1
    sll $t9, $t9, 31
    and $s1, $t7, $t9 
    bne $s1, $zero, negative
    bne $s2, $zero, twosComplement  #checkes the s7 register to see if our value is negative

# Return point after converting to negative number if a minus sign 
# was detected. Print and exit.     
continue:          
    move $v0, $t7
    jr $ra

# manipulates the digit to convert and checks validity.   
digit:
    bgt $t9, '9', wrong
    sub $t1, $t9, '0'   #gets the digit
    mul $t1, $t1, $t8   #Multiply
    add $t7, $t7, $t1	#Add
    mul $t8, $t8, $a1   #Power 
    j loop

#get the digit    
lowerCase:
    bgt $t9, 'f', wrong 
    sub $t1, $t9, 'a'
    add $t1, $t1, 10
    mul $t1, $t1, $t8  
    add $t7, $t7, $t1	
    mul $t8, $t8, $a1 
    b loop

#get the digit    
upperCase:
    bgt $t9, 'F', wrong

    sub $t1, $t9, 'A'
    add $t1, $t1, 10
    mul $t1, $t1, $t8  
    add $t7, $t7, $t1   
    mul $t8, $t8, $a1  
    b loop

negative:
    li $t2, 10      #Load 10 into t7 register
    divu $t7, $t2
    mflo $t9        #Moves the lower register to t1 register
    mfhi $t2        #Moves the higher register to t7 register

    #Prints t1 register
    add $a0, $t9, $zero
    li $v0, 1
    syscall

    #Prints t7 register
    add $a0, $t2, $zero
    li $v0, 1
    syscall

#End.
exit:   
        li $v0, 10
        syscall

#Perform the twos complement.  
twosComplement:

    sub $t7, $zero, $t7     #Convert it to a negative number
    j continue 
