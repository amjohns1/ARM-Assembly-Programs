@ Filename: amjlab4.s
@ Author: Adam Johnson
@ Date: 10/13/2024
@ Description: Vending machine simulation in thumb mode
@ Secret Code: Type the letter 'S' to see stock

@ Use these commands to link, compile, run, and debug this program:
@ as -o amjlab4.o amjlab4.s
@ gcc -o amjlab4 amjlab4.o
@ ./amjlab4 ;echo $?
@ gdb --args ./amjlab4

.global main

main:
    ADR r0, ThumbCode + 1    @ Generate address of Thumb section
    BX  r0                   @ Branch and change to Thumb state 

    .thumb                   @ Switch to THUMB mode

ThumbCode:
    push {lr}                    @ Save the link register to preserve return address
    bl initialize_inventory      @ Call functiojn to set up initial inventory
    bl main_loop                 @ Call the main loop function
    pop {pc}                     @ Return from main

main_loop:                     @ Main program loop function
    push {lr}                 @ Save return address for this function
.main_loop_start:             @ Local label for loop start point
    bl display_welcome        @ Show welcome message and menu
    bl check_stock           @ Check if any items remain
    cmp r0, #1               @ Compare return value with 1 (empty)
    beq machine_empty        @ If machine is empty, handle that case
    bl process_selection     @ Otherwise process user's selection
    b .main_loop_start       @ Loop back to start for next transaction
    pop {pc}                 @ Return from function (note: unreachable due to branch)

machine_empty:                @ Function to handle when machine has no items
    push {lr}                @ Save return address before making function calls
    ldr r0, =empty_msg       @ Load address of empty machine message into r0 for printf
    bl printf                @ Print the empty machine message
    b exit                   @ Branch to exit function since machine is empty

exit:                        @ Function to terminate program
    movs r7, #1              @ Set r7 to 1 to indicate sys_exit system call
    svc #0                   @ Software interrupt to exit program 

invalid_input:               @ Function to handle invalid user input
    push {lr}                @ Save return address before making function calls
    ldr r0, =error_msg       @ Load address of error message into r0 for printf
    bl printf                @ Print the error message
    ldr r0, =strInputPattern @ Load address of input pattern to clear buffer
    ldr r1, =strInputError   @ Load address to store cleared input
    bl scanf                 @ Clear the input buffer
    pop {pc}                 @ Return to calling function

out_of_stock:                @ Function to handle when selected item is out
    push {lr}                @ Save return address before making function calls
    ldr r0, =out_of_stock_msg @ Load address of out of stock message
    bl printf                @ Print the out of stock message
    pop {pc}                 @ Return to calling function

process_selection:           @ Function to handle user's item selection
    push {lr}                @ Save return address before making function calls
    ldr r0, =charInputPattern @ Load address of pattern for single char input
    ldr r1, =charInput       @ Load address where input will be stored
    bl scanf                 @ Read user's input character
    ldr r1, =charInput       @ Reload input address to get character
    ldrb r1, [r1]            @ Load the input character (byte) into r1
    
    cmp r1, #'G'             @ Compare input with 'G' for Gum
    beq .do_gum              @ If Gum selected, branch to handle it
    cmp r1, #'P'             @ Compare input with 'P' for Peanuts
    beq .do_peanuts          @ If Peanuts selected, branch to handle it
    cmp r1, #'C'             @ Compare input with 'C' for Crackers
    beq .do_crackers         @ If Crackers selected, branch to handle it
    cmp r1, #'M'             @ Compare input with 'M' for M&Ms
    beq .do_mnms             @ If M&Ms selected, branch to handle it
    cmp r1, #'S'             @ Compare input with 'S' for secret code
    beq .do_inventory        @ If secret code entered, show inventory
    bl invalid_input         @ If no valid selection, handle invalid input
    b .main_loop_start       @ Return to main loop after invalid input

