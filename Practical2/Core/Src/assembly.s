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


main_loop:

@ Checks if buttons are pressed, if not then default mode
@ Need to refer to this later when doing the button modes


@ 0.7 seconds delay function
longdelay:
LDR R3, = LONG_DELAY_CNT @ set address of long delay to R3
LDR R3, [R3] @ loads the value of the long delay at its address and sets it to R3
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
SHORT_DELAY_CNT: 	.word 0
