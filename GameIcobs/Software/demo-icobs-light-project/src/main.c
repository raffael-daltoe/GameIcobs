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
#include "pacman.h"

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

/*				PROTOTYPES OF FUNCTIONS					*/

static  void countPoints(char maze[10][20]);
static  void movementPacman(char maze[10][20], __uint8_t *posX,
                                             __uint8_t *posY, char movement);
static   __uint8_t isPositionOccupiedByGhost(Position ghosts[], 
                                __uint8_t numGhosts, __uint8_t x, __uint8_t y);	
static  __uint8_t verifyCollision(Position ghost[], __uint8_t numGhosts, 
                                                __uint8_t posX, __uint8_t posY);
static  void moveGhosts(char maze[10][20], Position ghosts[],
     __uint8_t numGhosts, __uint8_t posX, __uint8_t posY, __uint8_t difficulty);

/*					GLOBAL VARIABLES					*/
int TIMER_FLAG = 0;
__uint8_t points = 0;
__uint8_t totalPoints = 0;
__uint8_t running = 1;


static void timer_clock_cb(int code)
{
	TIMER_FLAG=1;
	((void)code);
}

static  void countPoints(char maze[10][20])
{
    for (__uint8_t i = 0; i < 10; i++)
    {
        for (__uint8_t j = 0; j < 20; j++)
        {
            if (maze[i][j] == '.')
            {
                totalPoints++;
            }
        }
    }
}

static  void movementPacman(char maze[10][20], __uint8_t *posX,
                                             __uint8_t *posY, char movement)
{
    __uint8_t newPosX = *posX, newPosY = *posY;

    switch (movement)
    {
    case 'w':
        newPosY--;
        break;
    case 's':
        newPosY++;
        break;
    case 'a':
        newPosX--;
        break;
    case 'd':
        newPosX++;
        break;
    default:
        printf("Invalid key.\n");
        return;
    }

    // To Verify if the next pos is a wall or ghost
    if (maze[newPosY][newPosX] == 'X')
    {
        printf("Invalid Movement ! Wall .\n");
        return;
    }

    // To verify if the next position have a point
    if (maze[newPosY][newPosX] == '.')
    {
        points++; // collect the point

        maze[newPosY][newPosX] = ' '; // Remove de point of maze
    }

    // Update the pos of PACMAN
    *posX = newPosX;
    *posY = newPosY;
}

static   __uint8_t isPositionOccupiedByGhost(Position ghosts[], 
                                __uint8_t numGhosts, __uint8_t x, __uint8_t y)
{
    for (__uint8_t i = 0; i < numGhosts; i++)
    {
        if (ghosts[i].x == x && ghosts[i].y == y)
        {
            return 1; // Busy Position
        }
    }
    return 0; // Free Position
}

static  void moveGhosts(char maze[10][20], Position ghosts[],
     __uint8_t numGhosts, __uint8_t posX, __uint8_t posY, __uint8_t difficulty)
{
    for (__uint8_t i = 0; i < numGhosts; i++)
    {
        __uint8_t movement;
        __uint8_t newPosX = ghosts[i].x;
        __uint8_t newPosY = ghosts[i].y;

        if (difficulty == 1)
        { // Easy : random movement
            movement = rand() % 4;
        }
        else if (difficulty == 2)
        { // Medium : occasionally movement in direction to PACMAN
            if (rand() % 4){ // 75% of chance of random movement, 25% of chance
                                                            // to follow PACMAN
                movement = rand() % 4;
            }
            else
            {
                if (abs(ghosts[i].x - posX) > abs(ghosts[i].y - posY))
                {
                    movement = ghosts[i].x > posX ? 2 : 3; // left or right
                }
                else
                {
                    movement = ghosts[i].y > posY ? 0 : 1; // above or below
                }
            }
        }
        else
        { // Hard : movement smartest in direction to PACMAN
            if (rand() % 2)
            {                            // Alternance between axes X or Y
                movement = newPosX > posX ? 2 : 3; // Left or Right 
            }
            else
            {
                movement = newPosY > posY ? 0 : 1; //  above or below
            }
        }

        switch (movement)
        {
        case 0:
            newPosY--;
            break;
        case 1:
            newPosY++;
            break;
        case 2:
            newPosX--;
            break;
        case 3:
            newPosX++;
            break;
        }

        // Verify if is valid the position of the ghost
        if (maze[newPosY][newPosX] != 'X' && !isPositionOccupiedByGhost(ghosts, 
                                                   numGhosts, newPosX, newPosY))
        {
            ghosts[i].x = newPosX;
            ghosts[i].y = newPosY;
        }
    }
}

static  __uint8_t verifyCollision(Position ghost[], __uint8_t numGhosts, 
                                                __uint8_t posX, __uint8_t posY)
{
    for (__uint8_t i = 0; i < numGhosts; i++)
    {
        if (ghost[i].x == posX && ghost[i].y == posY)
        {
            return 1; // Collision detected
        }
    }
    return 0; // without collisions
}

