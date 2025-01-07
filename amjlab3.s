@ Filename: amjlab3.s
@ Author: Adam Johnson
@ Date: 10?09/2024
@ Description: Vending machine simulation for CS413
@ Secret Code: Type the letter ’S’ to see stock

@ Use these commands to assemble, link, run and debug this program:
@    as -o amjlab3.o amjlab3.s
@    gcc -o amjlab3 amjlab3.o
@    ./amjlab3 ;echo $?
@    gdb --args ./amjlab3

.equ INPUT_ERROR, 0          @ Define a constant for input errors, though it's not used in this code
.global main                 @ Make the main label globally visible for the linker

main:
    push {lr}                    @ Save the link register to preserve return address
    bl initialize_inventory      @ Call function to set up initial inventory

main_loop:
    bl display_welcome           @ Display welcome message at the start of each loop
    bl check_stock               @ Check if any items are in stock
    cmp r0, #1                   @ Compare return value with 1 (1 means machine is empty)
    beq machine_empty            @ If machine is empty, branch to handle that case
    bl process_selection         @ Process user's selection
    b main_loop                  @ Loop back to start for next transaction
    pop {lr}                     @ Restore link register 
    bx lr                        @ Return from main

initialize_inventory:
    push {lr}                    @ Save link register
    mov r4, #2                   @ Set initial Gum inventory to 2
    mov r5, #2                   @ Set initial Peanuts inventory to 2
    mov r6, #2                   @ Set initial Cheese Crackers inventory to 2
    mov r7, #2                   @ Set initial M&Ms inventory to 2
    mov r10, #4                  @ Set total number of item types to 4
    pop {lr}                     @ Restore link register
    bx lr                        @ Return from function

display_welcome:
    push {lr}                    @ Save link register
    ldr r0, =welcome_message     @ Load address of welcome message
    bl printf                    @ Print welcome message
    ldr r0, =choice_prompt       @ Load address of choice prompt
    bl printf                    @ Print choice prompt
    mov r8, #0                   @ Reset payment amount to 0
    pop {lr}                     @ Restore link register
    bx lr                        @ Return from function

check_stock:
    push {lr}
    bl check_inventory           @ Call function to check inventory levels
    cmp r0, #1                   @ Compare return value with 1 (1 means machine is empty)
    beq machine_empty            @ If machine is empty, branch to handle that case
    pop {lr}                     @ Restore link register (this line is misplaced)
    bx lr                        @ Return from function

check_inventory:
    push {lr}                    @ Save link register
    mov r0, #0                   @ Initialize counter for out-of-stock items
    cmp r4, #0                   @ Check if Gum is out of stock
    addeq r0, r0, #1             @ If out of stock, increment counter
    cmp r5, #0                   @ Check if Peanuts are out of stock
    addeq r0, r0, #1             @ If out of stock, increment counter
    cmp r6, #0                   @ Check if Crackers are out of stock
    addeq r0, r0, #1             @ If out of stock, increment counter
    cmp r7, #0                   @ Check if M&Ms are out of stock
    addeq r0, r0, #1             @ If out of stock, increment counter
    cmp r0, #4                   @ Check if all items are out of stock
    beq machine_empty            @ Machine not empty
    mov r0, #0                   @ If not all out of stock, set return value to 0
    pop {lr}                     @ Restore link register
    bx lr                        @ Return from function

process_selection:
    push {lr}                    @ Save link register
    ldr r0, =charInputPattern    @ Load address of input pattern
    ldr r1, =charInput           @ Load address to store input
    bl scanf                     @ Read user input
    ldr r1, =charInput           @ Load address of input
    ldr r1, [r1]                 @ Load the input character
    cmp r1, #'G'                 @ Compare input with 'G'
    beq handle_gum               @ If 'G', handle gum selection
    cmp r1, #'P'                 @ Compare input with 'P'
    beq handle_peanuts           @ If 'P', handle peanuts selection
    cmp r1, #'C'                 @ Compare input with 'C'
    beq handle_crackers          @ If 'C', handle crackers selection
    cmp r1, #'M'                 @ Compare input with 'M'
    beq handle_mnms              @ If 'M', handle M&Ms selection
    cmp r1, #'S'                 @ Compare input with 'S'
    beq show_inventory           @ If 'S', show inventory
    b invalid_input              @ If no match, handle invalid input
    pop {lr}                     @ Restore link register (this line is never reached)
    bx lr

