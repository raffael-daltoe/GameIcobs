// ##########################################################
// ##########################################################
// ##    __    ______   ______   .______        _______.   ##
// ##   |  |  /      | /  __  \  |   _  \      /       |   ##
// ##   |  | |  ,----'|  |  |  | |  |_)  |    |   (----`   ##
// ##   |  | |  |     |  |  |  | |   _  <      \   \       ##
// ##   |  | |  `----.|  `--'  | |  |_)  | .----)   |      ##
// ##   |__|  \______| \______/  |______/  |_______/       ##
// ##                                                      ##
// ##########################################################
// ##########################################################
//-----------------------------------------------------------
// system.c
// Author: Soriano Theo
// Update: 07-06-2022
//-----------------------------------------------------------

#include "system.h"

void SystemInit(void)
{
	IBEX_DISABLE_INTERRUPTS;

	RSTCLK.GPIOAEN = 1;
	RSTCLK.GPIOBEN = 1;
	RSTCLK.GPIOCEN = 1;

	// UART1 initialization
	UART1_Init(115200);
	UART1_Enable();
	IBEX_SET_INTERRUPT(IBEX_INT_UART1);

	CRC8_Init();

	IBEX_ENABLE_INTERRUPTS;
}
