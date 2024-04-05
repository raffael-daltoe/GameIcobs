#include "system.h"
#include "pacman.h"
#include <stdbool.h>
#include <stdio.h>

#define _BTNU_MODE GPIOC.MODEbits.P0
#define BTNU GPIOC.IDRbits.P0

#define _BTNL_MODE GPIOC.MODEbits.P1
#define BTNL GPIOC.IDRbits.P1

#define _BTNR_MODE GPIOC.MODEbits.P2
#define BTNR GPIOC.IDRbits.P2

#define _BTND_MODE GPIOC.MODEbits.P3
#define BTND GPIOC.IDRbits.P3

#define _SW0_MODE GPIOA.MODEbits.P0
#define SW0 GPIOA.IDRbits.P0

#define _SW1_MODE GPIOA.MODEbits.P1
#define SW1 GPIOA.IDRbits.P1

#define _SW2_MODE GPIOA.MODEbits.P2
#define SW2 GPIOA.IDRbits.P2

#define _SW3_MODE GPIOA.MODEbits.P3
#define SW3 GPIOA.IDRbits.P3

#define _SW4_MODE GPIOA.MODEbits.P4
#define SW4 GPIOA.IDRbits.P4

#define _SW5_MODE GPIOA.MODEbits.P5
#define SW5 GPIOA.IDRbits.P5

#define _SW6_MODE GPIOA.MODEbits.P6
#define SW6 GPIOA.IDRbits.P6

#define _SW7_MODE GPIOA.MODEbits.P7
#define SW7 GPIOA.IDRbits.P7

#define _SW8_MODE GPIOA.MODEbits.P8
#define SW8 GPIOA.IDRbits.P8

#define _SW9_MODE GPIOA.MODEbits.P9
#define SW9 GPIOA.IDRbits.P9

#define _SW10_MODE GPIOA.MODEbits.P10
#define SW10 GPIOA.IDRbits.P10

#define _SW11_MODE GPIOA.MODEbits.P11
#define SW11 GPIOA.IDRbits.P11

#define _SW12_MODE GPIOA.MODEbits.P12
#define SW12 GPIOA.IDRbits.P12

#define _SW13_MODE GPIOA.MODEbits.P13
#define SW13 GPIOA.IDRbits.P13

#define _SW14_MODE GPIOA.MODEbits.P14
#define SW14 GPIOA.IDRbits.P14

#define _SW15_MODE GPIOA.MODEbits.P15
#define SW15 GPIOA.IDRbits.P15
/*				PROTOTYPES OF FUNCTIONS					*/

//static void moveGhosts(int numGhosts, int posX, int posY, int difficulty);
static void eaten(int i);
static int check_collision(int x, int y);

/*					GLOBAL VARIABLES					*/
int TIMER_FLAG = 0;
Position ghosts[] = {{0,0},{0,0},{0,0},{0,0}};

static void timer_clock_cb(int code)
{
    TIMER_FLAG = 1;
    ((void)code);
}

// static void moveGhosts(int numGhosts, int posX, int posY, int difficulty) {
//     int directions[4][2] = {{0, -1}, {0, 1}, {-1, 0}, {1, 0}}; // Direções: Up, Down, Left, Right

//     for (int i = 0; i < numGhosts; i++) {
//         for (int dir = 0; dir < 4; dir++) {
//             int newPosX = ghosts[i].x + directions[dir][0];
//             int newPosY = ghosts[i].y + directions[dir][1];

//             // Verificar se a nova posição é válida (não há colisões)
//             if (!check_collision(newPosX, newPosY)) {
//                 ghosts[i].x = newPosX;
//                 ghosts[i].y = newPosY;
//                 break; // Mover o fantasma e sair do loop
//             }
//         }
//     }
//     MY_VGA.Y1_Position = ghosts[0].y;    // blue
//     MY_VGA.X1_Position = ghosts[0].x;    // blue
//     MY_VGA.Y2_Position = ghosts[1].y;    // green
//     MY_VGA.X2_Position = ghosts[1].x; // green
//     MY_VGA.Y3_Position = ghosts[2].y;    // pink
//     MY_VGA.X3_Position = ghosts[2].x;    // pink
//     //MY_VGA.Y4_Position = ghosts[3].y;    // something
//     //MY_VGA.X4_Position = ghosts[3].x;    // some color kk
// }

