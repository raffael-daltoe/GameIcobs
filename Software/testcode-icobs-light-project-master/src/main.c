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
// main.c
// Author: Soriano Theo
// Update: 23-09-2020
//-----------------------------------------------------------

#include "system.h"

int main(void)
{
	RSTCLK.GPIOAEN = 1;
	RSTCLK.GPIOBEN = 1;
	RSTCLK.GPIOCEN = 1;

	GPIOB.ODR = 0x0000;
	GPIOB.MODER = 0xFFFF;

	MY_PERIPH.REG1 = 0x55;
	MY_PERIPH.REG2 = MY_PERIPH.REG1;
	MY_VGA.Background =0;
	
	// UART1 initialization
	/*UART1_Init(115200);
	UART1_Enable();
	IBEX_SET_INTERRUPT(IBEX_INT_UART1);

	IBEX_ENABLE_INTERRUPTS;
*/
	MY_PERIPH.REG1 = 0x0;
	MY_PERIPH.REG2 = 0x1;
	MY_PERIPH.REG3 = 0x2;
	MY_PERIPH.REG4 = 0x3;

	int8_t count = 0;

	/*while(1) {
		myprintf("%d\n",count);
		count++;
		GPIOB.ODR = count;
		delay_ms(1);
	}*/

	while(1){
		//myprintf("%d\n",count);
		//count++;
		//GPIOB.ODR = count;
		delay_ms(500);
		MY_PERIPH.REG1++;
		MY_PERIPH.REG2++;
		MY_PERIPH.REG3++;
		MY_PERIPH.REG4++;
		MY_VGA.Background+=1;
	}
	return 0;
}

void Default_Handler(void){
	GPIOB.ODR = 0xFFFF;
}