handle_gum:
    push {lr}                    @ Save link register
    cmp r4, #0                   @ Check if gum is in stock
    beq out_of_stock             @ If out of stock, branch to out_of_stock handler
    mov r9, #50                  @ Set price of gum to 50 cents
    ldr r0, =gum_msg             @ Load gum selection message
    bl printf                    @ Print gum selection message
    ldr r0, =charInputPattern    @ Load input pattern for confirmation
    ldr r1, =charInput           @ Load address to store confirmation
    bl scanf                     @ Read confirmation input
    ldr r1, =charInput           @ Load address of confirmation input
    ldr r1, [r1]                 @ Load confirmation input
    cmp r1, #'n'                 @ Compare input with 'n'
    beq main_loop                @ If 'n', go back to main loop
    cmp r1, #'y'                 @ Compare input with 'y'
    bne invalid_input            @ If not 'y', handle invalid input
    sub r4, r4, #1               @ Decrement gum inventory
    b payment_loop               @ Branch to payment loop
    pop {lr}                     @ Restore link register (this line is never reached)
    bx lr                        @ Return from function (this line is never reached)

handle_peanuts:
    push {lr}                    @ Save link register as we'll be calling other functions
    cmp r5, #0                   @ Compare peanuts inventory (r5) with 0
    beq out_of_stock             @ If inventory is 0, branch to out_of_stock handler
    mov r9, #55                  @ Set price of peanuts to 55 cents in r9
    ldr r0, =peanuts_msg         @ Load address of peanuts selection message
    bl printf                    @ Print peanuts selection message
    ldr r0, =charInputPattern    @ Load address of input pattern for confirmation
    ldr r1, =charInput           @ Load address to store user's confirmation
    bl scanf                     @ Read user's confirmation input
    ldr r1, =charInput           @ Load address of user's input
    ldr r1, [r1]                 @ Load the actual input character
    cmp r1, #'n'                 @ Compare input with 'n' (no)
    beq main_loop                @ If 'n', go back to check stock (user changed mind)
    cmp r1, #'y'                 @ Compare input with 'y' (yes)
    bne invalid_input            @ If not 'y', treat as invalid input
    sub r5, r5, #1               @ Decrement peanuts inventory by 1 (anticipating sale)
    b payment_loop               @ Branch to payment loop to collect money
    pop {lr}                     @ Restore link register (unreachable code)
    bx lr                        @ Return from function (unreachable code)

handle_crackers:
    push {lr}                    @ Save link register as we'll be calling other functions
    cmp r6, #0                   @ Compare crackers inventory (r6) with 0
    beq out_of_stock             @ If inventory is 0, branch to out_of_stock handler
    mov r9, #65                  @ Set price of crackers to 65 cents in r9
    ldr r0, =crackers_msg        @ Load address of crackers selection message
    bl printf                    @ Print crackers selection message
    ldr r0, =charInputPattern    @ Load address of input pattern for confirmation
    ldr r1, =charInput           @ Load address to store user's confirmation
    bl scanf                     @ Read user's confirmation input
    ldr r1, =charInput           @ Load address of user's input
    ldr r1, [r1]                 @ Load the actual input character
    cmp r1, #'n'                 @ Compare input with 'n' (no)
    beq main_loop                @ If 'n', go back to main loop (user changed mind)
    cmp r1, #'y'                 @ Compare input with 'y' (yes)
    bne invalid_input            @ If not 'y', treat as invalid input
    sub r6, r6, #1               @ Decrement crackers inventory by 1 (anticipating sale)
    b payment_loop               @ Branch to pyament loop to collect money
    pop {lr}                     @ Restore link register (unreachable code)
    bx lr                        @ Return from function (unreachable code)