static void init_GPIO_and_UART(){
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
}

static void init_Registers(){
    MY_VGA.Y0_Position=20;
	MY_VGA.X0_Position=20;
    MY_VGA.Y1_Position=55;
    MY_VGA.X1_Position=55;
    MY_VGA.Y2_Position=200;
    MY_VGA.X2_Position=200;
    MY_VGA.Y3_Position=300;
    MY_VGA.X3_Position=300;
    MY_VGA.Y4_Position=160;
    MY_VGA.X4_Position=160;
    MY_VGA.Y5_Position=0;
    MY_VGA.X5_Position=0;
    MY_VGA.Background=0;
}
//          ________________________________________________________
//        ._|                TABLE OF REGISTERS                    |_.
////////////////////////////////////////////////////////////////////////////////
//  -----------------                                                         //
//  |  X0,Y0        |       PACMAN                                            //
//  |  X1,Y1        |       GHOST1                                            //
//  |  X2,Y2        |       GHOST2                                            //
//  |  X3,Y3        |       GHOST3                                            //
//  |  X4,Y4        |       GHOST4                                            //
//  |  X5,Y5        |       MAP                                               //
//  |  BACKGROUND   |       ANYTHING                                          //
//  -----------------                                                         //
////////////////////////////////////////////////////////////////////////////////
int main(void)
{
	init_GPIO_and_UART();
	init_Registers();

	MY_VGA.X2_Position=320;
	MY_VGA.Y2_Position=400;
	while(1){
        //delay_ms(0.000001);
        MY_VGA.X5_Position+=1;
        MY_VGA.Y5_Position+=1;
        
		//delay_ms(1);
    // Mover para a direita, garantindo que não ultrapasse a borda esquerda da segunda imagem
    if(BTNR && MY_VGA.X1_Position < 558) {
        if(!(MY_VGA.X1_Position + 80 >= MY_VGA.X2_Position && MY_VGA.X1_Position < MY_VGA.X2_Position + 90 && 
        ((MY_VGA.Y1_Position + 90 > MY_VGA.Y2_Position && MY_VGA.Y1_Position < MY_VGA.Y2_Position + 90) || 
        (MY_VGA.Y1_Position < MY_VGA.Y2_Position + 90 && MY_VGA.Y1_Position + 90 > MY_VGA.Y2_Position)))) {
            MY_VGA.X1_Position++;
        }
    }


    // Mover para a esquerda, garantindo que não ultrapasse a borda direita da segunda imagem
    if(BTNL && MY_VGA.X1_Position > 0) {
        if(!(MY_VGA.X1_Position <= MY_VGA.X2_Position + 90 && MY_VGA.X1_Position + 80 > MY_VGA.X2_Position && 
        ((MY_VGA.Y1_Position + 90 > MY_VGA.Y2_Position && MY_VGA.Y1_Position < MY_VGA.Y2_Position + 90) || 
        (MY_VGA.Y1_Position < MY_VGA.Y2_Position + 90 && MY_VGA.Y1_Position + 90 > MY_VGA.Y2_Position)))) {
            MY_VGA.X1_Position--;
        }
    }

    // Mover para cima, garantindo que não ultrapasse a borda inferior da segunda imagem
    if(BTNU && MY_VGA.Y1_Position > 0) {
        if(!(MY_VGA.Y1_Position <= MY_VGA.Y2_Position + 90 && MY_VGA.Y1_Position + 90 > MY_VGA.Y2_Position && 
        ((MY_VGA.X1_Position + 80 > MY_VGA.X2_Position && MY_VGA.X1_Position < MY_VGA.X2_Position + 90) || 
        (MY_VGA.X1_Position < MY_VGA.X2_Position + 90 && MY_VGA.X1_Position + 80 > MY_VGA.X2_Position)))) {
            MY_VGA.Y1_Position--;
        }
    }

    // Mover para baixo, garantindo que não ultrapasse a borda superior da segunda imagem
    if(BTND && MY_VGA.Y1_Position < 390) {
        if(!(MY_VGA.Y1_Position + 90 >= MY_VGA.Y2_Position && MY_VGA.Y1_Position < MY_VGA.Y2_Position + 90 && 
        ((MY_VGA.X1_Position + 80 > MY_VGA.X2_Position && MY_VGA.X1_Position < MY_VGA.X2_Position + 90) || 
        (MY_VGA.X1_Position < MY_VGA.X2_Position + 90 && MY_VGA.X1_Position + 80 > MY_VGA.X2_Position)))) {
            MY_VGA.Y1_Position++;
        }
    }



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

	}

	return 0;
}

void Default_Handler(void){
	GPIOB.ODR = 0xFFFF;
}


