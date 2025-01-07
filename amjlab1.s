@ Filename: amjlab1.s
@ Author:   Adam Johnson
@ Email:    amj0034@uah.edu
@ Class:    CS413-02
@ Term:     Fall 2024
@ Date:     08/31/2024

@ Purpose:  This program demonstrates array operations in ARM assembly.
@           It initializes two arrays, calculates their sum into a third array,
@           displays all arrays, and then selectively prints values from the
@           third array based on user input (positive, negative, or zero).

@ Use these commands to assemble, link, and run the program:
@    as -o amjlab1.o amjlab1.s
@    gcc -o amjlab1 amjlab1.o
@    ./amjlab1 ;echo $?
@    gdb --args ./amjlab1

.global main              @ make main function visible to linker
.equ ARRAY_SIZE, 10       @ define constant for array size
.equ EXIT_CODE, 0x01      @ define constant for exit code

main:
    push {lr}             @ save link register to stack
    bl display_intro      @ display welcome message
    bl perform_array_ops  @ perform array operations
    bl show_arrays        @ display all arrays
    bl get_user_choice    @ get and process user input
    pop {lr}              @ restore link register
    bx lr                 @ return from main function

@ Function: display_intro
@ Purpose: Displays the welcome message to the user
display_intro:
    push {lr}             @ save link register
    ldr r0, =intro_message @ load address of intro message
    bl printf             @ call printf to display message
    pop {lr}              @ restore link register
    bx lr                 @ return from function

@ Function: perform_array_ops
@ Purpose: Calculates the sum of array1 and array2 into result_array
perform_array_ops:
    push {r4-r8, lr}      @ save registers and link register
    ldr r4, =source_array1 @ load address of first source array
    ldr r5, =source_array2 @ load address of second source array
    ldr r6, =result_array @ load address of result array
    mov r7, #ARRAY_SIZE   @ initialize loop counter

    @ Loop to calculate sum array using auto-indexing
array_loop:
    ldr r0, [r4], #4      @ load from array1 and increment address
    ldr r1, [r5], #4      @ load from array2 and increment address
    add r2, r0, r1        @ add elements from both arrays
    str r2, [r6], #4      @ store result and increment address
    subs r7, r7, #1       @ decrement loop counter
    bne array_loop        @ continue loop if counter is not zero

    pop {r4-r8, lr}       @ restore registers and link register
    bx lr                 @ return from function

@ Function: show_arrays
@ Purpose: Displays all three arrays
show_arrays:
    push {r4, lr}         @ save r4 and link register
    
    ldr r0, =array1_label @ load address of first array label
    bl printf             @ print first array label
    ldr r1, =source_array1 @ load address of first array
    bl print_array        @ call function to print first array

    ldr r0, =array2_label @ load address of second array label
    bl printf             @ print second array label
    ldr r1, =source_array2 @ load address of second array
    bl print_array        @ call function to print second array

    ldr r0, =result_label @ load address of result array label
    bl printf             @ print result array label
    ldr r1, =result_array @ load address of result array
    bl print_array        @ call function to print result array

    pop {r4, lr}          @ restore r4 and link register
    bx lr                 @ return from function

@ Function: print_array
@ Purpose: Prints an array passed by address
@ Input: r1 - address of the array to print
print_array:
    push {r4-r6, lr}      @ save registers and link register
    mov r4, r1            @ store array address in r4
    mov r5, #ARRAY_SIZE   @ initialize loop counter

    @ Loop to print array elements
print_loop:
    ldr r1, [r4], #4      @ load value from array and increment address
    ldr r0, =number_format @ load address of number format string
    bl printf             @ print the number
    subs r5, r5, #1       @ decrement loop counter
    bne print_loop        @ continue loop if counter is not zero

    ldr r0, =newline      @ load address of newline string
    bl printf             @ print newline
    pop {r4-r6, lr}       @ restore registers and link register
    bx lr                 @ return from function