static void init_GPIO_and_UART()
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

    _SW0_MODE = GPIO_MODE_INPUT;
    _SW1_MODE = GPIO_MODE_INPUT;
    _SW2_MODE = GPIO_MODE_INPUT;
    _SW3_MODE = GPIO_MODE_INPUT;
    _SW4_MODE = GPIO_MODE_INPUT;
    _SW5_MODE = GPIO_MODE_INPUT;
    _SW6_MODE = GPIO_MODE_INPUT;
    _SW7_MODE = GPIO_MODE_INPUT;
    _SW8_MODE = GPIO_MODE_INPUT;
    _SW9_MODE = GPIO_MODE_INPUT;
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

    myprintf("\n! The game will start... Haha Loser ! \n");

    set_timer_ms(1000, timer_clock_cb, 0);
}

static void init_Registers()
{
    MY_VGA.Y0_Position = 60;
    MY_VGA.X0_Position = 110;
    MY_VGA.Y1_Position = 200;    // blue
    MY_VGA.X1_Position = 215;    // blue
    MY_VGA.Y2_Position = 360;    // green
    MY_VGA.X2_Position = 320; // green
    MY_VGA.Y3_Position = 200;    // pink
    MY_VGA.X3_Position = 240;    // pink
    MY_VGA.Y4_Position = 500;    // something
    MY_VGA.X4_Position = 320;    // some color kk
    MY_VGA.Background = 0;
    MY_VGA.Register_Foods = 0x0;
    MY_VGA.Scoreboard = 0x0;

    // ghosts[0].x = MY_VGA.X1_Position;
    // ghosts[0].y = MY_VGA.Y1_Position;
    // ghosts[1].x = MY_VGA.X2_Position;
    // ghosts[1].y = MY_VGA.Y2_Position;
    // ghosts[2].x = MY_VGA.X3_Position;
    // ghosts[2].y = MY_VGA.Y3_Position;
    // ghosts[3].x = MY_VGA.X4_Position;
    // ghosts[3].y = MY_VGA.Y4_Position;
    
}

Obstacle obstacles[] = {
    {102,64,197,101},
    {102,64,147,127},
    {271,63,312,127},
    {216,63,312,101},

    {271,141,324,182}, //

    {91,140,148,183},
    {161,115,198,183},
    {216,116,259,183},
    {160,193,259,237},
    {160,195,197,259},
    {221,195,262,263},
    {272,197,315,358},
    {159,319,263,358},

    {159,294,195,358},

    {220,291,263,358},
    
    {198,291,162,358},
    {106,196,143,358},
    {94,371,149,412},
    {271,370,324,412},
    {154,370,198,436},
    {218,369,262,437},
    {270,426,310,491},
    {217,450,310,492},
    {103,449,199,493},
    {103,424,146,493},
    {0,0,93,635},
    {0,504,480,640},
    {324,0,480,640},
    {0,0,324,50}
};

Food_Pos Food[] = {
    {102, 102},
    {153, 108},
    {261, 108},
    {261, 448},
    {153, 447},
    {153, 360}, // 5 eaten(4)
    {266, 360},
    {266, 277},
    {319, 277},
    {98, 277},
    {98, 189},
    {318, 189},
    {318, 360},
    {208, 402},
    {208, 149},
    {208, 499},
    {208, 58},
    {211, 278},
    {211, 244},
    {151, 158},
    {266, 390}};


int obstacle_count = sizeof(obstacles) / sizeof(obstacles[0]);
int food_count = sizeof(Food) / sizeof(Food[0]);

