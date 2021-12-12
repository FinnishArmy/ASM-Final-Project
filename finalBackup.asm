#String to int
#Ronny Valtonen
#12/7/2020

 
#***Start of Code***#


.data
#Testing stuff
stringInput: .asciiz "g"        
base:        .byte 16
 
   
errorMessage:  .asciiz "\nError. Not a legal digit for the base given."

.text  

stringToInt: 

    la $t0, stringInput #current char address in t0
    li $t2, 0       
    li $t4, 1       
    lb $a1, base        #load into a1
    bgt $a1, 16, invalid    #checks if base is valid

    lb $s6, base        #loads into s6
    addi $s6, $s6, 48   #converts to ascii
    lb $s0, ($t0)   
    la $t5, stringInput
    beq $s0, '-', negSet    #checks is theres a negative sign
    j check         #jump to check


# Checks if the nubmer is negative.     
negSet:
    addi $s7, $zero, 1 
    addi $t0, $t0, 1
    addi $t5, $t5, 1


     
#Chekcs until it is at the end of the input
check:
    lb $t1, ($t0)
    beq $t1, '\n', endCheck
    beq $t1, '\0', endCheck
    add $t0, $t0, 1
    b check

endCheck:
#Checks the char backwards while decrementing the address. If the...
#highest ascii value is less than start address go to 4. 
loop:
    sub $t0, $t0, 1
    blt $t0, $t5 , valid     #Branch if less than strating address.
    lb $t1, ($t0)
    bgt $s6, 57, leave   #Branch if greater than s6
    bge $t1, $s6, invalid    #Branch if $t1 is >= $s6
    j values


leave:
	#Nothing to see here just an exit.

#Only use required values.    
values:  
    bge $t1, 'g', invalid       
    bge $t1, 'a', lowerCase
    bge $t1, 'G', invalid
    bge $t1, 'A', upperCase
    bge $t1, '9', invalid
    bge $t1 , '0', digit

#Error Message.
invalid:
    li $v0,1
    li $a0,0
    syscall
    
    li $v0, 4
    la $a0, errorMessage         
    syscall
    
    b exit

#Checks if valid. 
#Use twosComplement to check for negative.
valid:
    addi $t1, $zero, 1
    sll $t1, $t1, 31
    and $s1, $t2, $t1 
    bne $s1, $zero, negative
    bne $s7, $zero, twosComplement  #checkes the s7 register to see if our value is negative

# Return point after converting to negative number if a minus sign 
# was detected. Print and exit.     
continue:          
    li $v0, 1       # Print content of t2
    move $a0, $t2
    syscall
    b exit  

# manipulates the digit to convert and checks validity.   
digit:
    bgt $t1, '9', invalid
    sub $t3, $t1, '0'   #gets the digit
    mul $t3, $t3, $t4   #Multiply
    add $t2, $t2, $t3	#Add
    mul $t4, $t4, $a1   #Power 
    j loop

#get the digit    
lowerCase:
    bgt $t1, 'f', invalid 
    sub $t3, $t1, 'a'
    add $t3, $t3, 10
    mul $t3, $t3, $t4  
    add $t2, $t2, $t3	
    mul $t4, $t4, $a1 
    b loop

#get the digit    
upperCase:
    bgt $t1, 'F', invalid

    sub $t3, $t1, 'A'
    add $t3, $t3, 10
    mul $t3, $t3, $t4  
    add $t2, $t2, $t3   
    mul $t4, $t4, $a1  
    b loop

negative:
    li $t7, 10      #Load 10 into t7 register
    divu $t2, $t7
    mflo $t1        #Moves the lower register to t1 register
    mfhi $t7        #Moves the higher register to t7 register

    #Prints t1 register
    add $a0, $t1, $zero
    li $v0, 1
    syscall

    #Prints t7 register
    add $a0, $t7, $zero
    li $v0, 1
    syscall

#End.
exit:   
        li $v0, 10
        syscall

#Perform the twos complement.  
twosComplement:

    sub $t2, $zero, $t2     #Convert it to a negative number
    j continue 
