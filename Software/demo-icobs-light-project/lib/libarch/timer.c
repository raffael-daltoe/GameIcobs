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
// timer.c
// Author: Soriano Theo
// Update: 23-11-2021
//-----------------------------------------------------------

#include <arch.h>
#include <timer.h>
#include <ibex_csr.h>

static void (*g_callback)(int);
static int g_callback_code;

void set_timer_ms(int time, void (*callback)(int), int code){
	g_callback = callback;
	g_callback_code = code;
	IBEX_SET_INTERRUPT(IBEX_INT_TIMER1);
	RSTCLK.TIMER1EN = 1;
	TIMER1.PE = 0;
	TIMER1.UIE = 1;
	TIMER1.CNT = 0;
	TIMER1.PSC = 24999;
	TIMER1.ARR = time*2;
	TIMER1.PE = 1;
}

void delay_ms(int time_ms){
	RSTCLK.TIMER1EN = 1;
	TIMER1.PE = 0;
	TIMER1.UIF = 0;
	TIMER1.CNT = 0;
	TIMER1.PSC = 24999;
	TIMER1.ARR = time_ms*2;
	TIMER1.PE = 1;
	while (!TIMER1.UIF);
}

void TIMER1_IRQHandler(void) __attribute__((interrupt));
void TIMER1_IRQHandler(void)
{
	if (TIMER1.UIF)
	{
		if (g_callback != (void*)0)
		{
			g_callback(g_callback_code);
		}
		TIMER1.UIF = 0;
	}
}