static int check_collision(int x, int y)
{
    for (int i = 0; i < obstacle_count; i++)
    {
        if (x >= obstacles[i].x_min && x <= obstacles[i].x_max &&
            y >= obstacles[i].y_min && y <= obstacles[i].y_max)
        {
            return 1; // Collision detected
        }
    }

    return 0; // none colisão
}

static void verifyEats()
{
    if ((MY_VGA.X0_Position >= Food[0].x - RANGE && MY_VGA.X0_Position <= Food[0].x + RANGE)
    && MY_VGA.Y0_Position >= Food[0].y - RANGE && MY_VGA.Y0_Position <= Food[0].y + RANGE)
        eaten(0);

    if (MY_VGA.X0_Position >= Food[1].x - RANGE && MY_VGA.X0_Position <= Food[1].x + RANGE 
    && MY_VGA.Y0_Position >= Food[1].y - RANGE && MY_VGA.Y0_Position <= Food[1].y + RANGE)
        eaten(1);

    if (MY_VGA.X0_Position >= Food[2].x - RANGE && MY_VGA.X0_Position <= Food[2].x + RANGE 
    && MY_VGA.Y0_Position >= Food[2].y - RANGE && MY_VGA.Y0_Position <= Food[2].y + RANGE)
        eaten(2);

    if (MY_VGA.X0_Position >= Food[3].x - RANGE && MY_VGA.X0_Position <= Food[3].x + RANGE 
    && MY_VGA.Y0_Position >= Food[3].y - RANGE && MY_VGA.Y0_Position <= Food[3].y + RANGE)
        eaten(3);

    if (MY_VGA.X0_Position >= Food[4].x - RANGE && MY_VGA.X0_Position <= Food[4].x + RANGE 
    && MY_VGA.Y0_Position >= Food[4].y - RANGE && MY_VGA.Y0_Position <= Food[4].y + RANGE)
        eaten(4);
    
    if (MY_VGA.X0_Position >= Food[5].x - RANGE && MY_VGA.X0_Position <= Food[5].x + RANGE 
    && MY_VGA.Y0_Position >= Food[5].y - RANGE && MY_VGA.Y0_Position <= Food[5].y + RANGE)
        eaten(5);

    if (MY_VGA.X0_Position >= Food[6].x - RANGE && MY_VGA.X0_Position <= Food[6].x + RANGE 
    && MY_VGA.Y0_Position >= Food[6].y - RANGE && MY_VGA.Y0_Position <= Food[6].y + RANGE)
        eaten(6);

    if (MY_VGA.X0_Position >= Food[7].x - RANGE && MY_VGA.X0_Position <= Food[7].x + RANGE 
    && MY_VGA.Y0_Position >= Food[7].y - RANGE && MY_VGA.Y0_Position <= Food[7].y + RANGE)
        eaten(7);

    if (MY_VGA.X0_Position >= Food[8].x - RANGE && MY_VGA.X0_Position <= Food[8].x + RANGE 
    && MY_VGA.Y0_Position >= Food[8].y - RANGE && MY_VGA.Y0_Position <= Food[8].y + RANGE)
        eaten(8);    

    if (MY_VGA.X0_Position >= Food[9].x - RANGE && MY_VGA.X0_Position <= Food[9].x + RANGE 
    && MY_VGA.Y0_Position >= Food[9].y - RANGE && MY_VGA.Y0_Position <= Food[9].y + RANGE)
        eaten(9);

    if (MY_VGA.X0_Position >= Food[10].x - RANGE && MY_VGA.X0_Position <= Food[10].x + RANGE 
    && MY_VGA.Y0_Position >= Food[10].y - RANGE && MY_VGA.Y0_Position <= Food[10].y + RANGE)
        eaten(10);

    if (MY_VGA.X0_Position >= Food[11].x - RANGE && MY_VGA.X0_Position <= Food[11].x + RANGE 
    && MY_VGA.Y0_Position >= Food[11].y - RANGE && MY_VGA.Y0_Position <= Food[11].y + RANGE)
        eaten(11);

    if (MY_VGA.X0_Position >= Food[12].x - RANGE && MY_VGA.X0_Position <= Food[12].x + RANGE 
    && MY_VGA.Y0_Position >= Food[12].y - RANGE && MY_VGA.Y0_Position <= Food[12].y + RANGE)
        eaten(12);
    
    if (MY_VGA.X0_Position >= Food[13].x - RANGE && MY_VGA.X0_Position <= Food[13].x + RANGE 
    && MY_VGA.Y0_Position >= Food[13].y - RANGE && MY_VGA.Y0_Position <= Food[13].y + RANGE)
        eaten(13);
    
    if (MY_VGA.X0_Position >= Food[14].x - RANGE && MY_VGA.X0_Position <= Food[14].x + RANGE 
    && MY_VGA.Y0_Position >= Food[14].y - RANGE && MY_VGA.Y0_Position <= Food[14].y + RANGE)
        eaten(14);

    if (MY_VGA.X0_Position >= Food[15].x - RANGE && MY_VGA.X0_Position <= Food[15].x + RANGE
    && MY_VGA.Y0_Position >= Food[15].y - RANGE && MY_VGA.Y0_Position <= Food[15].y + RANGE)
        eaten(15);
    
    if (MY_VGA.X0_Position >= Food[16].x - RANGE && MY_VGA.X0_Position <= Food[16].x + RANGE 
    && MY_VGA.Y0_Position >= Food[16].y - RANGE && MY_VGA.Y0_Position <= Food[16].y + RANGE)
        eaten(16);

    if (MY_VGA.X0_Position >= Food[17].x - RANGE && MY_VGA.X0_Position <= Food[17].x + RANGE 
    && MY_VGA.Y0_Position >= Food[17].y - RANGE && MY_VGA.Y0_Position <= Food[17].y + RANGE)
        eaten(17);

    if (MY_VGA.X0_Position >= Food[18].x - RANGE && MY_VGA.X0_Position <= Food[18].x + RANGE 
    && MY_VGA.Y0_Position >= Food[18].y - RANGE && MY_VGA.Y0_Position <= Food[18].y + RANGE)
        eaten(18);
    
    if (MY_VGA.X0_Position >= Food[19].x - RANGE && MY_VGA.X0_Position <= Food[19].x + RANGE 
    && MY_VGA.Y0_Position >= Food[19].y - RANGE && MY_VGA.Y0_Position <= Food[19].y + RANGE)
        eaten(19);
    
    if (MY_VGA.X0_Position >= Food[20].x - RANGE && MY_VGA.X0_Position <= Food[20].x + RANGE 
    && MY_VGA.Y0_Position >= Food[20].y - RANGE && MY_VGA.Y0_Position <= Food[20].y + RANGE)
        eaten(20);
    
}