@ Function: get_user_choice
@ Purpose: Prompts for user input and calls appropriate print function
get_user_choice:
    push {r4-r6, lr}      @ save registers and link register
    ldr r0, =prompt_message @ load address of prompt message
    bl printf             @ print prompt message

    ldr r0, =input_format @ load address of input format string
    ldr r1, =user_input   @ load address to store user input
    bl scanf              @ read user input

    @ Error checking for scanf (simple version)
    cmp r0, #1            @ compare scanf return value with 1
    bne input_error       @ branch to error handling if not equal

    ldr r0, =user_input   @ load address of user input
    ldrb r0, [r0]         @ load byte (character) from user input

    cmp r0, #'+'          @ compare input with '+'
    beq print_positive    @ branch to print positive if equal
    cmp r0, #'-'          @ compare input with '-'
    beq print_negative    @ branch to print negative if equal
    cmp r0, #'0'          @ compare input with '0'
    beq print_zero        @ branch to print zero if equal
    b input_error         @ branch to error handling if no match

input_error:
    ldr r0, =error_message @ load address of error message
    bl printf             @ print error message
    b exit_program        @ branch to exit program

@ Function: print_positive
@ Purpose: Prints positive numbers from result_array
print_positive:
    ldr r4, =result_array @ load address of result array
    mov r5, #ARRAY_SIZE   @ initialize loop counter
pos_loop:
    ldr r1, [r4], #4      @ load value from array and increment address
    cmp r1, #0            @ compare value with 0
    ble skip_pos          @ skip if less than or equal to 0
    ldr r0, =number_format @ load address of number format string
    bl printf             @ print the number if positive
skip_pos:
    subs r5, r5, #1       @ decrement loop counter
    bne pos_loop          @ continue loop if counter is not zero
    ldr r0, =newline      @ load address of newline string
    bl printf             @ print newline
    b exit_program        @ branch to exit program

@ Function: print_negative
@ Purpose: Prints negative numbers from result_array
print_negative:
    ldr r4, =result_array @ load address of result array
    mov r5, #ARRAY_SIZE   @ initialize loop counter
neg_loop:
    ldr r1, [r4], #4      @ load value from array and increment address
    cmp r1, #0            @ compare value with 0
    bge skip_neg          @ skip if greater than or equal to 0
    ldr r0, =number_format @ load address of number format string
    bl printf             @ print the number if negative
skip_neg:
    subs r5, r5, #1       @ decrement loop counter
    bne neg_loop          @ continue loop if counter is not zero
    ldr r0, =newline      @ load address of newline string
    bl printf             @ print newline
    b exit_program        @ branch to exit program

@ Function: print_zero
@ Purpose: Prints zero values from result_array
print_zero:
    ldr r4, =result_array @ load address of result array
    mov r5, #ARRAY_SIZE   @ initialize loop counter
zero_loop:
    ldr r1, [r4], #4      @ load value from array and increment address
    cmp r1, #0            @ compare value with 0
    bne skip_zero         @ skip if not equal to 0
    ldr r0, =number_format @ load address of number format string
    bl printf             @ print the number if zero
skip_zero:
    subs r5, r5, #1       @ decrement loop counter
    bne zero_loop         @ continue loop if counter is not zero
    ldr r0, =newline      @ load address of newline string
    bl printf             @ print newline
    b exit_program        @ branch to exit program

exit_program:
    mov r7, #1            @ move exit syscall number to r7
    mov r0, #0            @ move 0 (success) to r0 as exit status
    svc 0                 @ make system call to exit program

.data
.balign 4
intro_message:    .asciz "Welcome to the Array Operations Program\n"
.balign 4
prompt_message:   .asciz "Enter +, -, or 0 to view positive, negative, or zero values: "
.balign 4
array1_label:     .asciz "First Source Array:\n"
.balign 4
array2_label:     .asciz "Second Source Array:\n"
.balign 4
result_label:     .asciz "Resulting Array:\n"
.balign 4
number_format:    .asciz "%d "
.balign 4
input_format:     .asciz " %c"
.balign 4
newline:          .asciz "\n"
.balign 4
error_message:    .asciz "Invalid input. Program terminating.\n"
.balign 4
user_input:       .word 0

.balign 4
source_array1:    .word 2, -4, 6, -8, 10, 0, 12, -14, 16, -18
.balign 4
source_array2:    .word -1, 3, -5, 7, -9, 0, 11, -13, 15, -17
.balign 4
result_array:     .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0