handle_mnms:
    push {lr}                    @ Save link register as we'll be calling other functions
    cmp r7, #0                   @ Compare M&Ms inventory (r7) with 0
    beq out_of_stock             @ If inventory is 0, branch to out_of_stock handler
    mov r9, #100                 @ Set price of M&Ms to 100 cents (1 dollar) in r9
    ldr r0, =mnms_msg            @ Load address of M&Ms selection message
    bl printf                    @ Print M&Ms selection message
    ldr r0, =charInputPattern    @ Load address of input pattern for confirmation
    ldr r1, =charInput           @ Load address to store user's confirmation
    bl scanf                     @ Read user's confirmation input
    ldr r1, =charInput           @ Load address of user's input
    ldr r1, [r1]                 @ Load the actual input character
    cmp r1, #'n'                 @ Compare input with 'n' (no)
    beq main_loop                @ If 'n', go back to check stock (user changed mind)
    cmp r1, #'y'                 @ Compare input with 'y' (yes)
    bne invalid_input            @ If not 'y', treat as invalid input
    sub r7, r7, #1               @ Decrement M&Ms inventory by 1 (anticipating sale)
    b payment_loop               @ Branch to payment loop to collect money
    pop {lr}                     @ Restore link register (unreachable code)
    bx lr                        @ Return from function (unreachable code)

payment_loop:
    push {lr}                    @ Save link register
payment_start:
    cmp r8, r9
    bge payment_sufficient       @ Branch if paid enough or more
    ldr r0, =payment_prompt      @ Load payment prompt
    mov r1, r9                   @ Move price to r1 for printf
    bl printf                    @ print payment prompt
    ldr r0, =charInputPattern    @ Load input pattern for coin/bill
    ldr r1, =charInput           @ Load address to store coin/bill input
    bl scanf                     @ Read coin/bill input
    ldr r1, =charInput           @ Load address of coin/bill input
    ldrb r1, [r1]                @ Load coin/bill input
    cmp r1, #'D'                 @ Compare input with 'D' (dime)
    beq dime                     @ If dime, branch to dime handler
    cmp r1, #'Q'                 @ Compare input with 'Q' (quarter)
    beq quarter                  @ If quarter, branch to quarter handler
    cmp r1, #'B'                 @ Compare input with 'B' (bill)
    beq dollar                   @ If bill, branch to dollar handler
    b invalid_payment            @ If invalid input, handle invalid payment
    pop {lr}                     @ Restore link register 
    bx lr                        @ Return from function 

payment_sufficient:
    cmp r8, r9                   @ Compare total paid (r8) with price (r9)
    beq exact_pay                @ If exact payment, branch to exact_pay handler
    bgt overpay                  @ If overpaid, branch to overpay handler
    b main_loop

dollar:
    add r8, r8, #100         @ Add 100 cents (dollar value) to total payment in r8
    b payment_loop           @ Branch back to payment loop to continue collecting payment

quarter:
    add r8, r8, #25          @ Add 25 cents (quarter value) to total payment in r8
    b payment_loop           @ Branch back to payment loop to continue collecting payment

dime:
    add r8, r8, #10          @ Add 10 cents (dime value) to total payment in r8
    b payment_loop           @ Branch back to payment loop to continue collecting payment

exact_pay:
    push {lr}                @ Save link register
    ldr r0, =enough_money_msg @ Load address of "enough money" message
    bl printf                @ Print "enough money" message
    ldr r0, =dispense_msg    @ Load address of dispense message
    bl printf                @ Print dispense message
    mov r8, #0               @ Reset 
    pop {lr}                 @ Restore link register
    b main_loop 

overpay:
    push {lr}                @ Save link register
    ldr r0, =enough_money_msg @ Load address of "enough money" message
    bl printf                @ Print "enough money" message
    ldr r0, =dispense_msg    @ Load address of dispense message
    bl printf                @ Print dispense message
    sub r1, r8, r9           @ Calculate change by subtracting price (r9) from payment (r8)
    ldr r0, =change_msg      @ Load address of change message
    bl printf                @ Print change message
    mov r8, #0               @ Reset Payment amount
    pop {lr}                 @ Restore link register
    b main_loop              @ Branch back to main loop for next transaction