.do_gum:                     @ Label for handling Gum selection
    bl handle_gum            @ Call function to process Gum purchase
    b .main_loop_start       @ Return to main loop after handling
.do_peanuts:                 @ Label for handling Peanuts selection
    bl handle_peanuts        @ Call function to process Peanuts purchase
    b .main_loop_start       @ Return to main loop after handling
.do_crackers:                @ Label for handling Crackers selection
    bl handle_crackers       @ Call function to process Crackers purchase
    b .main_loop_start       @ Return to main loop after handling
.do_mnms:                    @ Label for handling M&Ms selection
    bl handle_mnms           @ Call function to process M&Ms purchase
    b .main_loop_start       @ Return to main loop after handling
.do_inventory:               @ Label for handling secret inventory check
    bl show_inventory        @ Call function to display current inventory
    b .main_loop_start       @ Return to main loop after showing inventory

show_inventory:              @ Function to display current inventory
    push {lr}                @ Save return address before making function calls
    ldr r0, =inventory_header @ Load address of inventory header message
    bl printf                @ Print the inventory header
    movs r1, r4              @ Move Gum count to r1 for printf
    ldr r0, =inventory_gum   @ Load address of Gum inventory message
    bl printf                @ Print Gum inventory count
    movs r1, r5              @ Move Peanuts count to r1 for printf
    ldr r0, =inventory_peanuts @ Load address of Peanuts inventory message
    bl printf                @ Print Peanuts inventory count
    movs r1, r6              @ Move Crackers count to r1 for printf
    ldr r0, =inventory_crackers @ Load address of Crackers inventory message
    bl printf                @ Print Crackers inventory count
    movs r1, r7              @ Move M&Ms count to r1 for printf
    ldr r0, =inventory_mnms  @ Load address of M&Ms inventory message
    bl printf                @ Print M&Ms inventory count
    pop {pc}                 @ Return to calling function

handle_gum:                  @ Entry point for handling gum purchases
    push {lr}                @ Save return address since we'll call functions that would overwrite it
    cmp r4, #0               @ Must check gum inventory first before proceeding
    beq .gum_out_of_stock    @ Can't sell if r4=0, so redirect to out of stock handler
    
    movs r2, #50             @ Store gum's price in r2, needed for payment calculations
    push {r2}                @ Save price since printf will corrupt r2 (r0-r3 not preserved in calls)
    ldr r0, =gum_msg         @ Printf requires message address in r0
    bl printf                @ Call will overwrite r0-r3
    pop {r2}                 @ Restore our price since printf corrupted r2
    
    push {r2}                @ Save price again because scanf will also corrupt registers
    ldr r0, =charInputPattern @ Scanf needs format string in r0
    ldr r1, =charInput       @ Scanf needs address to store input in r1
    bl scanf                 @ Call will corrupt r0-r3
    pop {r2}                 @ Get price back after scanf corrupted registers
    
    ldr r1, =charInput       @ Need to reload input address as scanf changed r1
    ldrb r1, [r1]           @ Get the actual character that was input
    cmp r1, #'n'            @ Check if user wants to cancel
    beq .gum_return         @ If 'n', abort transaction
    cmp r1, #'y'            @ Check if user confirmed
    bne .gum_invalid        @ If not 'y' or 'n', input is invalid
    
    sub r4, #1              @ Decrement inventory BEFORE payment to prevent overselling
    bl payment_loop         @ Process payment using price in r2
    pop {pc}                @ Successful purchase complete, return to caller

.gum_return:                @ Handle when user cancels purchase
    b .main_loop_start      @ Return to main menu

.gum_out_of_stock:          @ Handle when no gum available
    bl out_of_stock         @ Show out of stock message
    b .main_loop_start      @ Return to main menu

.gum_invalid:               @ Handle invalid yes/no response
    bl invalid_input        @ Show error message
    b .main_loop_start      @ Return to main menu