static void verifySwitchBackground()
{
    if (SW0)
        MY_VGA.Background |= (1 << 0);
    else
        MY_VGA.Background &= ~(1 << 0);
    if (SW1)
        MY_VGA.Background |= (1 << 1);
    else
        MY_VGA.Background &= ~(1 << 1);
    if (SW2)
        MY_VGA.Background |= (1 << 2);
    else
        MY_VGA.Background &= ~(1 << 2);
    if (SW3)
        MY_VGA.Background |= (1 << 3);
    else
        MY_VGA.Background &= ~(1 << 3);
    if (SW4)
        MY_VGA.Background |= (1 << 4);
    else
        MY_VGA.Background &= ~(1 << 4);
    if (SW5)
        MY_VGA.Background |= (1 << 5);
    else
        MY_VGA.Background &= ~(1 << 5);
    if (SW6)
        MY_VGA.Background |= (1 << 6);
    else
        MY_VGA.Background &= ~(1 << 6);
    if (SW7)
        MY_VGA.Background |= (1 << 7);
    else
        MY_VGA.Background &= ~(1 << 7);
    if (SW8)
        MY_VGA.Background |= (1 << 8);
    else
        MY_VGA.Background &= ~(1 << 8);
    if (SW9)
        MY_VGA.Background |= (1 << 9);
    else
        MY_VGA.Background &= ~(1 << 9);
    if (SW10)
        MY_VGA.Background |= (1 << 10);
    else
        MY_VGA.Background &= ~(1 << 10);
    if (SW11)
        MY_VGA.Background |= (1 << 11);
    else
        MY_VGA.Background &= ~(1 << 11);
    if (SW12)
        MY_VGA.Background |= (1 << 12);
    else
        MY_VGA.Background &= ~(1 << 12);
    if (SW13)
        MY_VGA.Background |= (1 << 13);
    else
        MY_VGA.Background &= ~(1 << 13);
    if (SW14)
        MY_VGA.Background |= (1 << 14);
    else
        MY_VGA.Background &= ~(1 << 14);
    if (SW15)
        MY_VGA.Background |= (1 << 15);
    else
        MY_VGA.Background &= ~(1 << 15);
}

