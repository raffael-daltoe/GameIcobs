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

#define _BTNU_MODE  GPIOC.MODEbits.P0
#define BTNU        GPIOC.IDRbits.P0

#define _BTNL_MODE  GPIOC.MODEbits.P1
#define BTNL        GPIOC.IDRbits.P1

#define _BTNR_MODE  GPIOC.MODEbits.P2
#define BTNR        GPIOC.IDRbits.P2

#define _BTND_MODE  GPIOC.MODEbits.P3
#define BTND        GPIOC.IDRbits.P3

#define _SW0_MODE   GPIOA.MODEbits.P0
#define SW0			GPIOA.IDRbits.P0

#define _SW1_MODE   GPIOA.MODEbits.P1
#define SW1			GPIOA.IDRbits.P1

#define _SW2_MODE   GPIOA.MODEbits.P2
#define SW2			GPIOA.IDRbits.P2

#define _SW3_MODE   GPIOA.MODEbits.P3
#define SW3			GPIOA.IDRbits.P3

#define _SW4_MODE   GPIOA.MODEbits.P4
#define SW4			GPIOA.IDRbits.P4

#define _SW5_MODE   GPIOA.MODEbits.P5
#define SW5			GPIOA.IDRbits.P5

#define _SW6_MODE   GPIOA.MODEbits.P6
#define SW6			GPIOA.IDRbits.P6

#define _SW7_MODE   GPIOA.MODEbits.P7
#define SW7			GPIOA.IDRbits.P7

#define _SW8_MODE   GPIOA.MODEbits.P8
#define SW8			GPIOA.IDRbits.P8

#define _SW9_MODE   GPIOA.MODEbits.P9
#define SW9			GPIOA.IDRbits.P9

#define _SW10_MODE   GPIOA.MODEbits.P10
#define SW10			GPIOA.IDRbits.P10

#define _SW11_MODE   GPIOA.MODEbits.P11
#define SW11			GPIOA.IDRbits.P11

#define _SW12_MODE   GPIOA.MODEbits.P12
#define SW12			GPIOA.IDRbits.P12

#define _SW13_MODE   GPIOA.MODEbits.P13
#define SW13			GPIOA.IDRbits.P13

#define _SW14_MODE   GPIOA.MODEbits.P14
#define SW14			GPIOA.IDRbits.P14

#define _SW15_MODE   GPIOA.MODEbits.P15
#define SW15			GPIOA.IDRbits.P15

int TIMER_FLAG = 0;

static void timer_clock_cb(int code)
{
	TIMER_FLAG=1;
	((void)code);
}