handle_peanuts:              @ Entry point for peanuts purchase handling
    push {lr}                @ Save return address since we'll make function calls that would overwrite it
    cmp r5, #0               @ Check peanuts inventory since we can't sell if empty
    beq .peanuts_out_of_stock @ Branch to out of stock handler if r5=0
    movs r2, #55             @ Need price in r2 for payment calculations (55 cents)
    push {r2}                @ Must save price since printf will corrupt r2
    ldr r0, =peanuts_msg     @ Printf needs message address in r0
    bl printf                @ Call will corrupt r0-r3, which is why we saved r2
    pop {r2}                 @ Get price back since printf corrupted r2
    push {r2}                @ Save price again because scanf will also corrupt registers
    ldr r0, =charInputPattern @ Scanf needs format string in r0
    ldr r1, =charInput       @ Scanf needs address to store input in r1
    bl scanf                 @ Call will corrupt registers
    pop {r2}                 @ Restore price after scanf corrupted registers
    ldr r1, =charInput       @ Need to reload input address since scanf changed r1
    ldrb r1, [r1]            @ Get actual character input value to check response
    cmp r1, #'n'             @ Check if user wants to cancel
    beq .peanuts_return      @ User cancelled, return to main menu
    cmp r1, #'y'             @ Check if user confirmed purchase
    bne .peanuts_invalid     @ Neither y/n means invalid input
    sub r5, #1               @ Decrement inventory before payment to prevent overselling
    bl payment_loop          @ Start payment process with price in r2
    pop {pc}                 @ Return to caller after successful purchase

.peanuts_return:             @ Handle user cancelling purchase
    b .main_loop_start       @ Go back to main menu directly

.peanuts_out_of_stock:       @ Handle when no peanuts left
    bl out_of_stock          @ Display out of stock message
    b .main_loop_start       @ Return to main menu

.peanuts_invalid:            @ Handle invalid y/n response
    bl invalid_input         @ Show error message
    b .main_loop_start       @ Return to main menu

handle_crackers:             @ Same pattern as peanuts but for crackers
    push {lr}                @ Save return address for function calls
    cmp r6, #0               @ Check crackers inventory
    beq .crackers_out_of_stock @ Handle empty inventory
    movs r2, #65             @ Set crackers price (65 cents)
    push {r2}                @ Save price from printf corruption
    ldr r0, =crackers_msg    @ Load message for printf
    bl printf                @ Will corrupt registers
    pop {r2}                 @ Restore price after printf
    push {r2}                @ Save price from scanf corruption
    ldr r0, =charInputPattern @ Format for scanf
    ldr r1, =charInput       @ Where scanf stores input
    bl scanf                 @ Will corrupt registers
    pop {r2}                 @ Get price back after scanf
    push {r2}                @ Save price for payment_loop
    ldr r1, =charInput       @ Get input address
    ldrb r1, [r1]            @ Get input character
    cmp r1, #'n'             @ Check for cancel
    beq .crackers_return     @ Handle cancel
    cmp r1, #'y'             @ Check for confirm
    bne .crackers_invalid    @ Handle invalid input
    sub r6, #1               @ Update inventory
    bl payment_loop          @ Process payment
    pop {r2}                 @ Clear saved price from stack
    pop {pc}                 @ Return to caller

.crackers_return:            @ Handle cancel
    pop {r2}                 @ Clear saved price
    b .main_loop_start       @ Return to main menu

.crackers_out_of_stock:      @ Handle empty inventory
    bl out_of_stock          @ Show message
    b .main_loop_start       @ Return to menu

.crackers_invalid:           @ Handle bad input
    pop {r2}                 @ Clear saved price
    bl invalid_input         @ Show error
    b .main_loop_start       @ Return to menu

