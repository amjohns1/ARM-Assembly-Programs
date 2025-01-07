@ Filename: amjlab2.s
@ Author:   Adam Johnson
@ Email:    amj0034@uah.edu
@ Class:    CS413-02 
@ Term:     Fall 2024
@ Date:     09/22/2024

@ Purpose:  This program calculates the area of four geometric shapes:
@           triangle, rectangle, trapezoid, and square. It demonstrates
@           the use of subroutines, stack for parameter passing, and
@           input validation in ARM assembly.

@ NOTE TO GRADER:
@ ENTER EACH NUMBER INDIVIDUALLY	

@ Use these commands to assemble, link, run and debug this program:
@    as -o amjlab2.o amjlab2.s
@    gcc -o amjlab2 amjlab2.o
@    ./amjlab2
@    gdb --args ./amjlab2

.global main              @ Makes main visible to the linker, necessary for program entry point
.equ MAX_UINT, 0xFFFFFFFF @ Defines max unsigned int for overflow checking

main:
    push {lr}             @ Saves return address, necessary for proper function return
    bl display_welcome    @ Calls welcome function to greet user and explain program

main_loop:
    bl get_shape_choice   @ Gets user input for shape, centralizes input logic
    cmp r0, #5            @ Checks if user wants to quit
    beq program_exit      @ Exits if user chose to quit, provides clean exit path

    @ Branches to appropriate calculation based on user choice
    cmp r0, #1
    beq calc_triangle     @ Triangle calculation if user chose 1
    cmp r0, #2
    beq calc_rectangle    @ Rectangle calculation if user chose 2
    cmp r0, #3
    beq calc_trapezoid    @ Trapezoid calculation if user chose 3
    cmp r0, #4
    beq calc_square       @ Square calculation if user chose 4

    @ Asks user if they want to continue, allows for multiple calculations
    bl ask_continue
    cmp r0, #'y'
    beq main_loop         @ Repeats if user wants to continue

program_exit:
    mov r0, #0            @ Set return code to 0
    pop {lr}              @ Restores return address for proper program termination
    bx lr                 @ Returns to OS, ends program cleanly

@ Function: display_welcome
@ Purpose: Displays welcome message and instructions
display_welcome:
    push {lr}             @ Saves return address for nested function call
    ldr r0, =welcome_msg  @ Loads welcome message address
    bl printf             @ Prints welcome message, introduces program to user
    pop {lr}              @ Restores return address
    bx lr                 @ Returns to caller

@ Function: get_shape_choice
@ Purpose: Prompts user for shape choice and validates input
get_shape_choice:
    push {lr}             @ Saves return address for nested function calls

get_choice_loop:
    ldr r0, =shape_prompt @ Loads prompt message address
    bl printf             @ Prints prompt, asks user for shape choice
    ldr r0, =input_format @ Loads input format for scanf
    ldr r1, =user_input   @ Loads address to store user input
    bl scanf              @ Reads user input, gets shape choice from user
    cmp r0, #1            @ Checks if scanf read 1 item successfully
    bne input_error       @ Branches to error handling if input invalid
    ldr r0, =user_input   @ Reloads user input address
    ldr r0, [r0]          @ Loads actual input value
    cmp r0, #1            @ Checks if input is less than 1
    blt input_error       @ Branches to error if too low
    cmp r0, #5            @ Checks if input is greater than 5
    bgt input_error       @ Branches to error if too high
    pop {lr}              @ Restores return address if input valid
    bx lr                 @ Returns to caller with valid input

input_error:
    ldr r0, =error_msg    @ Loads error message address
    bl printf             @ Prints error message, informs user of invalid input
    ldr r0, =clear_input  @ Loads format to clear input buffer
    ldr r1, =input_buffer @ Loads buffer address for clearing
    bl scanf              @ Clears input buffer to prevent cascading errors
    b get_choice_loop     @ Loops back for new input attempt