int main(void)
{
	RSTCLK.GPIOAEN = 1;
	RSTCLK.GPIOBEN = 1;
	RSTCLK.GPIOCEN = 1;

	GPIOB.ODR = 0x0000;
	GPIOB.MODER = 0xFFFF;

	_BTNU_MODE = GPIO_MODE_INPUT;
	_BTNL_MODE = GPIO_MODE_INPUT;
	_BTNR_MODE = GPIO_MODE_INPUT;
	_BTND_MODE = GPIO_MODE_INPUT;

	_SW0_MODE  = GPIO_MODE_INPUT; 
	_SW1_MODE  = GPIO_MODE_INPUT; 
	_SW2_MODE  = GPIO_MODE_INPUT; 
	_SW3_MODE  = GPIO_MODE_INPUT; 
	_SW4_MODE  = GPIO_MODE_INPUT; 
	_SW5_MODE  = GPIO_MODE_INPUT; 
	_SW6_MODE  = GPIO_MODE_INPUT; 
	_SW7_MODE  = GPIO_MODE_INPUT; 
	_SW8_MODE  = GPIO_MODE_INPUT; 
	_SW9_MODE  = GPIO_MODE_INPUT; 
	_SW10_MODE = GPIO_MODE_INPUT; 
	_SW11_MODE = GPIO_MODE_INPUT; 
	_SW12_MODE = GPIO_MODE_INPUT; 
	_SW13_MODE = GPIO_MODE_INPUT; 
	_SW14_MODE = GPIO_MODE_INPUT; 
	_SW15_MODE = GPIO_MODE_INPUT; 
	
	// UART1 initialization
	UART1_Init(115200);
	UART1_Enable();
	IBEX_SET_INTERRUPT(IBEX_INT_UART1);

	IBEX_ENABLE_INTERRUPTS;

	myprintf("\n! --VGA Working--! \n");

	set_timer_ms(1000, timer_clock_cb, 0);

	MY_VGA.Y1_Position=0;
	MY_VGA.X1_Position=0;
	MY_VGA.Background=0x0;
	MY_VGA.X2_Position=320;
	MY_VGA.Y2_Position=400;
	while(1){ 
		delay_ms(1);
// Mover para a direita, garantindo que não ultrapasse a borda esquerda da segunda imagem
if(BTNR && MY_VGA.Y1_Position < 558) {
    if(!(MY_VGA.Y1_Position + 80 >= MY_VGA.Y2_Position && MY_VGA.Y1_Position < MY_VGA.Y2_Position + 90 && 
       ((MY_VGA.X1_Position + 90 > MY_VGA.X2_Position && MY_VGA.X1_Position < MY_VGA.X2_Position + 90) || 
       (MY_VGA.X1_Position < MY_VGA.X2_Position + 90 && MY_VGA.X1_Position + 90 > MY_VGA.X2_Position)))) {
        MY_VGA.Y1_Position++;
    }
}

// Mover para a esquerda, garantindo que não ultrapasse a borda direita da segunda imagem
if(BTNL && MY_VGA.Y1_Position > 0) {
    if(!(MY_VGA.Y1_Position <= MY_VGA.Y2_Position + 90 && MY_VGA.Y1_Position + 80 > MY_VGA.Y2_Position && 
       ((MY_VGA.X1_Position + 90 > MY_VGA.X2_Position && MY_VGA.X1_Position < MY_VGA.X2_Position + 90) || 
       (MY_VGA.X1_Position < MY_VGA.X2_Position + 90 && MY_VGA.X1_Position + 90 > MY_VGA.X2_Position)))) {
        MY_VGA.Y1_Position--;
    }
}

// Mover para cima, garantindo que não ultrapasse a borda inferior da segunda imagem
if(BTNU && MY_VGA.X1_Position > 0) {
    if(!(MY_VGA.X1_Position <= MY_VGA.X2_Position + 90 && MY_VGA.X1_Position + 90 > MY_VGA.X2_Position && 
       ((MY_VGA.Y1_Position + 80 > MY_VGA.Y2_Position && MY_VGA.Y1_Position < MY_VGA.Y2_Position + 90) || 
       (MY_VGA.Y1_Position < MY_VGA.Y2_Position + 90 && MY_VGA.Y1_Position + 80 > MY_VGA.Y2_Position)))) {
        MY_VGA.X1_Position--;
    }
}

// Mover para baixo, garantindo que não ultrapasse a borda superior da segunda imagem
if(BTND && MY_VGA.X1_Position < 390) {
    if(!(MY_VGA.X1_Position + 90 >= MY_VGA.X2_Position && MY_VGA.X1_Position < MY_VGA.X2_Position + 90 && 
       ((MY_VGA.Y1_Position + 80 > MY_VGA.Y2_Position && MY_VGA.Y1_Position < MY_VGA.Y2_Position + 90) || 
       (MY_VGA.Y1_Position < MY_VGA.Y2_Position + 90 && MY_VGA.Y1_Position + 80 > MY_VGA.Y2_Position)))) {
        MY_VGA.X1_Position++;
    }
}
		  // above




		if(SW0)MY_VGA.Background |= (1 << 0);
		else MY_VGA.Background &= ~(1 << 0);
		if(SW1)MY_VGA.Background |= (1 << 1);
		else MY_VGA.Background &= ~(1 << 1);
		if(SW2)MY_VGA.Background |= (1 << 2);
		else MY_VGA.Background &= ~(1 << 2);
		if(SW3)MY_VGA.Background |= (1 << 3);
		else MY_VGA.Background &= ~(1 << 3);
		if(SW4)MY_VGA.Background |= (1 << 4);
		else MY_VGA.Background &= ~(1 << 4);
		if(SW5)MY_VGA.Background |= (1 << 5);
		else MY_VGA.Background &= ~(1 << 5);
		if(SW6)MY_VGA.Background |= (1 << 6);
		else MY_VGA.Background &= ~(1 << 6);
		if(SW7)MY_VGA.Background |= (1 << 7);
		else MY_VGA.Background &= ~(1 << 7);
		if(SW8)MY_VGA.Background |= (1 << 8);
		else MY_VGA.Background &= ~(1 << 8);
		if(SW9)MY_VGA.Background |= (1 << 9);
		else MY_VGA.Background &= ~(1 << 9);
		if(SW10)MY_VGA.Background |= (1 << 10);
		else MY_VGA.Background &= ~(1 << 10);
		if(SW11)MY_VGA.Background |= (1 << 11);
		else MY_VGA.Background &= ~(1 << 11);
		if(SW12)MY_VGA.Background |= (1 << 12);
		else MY_VGA.Background &= ~(1 << 12);
		if(SW13)MY_VGA.Background |= (1 << 13);
		else MY_VGA.Background &= ~(1 << 13);
		if(SW14)MY_VGA.Background |= (1 << 14);
		else MY_VGA.Background &= ~(1 << 14);
		if(SW15)MY_VGA.Background |= (1 << 15);
		else MY_VGA.Background &= ~(1 << 15);

		//MY_VGA.Background+=0x10;
		//MY_VGA.Y1_Position=10;				// last bit define what will happen		
		//MY_VGA.X1_Position=10;				// last bit define what will happen
	}

	return 0;
}

void Default_Handler(void){
	GPIOB.ODR = 0xFFFF;
}