handle_mnms:                @ Same pattern for M&Ms
    push {lr}               @ Save return address
    cmp r7, #0              @ Check M&Ms inventory
    beq .mnms_out_of_stock  @ Handle if empty
    movs r2, #100           @ Set M&Ms price (100 cents)
    push {r2}               @ Protect price from printf
    ldr r0, =mnms_msg       @ Get message for printf
    bl printf               @ Will corrupt registers
    pop {r2}                @ Restore price
    push {r2}               @ Protect from scanf
    ldr r0, =charInputPattern @ Format for scanf
    ldr r1, =charInput      @ Where to store input
    bl scanf                @ Will corrupt registers
    pop {r2}                @ Get price back
    ldr r1, =charInput      @ Get input location
    ldrb r1, [r1]           @ Get actual input
    cmp r1, #'n'            @ Check for cancel
    beq .mnms_return        @ Handle cancel
    cmp r1, #'y'            @ Check for confirm
    bne .mnms_invalid       @ Handle invalid
    sub r7, #1              @ Update inventory
    bl payment_loop         @ Process payment
    pop {pc}                @ Return to caller

.mnms_return:              @ Handle cancel
    b .main_loop_start     @ Return to menu

.mnms_out_of_stock:        @ Handle empty inventory  
    bl out_of_stock        @ Show message
    b .main_loop_start     @ Return to menu

.mnms_invalid:             @ Handle bad input
    bl invalid_input       @ Show error
    b .main_loop_start     @ Return to menu

payment_loop:
    push {lr}               @ Save return address
    push {r4, r5}           @ Use r4 to persistently store price, r5 for total
    mov r4, r2              @ Save price in r4
    movs r5, #0             @ Reset payment total in r5

.payment_check:
    mov r1, r4              @ Get price from r4
    sub r1, r5              @ Subtract amount paid to get remaining
    push {r1}               @ Save remaining amount
    ldr r0, =payment_prompt 
    bl printf               
    pop {r1}                @ Restore remaining amount

    ldr r0, =charInputPattern  @ Needs format string in r0 for scanf
    ldr r1, =charInput         @ Needs address for scanf to store result 
    bl scanf                   @ Scanf will corrupt registers
    ldr r1, =charInput         @ Reload to get input since bl scanf corrupted r1
    ldrb r1, [r1]              @ Get the actual character value that was input       

    cmp r1, #'D'            
    beq .add_dime           
    cmp r1, #'Q'            
    beq .add_quarter        
    cmp r1, #'B'            
    beq .add_dollar         

    ldr r0, =invalid_payment_msg
    bl printf               
    b .payment_check        

.add_dime:
    add r5, #10             @ Add dime to total in r5
    mov r1, r5              @ Get current total
    cmp r1, r4              @ Compare with price (in r4)
    blt .payment_check      @ If less than price, keep collecting
    b .payment_done

.add_quarter:
    add r5, #25             @ Add quarter to total in r5
    mov r1, r5              @ Get current total
    cmp r1, r4              @ Compare with price (in r4)
    blt .payment_check      @ If less than price, keep collecting
    b .payment_done

.add_dollar:
    add r5, #100            @ Add dollar to total in r5
    mov r1, r5              @ Get current total
    cmp r1, r4              @ Compare with price (in r4)
    blt .payment_check      @ If less than price, keep collecting

.payment_done:
    ldr r0, =enough_money_msg
    bl printf
    ldr r0, =dispense_msg
    bl printf

    @ Calculate and display change
    mov r1, r5              @ Get total paid
    sub r1, r4              @ Subtract price to get change
    cmp r1, #0              @ Check if any change
    ble .payment_exit       @ If no change, we're done

    push {r1}               @ Save change amount
    ldr r0, =change_msg     
    bl printf               
    pop {r1}                @ Restore stack

.payment_exit:
    pop {r4, r5}            @ Restore registers
    pop {pc}                @ Return

