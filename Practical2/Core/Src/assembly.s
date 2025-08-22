/*
 * assembly.s
 *
 */
 
 @ DO NOT EDIT
	.syntax unified
    .text
    .global ASM_Main
    .thumb_func

@ DO NOT EDIT
vectors:
	.word 0x20002000
	.word ASM_Main + 1

@ DO NOT EDIT label ASM_Main
ASM_Main:

	@ Some code is given below for you to start with
	LDR R0, RCC_BASE  		@ Enable clock for GPIOA and B by setting bit 17 and 18 in RCC_AHBENR
	LDR R1, [R0, #0x14]
	LDR R2, AHBENR_GPIOAB	@ AHBENR_GPIOAB is defined under LITERALS at the end of the code
	ORRS R1, R1, R2
	STR R1, [R0, #0x14]

	LDR R0, GPIOA_BASE		@ Enable pull-up resistors for pushbuttons
	MOVS R1, #0b01010101
	STR R1, [R0, #0x0C]
	LDR R1, GPIOB_BASE  	@ Set pins connected to LEDs to outputs
	LDR R2, MODER_OUTPUT
	STR R2, [R1, #0]
	MOVS R2, #0         	@ NOTE: R2 will be dedicated to holding the value on the LEDs

@ TODO: Add code, labels and logic for button checks and LED patterns

LDR R5, GPIOA_BASE @ sets register 5 to the address of the start of the GPIOA base, this just makes it easier to get to

main_loop:

@ Checks if buttons are pressed, if not then default mode
@ Need to refer to this later when doing the button modes

LDR R4, [R5, #0x10] @ the IDR is at 0x48000010, it holds the push button states
@ NOTE the push buttons are active low
ANDS R4, R4, #0x0F @ just considers values of inputs for SW0-3

@ First want to check if button 2 or 3 pressed bcos they only pressed one at a time and dont want it mixed up with the later 0&1 pressing stuff

TST  R4, #0b0100  @Button 2, the TST instruction is an AND that wont change the R4 value, just changes flag
BEQ  mode2 @ If result of above is 0, the Z flag =1 and it will go to mode2

TST R4, #0b1000 @ checks if button 3 pressed
BEQ  mode3 @same as above

TST  R4, #0b0011 @ both button 0 and 1
BEQ  mode01

TST  R4, #0b0001 @button 0 pressed
BEQ  mode0

TST  R4, #0b0010 @button 1 pressed
BEQ  mode1

B    mode_Default

mode01:
STR  R2, [R1, #0x14]
ADD  R2, R2, #2
BL   shortdelay
@ keep this at end of this fucntion:
B    main_loop

mode0:
STR  R2, [R1, #0x14]
ADD  R2, R2, #2
BL   longdelay

@ keep this at end of this fucntion:
B    main_loop

mode1:
STR  R2, [R1, #0x14]
ADD  R2, R2, #1
BL   shortdelay
@ keep this at end of this fucntion:
B    main_loop

mode2:

@ keep this at end of this function:
B    main_loop @returns to main loop

mode3:
@ keep this at end of this function:
B    main_loop @returns to main loop

default_mode:
STR  R2, [R1, #0x14] @ display current count on LEDs (R2) sends to address for LED ODR
ADD  R2, R2, #1 @ increments LED counter
BL   longdelay @ branch to 0.7s delay
B    main_loop @ takes back to main loop


@ 0.7 seconds delay function
longdelay:
LDR R3, = LONG_DELAY_CNT @ set address of long delay to R3
LDR R3, [R3] @ loads the value of the long delay at its address and sets it to R3
loop:
SUB R3, R3, #1 @ R3 = R3-1
BNE loop @ if R3 =0 then will exit loop, Z flag =1 then
BX LR @ going to call this fn later and this makes it jump back to where it was before in the main loop

shortdelay:
LDR R3, SHORT_DELAY_CNT
LDR R3, [R3]
loop:
SUB R3, R3, #1 @ R3 = R3-1
BNE loop @ if R3 =0 then will exit loop, Z flag =1 then
BX LR @ going to call this fn later and this makes it jump back to where it was before in the main loop

write_leds:
	STR R2, [R1, #0x14]
	B main_loop

@ LITERALS; DO NOT EDIT
	.align
RCC_BASE: 			.word 0x40021000
AHBENR_GPIOAB: 		.word 0b1100000000000000000
GPIOA_BASE:  		.word 0x48000000
GPIOB_BASE:  		.word 0x48000400
MODER_OUTPUT: 		.word 0x5555

@ TODO: Add your own values for these delays

@ Choosing long delay: 8 Mhz clock (8 million cycles per sec) and want a 0.7s delay.
@ 8 Mhz * 0.7 = 5600000 cycles
@ Did some research and apparently an ARM loop takes about 3 cycles to execute
@ Therefore delay value: 5600000 divided by 3 = 1866666
@ will have to double check this is correct when testing
LONG_DELAY_CNT: 	.word 1866666
SHORT_DELAY_CNT: 	.word 800000 @uses same logic as long delay but for 0.3s
