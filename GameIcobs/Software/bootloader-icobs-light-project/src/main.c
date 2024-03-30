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
// Bootloader main.c
// Author: Soriano Theo
// Update: 07-06-2022
//-----------------------------------------------------------

#include "system.h"

#ifndef BUILDNUMBER
#define BUILDNUMBER "00000001"
#endif

static const char message[] = "\x55\xFF\n" BUILDNUMBER "\nBootloader ICOBS light\n\n";

static void timer_clock_cb(int code)
{
	// SerialTick();
	((void)code);
}

int main(void)
{
	char* c = (char*)&message[0];
	int ret = 0;
	int in_progress = 0;

	SystemInit();

	_LD0_MODE = GPIO_MODE_OUTPUT;
	_LD1_MODE = GPIO_MODE_OUTPUT;
	_LD2_MODE = GPIO_MODE_OUTPUT;
	_LD15_MODE = GPIO_MODE_OUTPUT;
	LD0 = 1;
	LD1 = 0;
	LD2 = 0;
	LD15 = 0;

	set_timer_ms(1, timer_clock_cb, 0);

	while (*c)
		SerialSend(*(c++));

	if (RSTCLK.RSTSTATUS < 10)
		SerialSend('0' + RSTCLK.RSTSTATUS);
	else
		SerialSend('A' - 10 + RSTCLK.RSTSTATUS);

	SerialSend('\n');

	while (UART1_get_TxCount()); 	//wait last byte
	while (!UART1.TC);				//wait last byte transfert complete

	LD1 = 1;
	
	rst_clock();

	unsigned int cumul_length = 0;
	do
	{
		if (SerialTest())
		{
			in_progress = 1;
			ret = SerialReceive();
			if (ret > 0)
				cumul_length += ret;
		}
	} while (((clock() < 2000) || in_progress) && ret >= 0);

	in_progress = 0;

	if (ret != -1) {
		//error
	}

	while (!UART1.TC);

	LD2 = 1;


	RSTCLK.MEMSEL = MEMSEL_RAM1;
	RSTCLK.SOFTRESET = 1;

	return 0;
}

void Default_Handler(void){
	LD15 = 1;
}