@ Function: calc_triangle
@ Purpose: Calculates and displays triangle area
calc_triangle:
    push {r4-r6, lr}      @ Save registers we'll use and link register
    sub sp, sp, #16       @ Allocate 16 bytes on stack for local variables
    ldr r0, =triangle_prompt
    bl printf
    bl get_positive_integer
    str r0, [sp, #0]      @ Store base on stack
    bl get_positive_integer
    str r0, [sp, #4]      @ Store height on stack
    
    ldr r0, [sp, #0]      @ Load base into r0
    ldr r1, [sp, #4]      @ Load height into r1
    bl triangle_area      @ Call triangle_area, result will be in r0
    
    str r0, [sp, #8]      @ Store result on stack
    ldr r1, [sp, #8]      @ Load result into r1 for printf
    ldr r0, =result_msg
    bl printf
    add sp, sp, #16       @ Deallocate stack space
    pop {r4-r6, lr}       @ Restore saved registers and link register
    bx lr                 @ Return to caller

@ Function: triangle_area
@ Purpose: Calculates area of triangle (base * height / 2)
triangle_area:
    push {r4-r8, lr}      @ Save registers we'll use and link register
    mov r4, r0            @ r4 = base
    mov r5, r1            @ r5 = height
    umull r6, r7, r4, r5  @ r6:r7 = base * height
    cmp r7, #0            @ Check for overflow in multiplication
    bne overflow_error
    lsrs r0, r6, #1       @ r0 = (base * height) / 2, set flags for overflow
    bcs overflow_error    @ Branch if carry occurred in shift (overflow)
    pop {r4-r8, pc}       @ Restore registers and return

@ Function: calc_rectangle
@ Purpose: Calculates and displays rectangle area
calc_rectangle:
    push {r4-r6, lr}      @ Save registers we'll use and link register
    sub sp, sp, #16       @ Allocate 16 bytes on stack for local variables
    ldr r0, =rectangle_prompt
    bl printf
    bl get_positive_integer
    str r0, [sp, #0]      @ Store length on stack
    bl get_positive_integer
    str r0, [sp, #4]      @ Store width on stack
    
    ldr r0, [sp, #0]      @ Load length into r0
    ldr r1, [sp, #4]      @ Load width into r1
    bl rectangle_area     @ Call rectangle_area, result will be in r0
    
    str r0, [sp, #8]      @ Store result on stack
    ldr r1, [sp, #8]      @ Load result into r1 for printf
    ldr r0, =result_msg
    bl printf
    add sp, sp, #16       @ Deallocate stack space
    pop {r4-r6, lr}       @ Restore saved registers and link register
    bx lr                 @ Return to caller


@ Function: rectangle_area
@ Purpose: Calculates area of rectangle (length * width)
rectangle_area:
    push {r4-r8, lr}      @ Save registers we'll use and link register
    mov r4, r0            @ r4 = length
    mov r5, r1            @ r5 = width
    umull r0, r6, r4, r5  @ r0:r6 = length * width
    cmp r6, #0            @ Check for overflow in multiplication
    bne overflow_error
    pop {r4-r8, pc}       @ Restore registers and return

@ Function: calc_trapezoid
@ Purpose: Calculates and displays trapezoid area
calc_trapezoid:
    push {r4-r6, lr}      @ Save registers we'll use and link register
    sub sp, sp, #16       @ Allocate 16 bytes on stack for local variables
    ldr r0, =trapezoid_prompt
    bl printf
    bl get_positive_integer
    str r0, [sp, #0]      @ Store 'a' on stack
    bl get_positive_integer
    str r0, [sp, #4]      @ Store 'b' on stack
    bl get_positive_integer
    str r0, [sp, #8]      @ Store 'h' on stack
    
    ldr r0, [sp, #0]      @ Load 'a' into r0
    ldr r1, [sp, #4]      @ Load 'b' into r1
    ldr r2, [sp, #8]      @ Load 'h' into r2
    bl trapezoid_area     @ Call trapezoid_area, result will be in r0
    
    str r0, [sp, #12]     @ Store result on stack
    ldr r1, [sp, #12]     @ Load result into r1 for printf
    ldr r0, =result_msg
    bl printf
    add sp, sp, #16       @ Deallocate stack space
    pop {r4-r6, lr}       @ Restore saved registers and link register
    bx lr                 @ Return to caller

@ Function: trapezoid_area
@ Purpose: Calculates area of trapezoid ((a + b) * h / 2)
trapezoid_area:
    push {r4-r8, lr}      @ Save registers we'll use and link register
    mov r4, r0            @ r4 = a
    mov r5, r1            @ r5 = b
    mov r6, r2            @ r6 = h
    adds r7, r4, r5       @ r7 = a + b, set flags for overflow
    bvs overflow_error    @ Branch if overflow occurred in addition
    umull r0, r8, r7, r6  @ r0:r8 = (a + b) * h
    cmp r8, #0            @ Check for overflow in multiplication
    bne overflow_error
    lsrs r0, r0, #1       @ r0 = ((a + b) * h) / 2, set flags for overflow
    bcs overflow_error    @ Branch if carry occurred in shift (overflow)
    pop {r4-r8, pc}       @ Restore registers and return

@ Function: calc_square
@ Purpose: Calculates and displays square area
calc_square:
    push {lr}             @ Saves return address for nested function calls
    ldr r0, =square_prompt @ Loads square prompt address
    bl printf             @ Prints prompt for square dimension
    bl get_positive_integer @ Gets side length value
    mov r4, r0            @ Stores side length in r4 for later use
    push {r4}             @ Pushes side length onto stack for function call
    bl square_area        @ Calculates square area
    pop {r1}              @ Pops result from stack into r1 for printing
    ldr r0, =result_msg   @ Loads result message format
    bl printf             @ Prints the calculated area
    pop {lr}              @ Restores return address
    bx lr                 @ Returns to caller

@ Function: square_area
@ Purpose: Calculates area of square (side * side)
square_area:
    push {r4-r7, lr}      @ Saves registers and return address
    ldr r4, [sp, #20]     @ Loads side length from stack, adjusts for pushed registers
    umull r5, r6, r4, r4  @ Multiplies side by itself, checks for overflow
    cmp r6, #0            @ Checks high word for overflow
    bne overflow_error    @ Branches to overflow handler if high word non-zero
    str r5, [sp, #20]     @ Stores result on stack for return
    pop {r4-r7, pc}       @ Restores registers and returns

@ Function: get_positive_integer
@ Purpose: Gets and validates a positive integer input from user
get_positive_integer:
    push {lr}             @ Saves return address for nested function calls

get_int_loop:
    ldr r0, =input_prompt @ Loads input prompt address
    bl printf             @ Prints prompt for integer input
    ldr r0, =input_format @ Loads input format for scanf
    ldr r1, =user_input   @ Loads address to store user input
    bl scanf              @ Reads user input, gets integer from user
    cmp r0, #1            @ Checks if scanf read 1 item successfully
    bne input_error       @ Branches to error handling if input invalid
    ldr r0, =user_input   @ Reloads user input address
    ldr r0, [r0]          @ Loads actual input value
    cmp r0, #0            @ Checks if input is less than or equal to 0
    ble input_error       @ Branches to error if not positive
    pop {lr}              @ Restores return address if input valid
    bx lr                 @ Returns to caller with valid input

@ Function: ask_continue
@ Purpose: Asks user if they want to continue
ask_continue:
    push {lr}             @ Saves return address for nested function calls
    ldr r0, =continue_prompt @ Loads continue prompt address
    bl printf             @ Prints prompt asking user to continue
    ldr r0, =char_format  @ Loads character input format for scanf
    ldr r1, =user_input   @ Loads address to store user input
    bl scanf              @ Reads user input, gets y/n response
    ldr r0, =user_input   @ Reloads user input address
    ldrb r0, [r0]         @ Loads actual input character
    pop {lr}              @ Restores return address
    bx lr                 @ Returns to caller with user's choice

overflow_error:
    ldr r0, =overflow_msg @ Loads overflow error message address
    bl printf             @ Prints overflow error message
    mov r0, #0            @ Sets result to 0 in case of overflow
    str r0, [sp, #20]     @ Stores 0 as result on stack
    pop {r4-r7, pc}       @ Restores registers and returns from overflow_error

.data
.balign 4
welcome_msg:     .asciz "Welcome to the Area Calculator!\n"
.balign 4
shape_prompt:    .asciz "\nChoose a shape (1-Triangle, 2-Rectangle, 3-Trapezoid, 4-Square, 5-Quit): "
.balign 4
triangle_prompt: .asciz "Enter base and height for triangle:\n"
.balign 4
rectangle_prompt: .asciz "Enter length and width for rectangle:\n"
.balign 4
trapezoid_prompt: .asciz "Enter a, b, and height for trapezoid:\n"
.balign 4
square_prompt:   .asciz "Enter side length for square:\n"
.balign 4
input_prompt:    .asciz "Enter a positive integer: "
.balign 4
continue_prompt: .asciz "Continue? (y/n): "
.balign 4
result_msg:      .asciz "The area is: %d square units\n"
.balign 4
error_msg:       .asciz "Invalid input. Please try again.\n"
.balign 4
overflow_msg:    .asciz "Overflow error. Result too large.\n"
.balign 4
input_format:    .asciz "%d"
.balign 4
char_format:     .asciz " %c"
.balign 4
clear_input:     .asciz "%*[^\n]"
.balign 4
user_input:      .word 0
.balign 4
input_buffer:    .space 100