static void verifyButtons()
{
    if (BTNR)
    {
        if (!check_collision(MY_VGA.X0_Position, MY_VGA.Y0_Position + 1))
        {
            MY_VGA.Y0_Position++;
           // myprintf("X = [%d]  |  Y = [%d]\n", MY_VGA.X0_Position, MY_VGA.Y0_Position);
        }
    }
    if (BTNL)
    {
        if (!check_collision(MY_VGA.X0_Position, MY_VGA.Y0_Position - 1))
        {
            MY_VGA.Y0_Position--;
           // myprintf("X = [%d]  |  Y = [%d]\n", MY_VGA.X0_Position, MY_VGA.Y0_Position);
        }
    }
    if (BTND)
    {
        if (!check_collision(MY_VGA.X0_Position + 1, MY_VGA.Y0_Position))
        {
            MY_VGA.X0_Position++;
            //myprintf("X = [%d]  |  Y = [%d]\n", MY_VGA.X0_Position, MY_VGA.Y0_Position);
        }
    }

    if (BTNU)
    {
        if (!check_collision(MY_VGA.X0_Position - 1, MY_VGA.Y0_Position))
        {
            MY_VGA.X0_Position--;
            //myprintf("X = [%d]  |  Y = [%d]\n", MY_VGA.X0_Position, MY_VGA.Y0_Position);
        }
    }
}

static void eaten(int i)
{
    if (!(MY_VGA.Register_Foods & (1 << i)))  // if the food isn't eaten yet
    {
        MY_VGA.Register_Foods |= (1 << i);  // Define the bit to mark the food
        MY_VGA.Scoreboard++;             
    }   
}

//          ________________________________________________________
//        ._|                TABLE OF REGISTERS                    |_.
////////////////////////////////////////////////////////////////////////////////
//  -----------------                                                         //
//  |  X0,Y0        |       PACMAN - MOVEMENT                                 //
//  |  X1,Y1        |       GHOST0                                            //
//  |  X2,Y2        |       GHOST1                                            //
//  |  X3,Y3        |       GHOST2                                            //
//  |  X4,Y4        |       GHOST3                                            //
//  |  Scoreboard   |       Score on 7SEG                                     //
//  | Register_Foods|       Register of foods                                 //
//  |  BACKGROUND   |       SW                                                //
//  -----------------                                                         //
////////////////////////////////////////////////////////////////////////////////
int main(void)
{
    init_GPIO_and_UART();
    init_Registers();

    while (true)
    {
        //moveGhosts(4, MY_VGA.X0_Position, MY_VGA.Y0_Position, 3);
        delay_ms(1);
        verifyButtons();
        verifyEats();
        verifySwitchBackground();
    }

    return 0;
}

void Default_Handler(void)
{
    GPIOB.ODR = 0xFFFF;
}