show_inventory:
    push {lr}                   @ Save link register
    ldr r0, =inventory_header
    bl printf
    mov r1, r4                  @ Move gum inventory (r4) to r1 for printf
    ldr r0, =inventory_gum      @ Load address of gum inventory message
    bl printf                   @ Print gum inventory
    mov r1, r5                  @ Move peanuts inventory (r5) to r1 for printf
    ldr r0, =inventory_peanuts  @ Load address of peanuts inventory message
    bl printf                   @ Print peanuts inventory
    mov r1, r6                  @ Move crackers inventory (r6) to r1 for printf
    ldr r0, =inventory_crackers @ Load address of crackers inventory message
    bl printf                   @ Print crackers inventory
    mov r1, r7                  @ Move M&Ms inventory (r7) to r1 for printf
    ldr r0, =inventory_mnms     @ Load address of M&Ms inventory message
    bl printf                   @ Print M&Ms inventory
    pop {lr}                    @ Restore link register
    b main_loop                 @ Branch directly to main_loop

out_of_stock:
    push {lr}                 @ Save link register
    ldr r0, =out_of_stock_msg @ Load address of out of stock message
    bl printf                 @ Print out of stock message
    pop {lr}                  @ Restore link register 
    b main_loop               @ Branch to main loop 

invalid_input:
    push {lr}                @ Save link register
    ldr r0, =error_msg       @ Load address of error message
    bl printf                @ Print error message
    ldr r0, =strInputPattern @ Load address of input pattern to clear buffer
    ldr r1, =strInputError   @ Load address to store cleared input
    bl scanf                 @ Clear input buffer
    pop {lr}                 @ Restore link register 
    b main_loop

machine_empty:
    push {lr}                @ Save link register
    ldr r0, =empty_msg       @ Load address of empty machine message
    bl printf                @ Print empty machine message
    b exit                   @ Branch to exit function to end program
    pop {lr}                 @ Restore link register 
    bx lr                    @ Return from function 

invalid_payment:
    push {lr}                    @ Save link register
    ldr r0, =invalid_payment_msg @ Load address of invalid payment message
    bl printf                    @ Print invalid payment message
    b payment_loop               @ Branch back to payment_loop to retry payment
    pop {lr}                     @ Restore link register
    b payment_start              @ branch to payment start

exit:
    mov r7, #1
    svc 0

.data
.balign 4
welcome_message: .asciz "Welcome to Mr. Zippy's vending machine.\nCost of Gum ($0.50), Peanuts ($0.55), Cheese Crackers ($0.65), or M&Ms ($1.00).\n"
.balign 4
choice_prompt: .asciz "Enter item selection: Gum (G), Peanuts (P), Cheese Crackers (C), or M&Ms (M)\n"
.balign 4
gum_msg: .asciz "You selected Gum. Is this correct? (y/n)\n"
.balign 4
peanuts_msg: .asciz "You selected Peanuts. Is this correct? (y/n)\n"
.balign 4
crackers_msg: .asciz "You selected Cheese Crackers. Is this correct? (y/n)\n"
.balign 4
mnms_msg: .asciz "You selected M&Ms. Is this correct? (y/n)\n"
.balign 4
enough_money_msg: .asciz "Enough money entered.\n"
.balign 4
payment_prompt: .asciz "Enter at least %d cents for selection.\nDimes (D), Quarters (Q) and Dollar Bill (B): "
.balign 4
dispense_msg: .asciz "Your item has been dispensed.\n"
.balign 4
change_msg: .asciz "Change of %d cents has been returned.\n"
.balign 4
error_msg: .asciz "\n\nInvalid input, try again.\n\n"
.balign 4
out_of_stock_msg: .asciz "\nYour selected item is out of stock. Please make another selection. \n"
.balign 4
empty_msg: .asciz "The machine is completely out of items\n"
.balign 4
inventory_gum: .asciz "\nGum: %d left\n"
.balign 4
inventory_peanuts: .asciz "Peanuts: %d left\n"
.balign 4
inventory_crackers: .asciz "Crackers: %d left\n"
.balign 4
inventory_mnms: .asciz "M&Ms: %d left\n\n"
.balign 4
invalid_payment_msg: .asciz "Invalid payment. Please enter D, Q, or B.\n"
.balign 4
inventory_header: .asciz "\nCurrent Inventory:\n"
.balign 4
charInputPattern: .asciz "%s"
.balign 4
charInput: .word 0
.balign 4
strInputPattern: .asciz "%[^\n]"
.balign 4
strInputError: .skip 100*4