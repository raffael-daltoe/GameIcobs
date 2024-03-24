/* 	##########################################################
	##########################################################
	##    __    ______   ______   .______        _______.   ##
	##   |  |  /      | /  __  \  |   _  \      /       |   ##
	##   |  | |  ,----'|  |  |  | |  |_)  |    |   (----`   ##
	##   |  | |  |     |  |  |  | |   _  <      \   \       ##
	##   |  | |  `----.|  `--'  | |  |_)  | .----)   |      ##
	##   |__|  \______| \______/  |______/  |_______/       ##
	##                                                      ##
	##########################################################
	##########################################################
	----------------------------------------------------------
	Startup file
	Author: Soriano Theo
	Update: 07-06-2022
	---------------------------------------------------------- */

.global Default_Handler

.word __ROM_BASE
.word __RAM_BASE

/* ---------------------------------------------------------------- */
.section .text.Reset_Handler
.weak Reset_Handler
.type Reset_Handler, %function

Reset_Handler:

	/* Set stack pointer */
	la  x2, __stack

	/* Copy data init */
	la  x25, _text_end 		/* load adress : x25 = @_text_end */
	la  x26, _data_start	/* load adress : x26 = @_data_start */
	la  x27, _data_end		/* load adress : x27 = @_data_end */
	/* Test if empty */
	bge x26, x27, copy_loop_end

	/* Copy data loop */
copy_loop:
	/* Copy data */
	lw  x28, 0(x25)			/* load : x28 = _text_end[i] */
	sw  x28, 0(x26)			/* _data_start[j] = x28 */
	/* Increment pointers (word) */
	add x25, x25, 4			/* i++ */
	add x26, x26, 4			/* j++ */
	/* Test if end */
	ble x26, x27, copy_loop /* continue while j <= @_data_end*/

copy_loop_end:

	/* Clear BSS init */
	la  x26, _bss_start		/* load adress : x26 = @_bss_start */
	la  x27, _bss_end		/* load adress : x27 = @_bss_end */
	/* Test if empty */
	bge x26, x27, zero_loop_end 	/* if empty branch to zero_loop_end */

	/* Clear BSS loop */
zero_loop:
	/* Clear memory */
	sw  x0, 0(x26)			/* _bss_start[i] = 0 */
	/* Increment pointer (word) */
	add x26, x26, 4			/* i++ */
	/* Test if end */
	ble x26, x27, zero_loop	/* continue while i <= @_bss_end*/

zero_loop_end:

	/* Set argc = argv = 0 */
	mv  x10, x0
	mv  x11, x0
	/* Call 'main' */
	jal main
	/* Always finish in trap */
	j   trap

/* ---------------------------------------------------------------- */
/* DEFAULT EXCEPTION HANDLER */
	.section .text.Default_Handler
	.weak Default_Handler

Default_Handler:
trap:
	j trap

/* ---------------------------------------------------------------- */
/* EXCEPTION VECTORS */
	.section .vectors, "ax"
	.option norvc

	/* external interrupts are handled by the same callback */
	/* until compiler supports IRQ routines */
	.org 0x00
	.rept 16
	j   Default_Handler
	.endr
	j   IRQ_00_Handler
	j   IRQ_01_Handler
	j   IRQ_02_Handler
	j   IRQ_03_Handler
	j   IRQ_04_Handler
	j   IRQ_05_Handler
	j   IRQ_06_Handler
	j   IRQ_07_Handler
	j   IRQ_08_Handler
	j   IRQ_09_Handler
	j   IRQ_10_Handler
	j   IRQ_11_Handler
	j   IRQ_12_Handler
	j   IRQ_13_Handler
	j   IRQ_14_Handler
	j   IRQ_NMI_Handler

	/*  Reset vector */
	.org 0x80
	j   Reset_Handler

	/*  Illegal instruction exception */
	.org 0x84
	j   Default_Handler

	/*  Ecall handler */
	.org 0x88
	j   Default_Handler



/* ---------------------------------------------------------------- */
	/* Set all handlers as weak alias of default handler */
	.weak IRQ_00_Handler
	.weak IRQ_01_Handler
	.weak IRQ_02_Handler
	.weak IRQ_03_Handler
	.weak IRQ_04_Handler
	.weak IRQ_05_Handler
	.weak IRQ_06_Handler
	.weak IRQ_07_Handler
	.weak IRQ_08_Handler
	.weak IRQ_09_Handler
	.weak IRQ_10_Handler
	.weak IRQ_11_Handler
	.weak IRQ_12_Handler
	.weak IRQ_13_Handler
	.weak IRQ_14_Handler
	.weak IRQ_NMI_Handler

	.set IRQ_00_Handler, Default_Handler
	.set IRQ_01_Handler, Default_Handler
	.set IRQ_02_Handler, Default_Handler
	.set IRQ_03_Handler, Default_Handler
	.set IRQ_04_Handler, Default_Handler
	.set IRQ_05_Handler, Default_Handler
	.set IRQ_06_Handler, Default_Handler
	.set IRQ_07_Handler, Default_Handler
	.set IRQ_08_Handler, Default_Handler
	.set IRQ_09_Handler, Default_Handler
	.set IRQ_10_Handler, Default_Handler
	.set IRQ_11_Handler, Default_Handler
	.set IRQ_12_Handler, Default_Handler
	.set IRQ_13_Handler, Default_Handler
	.set IRQ_14_Handler, Default_Handler
	.set IRQ_NMI_Handler, Default_Handler