initialize_inventory:
    push {lr}                    @ Save link register
    movs r4, #2                  @ Set initial Gum inventory to 2
    movs r5, #2                  @ Set initial Peanuts inventory to 2
    movs r6, #2                  @ Set initial Cheese Crackers inventory to 2
    movs r7, #2                  @ Set initial M&Ms inventory to 2
    movs r0, #4                  @ Set total number of item types to 4 
    pop {pc}                     @ Return from function

display_welcome:
    push {lr}                    @ Save link register
    ldr r0, =welcome_message     @ Load address of welcome message
    bl printf                    @ Print welcome message
    ldr r0, =choice_prompt       @ Load address of choice prompt
    bl printf                    @ Print choice prompt
    pop {pc}                     @ Return from function

check_stock:
    push {lr}
    bl check_inventory           @ Call check_inventory function
    cmp r0, #1                  @ Compare return with 1 (empty = 1)
    beq .check_empty           @ If empty, branch to empty handler
    pop {pc}                    @ Return if not empty
.check_empty:
    bl machine_empty
    pop {pc}

check_inventory:
    push {lr}                   @ Save link register
    movs r0, #0                 @ Initialize counter for out of stock items
    cmp r4, #0                  @ Check if Gum is out
    bne .check_peanuts          @ If not zero, check next item
    add r0, #1                  @ Increment out of stock counter
.check_peanuts:
    cmp r5, #0                  @ Check if Peanuts are out
    bne .check_crackers         @ If not zero, check next item
    add r0, #1                  @ Increment out of stock counter
.check_crackers:
    cmp r6, #0                  @ Check if Crackers are out
    bne .check_mnms             @ If not zero, check next item
    add r0, #1                  @ Increment out of stock counter
.check_mnms:
    cmp r7, #0                  @ Check if M&Ms are out
    bne .final_check            @ If not zero, do final check
    add r0, #1                  @ Increment out of stock counter
.final_check:
    cmp r0, #4                  @ Check if all items are out
    beq .all_out                @ If all out, set return value to 1
    movs r0, #0                 @ If not all out, set return value to 0
    pop {pc}                    @ Return
.all_out:
    movs r0, #1                 @ Set return value to 1 (machine empty)
    pop {pc}                    @ Return

.data
.align 2
welcome_message: .asciz "Welcome to Mr. Zippy's vending machine.\nCost of Gum ($0.50), Peanuts ($0.55), Cheese Crackers ($0.65), or M&Ms ($1.00).\n"
choice_prompt: .asciz "Enter item selection: Gum (G), Peanuts (P), Cheese Crackers (C), or M&Ms (M)\n"
gum_msg: .asciz "You selected Gum. Is this correct? (y/n)\n"
peanuts_msg: .asciz "You selected Peanuts. Is this correct? (y/n)\n"
crackers_msg: .asciz "You selected Cheese Crackers. Is this correct? (y/n)\n"
mnms_msg: .asciz "You selected M&Ms. Is this correct? (y/n)\n"
enough_money_msg: .asciz "Enough money entered.\n"
payment_prompt: .asciz "Enter at least %d cents for selection.\nDimes (D), Quarters (Q) and Dollar Bill (B): "
dispense_msg: .asciz "Your item has been dispensed.\n"
change_msg: .asciz "Change of %d cents has been returned.\n"
error_msg: .asciz "\n\nInvalid input, try again.\n\n"
out_of_stock_msg: .asciz "\nYour selected item is out of stock. Please make another selection. \n"
empty_msg: .asciz "The machine is completely out of items\n"
inventory_gum: .asciz "\nGum: %d left\n"
inventory_peanuts: .asciz "Peanuts: %d left\n"
inventory_crackers: .asciz "Crackers: %d left\n"
inventory_mnms: .asciz "M&Ms: %d left\n\n"
invalid_payment_msg: .asciz "Invalid payment. Please enter D, Q, or B.\n"
inventory_header: .asciz "\nCurrent Inventory:\n"
charInputPattern: .asciz "%s"
charInput: .word 0
strInputPattern: .asciz "%[^\n]"
strInputError: .skip 100*4
