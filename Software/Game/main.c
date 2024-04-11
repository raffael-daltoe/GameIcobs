#include "system.h"
#include "pacman.h"
#include <stdbool.h>
#include <stdio.h>
#include <limits.h>

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

#define TRIES 50
/*				PROTOTYPES OF FUNCTIONS					*/
static void timer_clock_cb(int code);
uint8_t simple_rand(uint8_t seed);
static bool isPositionOccupiedByGhost(volatile unsigned int x, volatile unsigned int y);
static bool isAreaFree(int newX, int newY, uint8_t currentGhostIndex);
void moveGhostsAutomatically(uint8_t seed);
static void init_GPIO_and_UART();
static void init_Registers();
static int check_collision(int x, int y);
static void verifyEats();
static void verifySwitchBackground();
static void verifyButtons();
static void eaten(int i);
uint32_t digitTo7Segment(int digit);
static void updateScoreboard(int score);
static void Winner();
static void Loser();

/*					GLOBAL VARIABLES					*/
int TIMER_FLAG = 0;
Position ghosts[] = {{0,0},{0,0},{0,0},{0,0}};
int Scoreboard;
bool difficulty;
static void timer_clock_cb(int code)
{
    TIMER_FLAG = 1;
    ((void)code);
}

uint8_t simple_rand(uint8_t seed) {
    uint8_t random = seed;
    random ^= random << 3;
    random ^= random >> 5;
    random ^= random << 4;
    return random;
}

static bool isPositionOccupiedByGhost(volatile unsigned int x, volatile unsigned int y)
{
    for (__uint8_t i = 0; i < GHOSTS; i++)
    {
        if (x == ghosts[i].x && y == ghosts[i].y)

        {
            return true; // Busy Position
        }
    }
    return false; // Free Position
}

static bool isAreaFree(int newX, int newY, uint8_t currentGhostIndex) {
    for (uint8_t i = 0; i < GHOSTS; i++) {
        if (i != currentGhostIndex) {
            // Define the boundaries for the current ghost's prospective area
            int newLeft = newX, newRight = newX + SIZE_X_GHOST, newTop = newY, newBottom = newY + SIZE_Y_GHOST;

            // Define the boundaries for the other ghost's current area
            int otherLeft = ghosts[i].x, otherRight = ghosts[i].x + SIZE_X_GHOST;
            int otherTop = ghosts[i].y, otherBottom = ghosts[i].y + SIZE_Y_GHOST;

            // Check for overlap with any other ghost
            if (newLeft < otherRight && newRight > otherLeft && newTop < otherBottom && newBottom > otherTop) {
                return false; // Overlap detected
            }
        }
    }
    return true;
}

void moveGhostsAutomatically(uint8_t seed) {
    //uint8_t difficulty = 2; 
    difficulty = ((MY_VGA.Background >> 12) & 1);
    for (uint8_t i = 0; i < GHOSTS; i++)
    {
        uint8_t movement = simple_rand(seed) % 4;
        volatile unsigned int newPosX = ghosts[i].x;
        volatile unsigned int newPosY = ghosts[i].y;

        if (difficulty == 0)
        { // Medium : occasionally movement in direction to PACMAN
            if (simple_rand(seed) % 4){ // 75% of chance of random movement, 25% of chance
                                                            // to follow PACMAN
                movement = simple_rand(seed) % 4;
            }
            else
            {
                if ( MY_VGA.X0_Position - ghosts[i].x >=  MY_VGA.Y0_Position - ghosts[i].y)
                {
                    movement = ghosts[i].x > MY_VGA.X0_Position ? 2 : 3; // left or right
                }
                else
                {
                    movement = ghosts[i].y > MY_VGA.Y0_Position ? 0 : 1; // above or below
                }
            }
        }
        else
        { // Hard : movement smartest in direction to PACMAN
            if (simple_rand(seed) % 2)
            {                            // Alternance between axes X or Y
                movement = newPosX > MY_VGA.X0_Position ? 2 : 3; // Left or Right 
            }
            else
            {
                movement = newPosY > MY_VGA.Y0_Position ? 0 : 1; //  above or below
            }
        }

        switch (movement)
        {
        case 0:
            newPosY-=1;
            break;
        case 1:
            newPosY+=1;
            break;
        case 2:
            newPosX-=1;
            break;
        case 3:
            newPosX+=1;
            break;
        }

        if(!check_collision(newPosX,newPosY) && isAreaFree(newPosX, newPosY, i) &&
        (newPosX >=94 &&  newPosX <= 323 && newPosY >= 52 && newPosY <= 503)){
            ghosts[i].x = newPosX;
            ghosts[i].y = newPosY;
            switch (i)
            {
            case 0:
                MY_VGA.X1_Position = ghosts[0].x; 
                MY_VGA.Y1_Position = ghosts[0].y;
                break;
            case 1:
                MY_VGA.X2_Position = ghosts[1].x; 
                MY_VGA.Y2_Position = ghosts[1].y;
                break;     
            case 2:
                MY_VGA.X3_Position = ghosts[2].x; 
                MY_VGA.Y3_Position = ghosts[2].y;
                break;
            case 3:
                MY_VGA.X4_Position = ghosts[3].x; 
                MY_VGA.Y4_Position = ghosts[3].y;
                break;
            }
        }
    }
    if(isPositionOccupiedByGhost(MY_VGA.X0_Position,MY_VGA.Y0_Position) == true)
        Loser();
}

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

    //myprintf("\n! The game will start... Haha Loser ! \n");

    set_timer_ms(1000, timer_clock_cb, 0);
}

static void init_Registers()
{
    MY_VGA.Y0_Position = 60;
    MY_VGA.X0_Position = 110;
    MY_VGA.Y1_Position = 242;    // blue
    MY_VGA.X1_Position = 205;    // blue
    MY_VGA.Y2_Position = 446;    // green
    MY_VGA.X2_Position = 263;    // green
    MY_VGA.Y3_Position = 370;    // pink
    MY_VGA.X3_Position = 190;    // pink
    MY_VGA.Y4_Position = 443;    // some color  
    MY_VGA.X4_Position = 153;    // some color
    MY_VGA.Background = 0;
    MY_VGA.Register_Foods = 0x0;
    MY_VGA.Status = 0x0;
    Scoreboard = 0x0;
    difficulty = 0;
    ghosts[0].x = MY_VGA.X1_Position;
    ghosts[0].y = MY_VGA.Y1_Position;
    ghosts[1].x = MY_VGA.X2_Position;
    ghosts[1].y = MY_VGA.Y2_Position;
    ghosts[2].x = MY_VGA.X3_Position;
    ghosts[2].y = MY_VGA.Y3_Position;
    ghosts[3].x = MY_VGA.X4_Position;
    ghosts[3].y = MY_VGA.Y4_Position;
    
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

    return 0; // none collision
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
                    //moveGhostsAutomatically(rand);
            MY_VGA.Y0_Position++;
            myprintf("X = [%d]  |  Y = [%d]\n", MY_VGA.X0_Position, MY_VGA.Y0_Position);
        }
    }
    if (BTNL)
    {
        if (!check_collision(MY_VGA.X0_Position, MY_VGA.Y0_Position - 1))
        {
                    //moveGhostsAutomatically(rand);
            MY_VGA.Y0_Position--;
            myprintf("X = [%d]  |  Y = [%d]\n", MY_VGA.X0_Position, MY_VGA.Y0_Position);
        }
    }
    if (BTND)
    {
        if (!check_collision(MY_VGA.X0_Position + 1, MY_VGA.Y0_Position))
        {
                    //moveGhostsAutomatically(rand);
            MY_VGA.X0_Position++;
            myprintf("X = [%d]  |  Y = [%d]\n", MY_VGA.X0_Position, MY_VGA.Y0_Position);
        }
    }

    if (BTNU)
    {
        if (!check_collision(MY_VGA.X0_Position - 1, MY_VGA.Y0_Position))
        {
           // moveGhostsAutomatically(rand);
            MY_VGA.X0_Position--;
            myprintf("X = [%d]  |  Y = [%d]\n", MY_VGA.X0_Position, MY_VGA.Y0_Position);
        }
    }
}


static void eaten(int i)
{
    if (!(MY_VGA.Register_Foods & (1 << i)))  // if the food isn't eaten yet
    {
        MY_VGA.Register_Foods |= (1 << i);  // Define the bit to mark the food
        Scoreboard++;             
    }   
}

uint32_t digitTo7Segment(int digit) {
    switch (digit) {
        case 0: return 0;
        case 1: return 1;
        case 2: return 2;
        case 3: return 3;
        case 4: return 4;
        case 5: return 5;
        case 6: return 6;
        case 7: return 7;
        case 8: return 8;
        case 9: return 9;
        default: return 0; // For unexpected input
    }
}

static void updateScoreboard(int score)
{
    // Assume each digit D3 D2 D1 D0 corresponds to MY_VGA.REG4, MY_VGA.REG3, MY_VGA.REG2, MY_VGA.REG1 respectively

    int digits[4] = {0}; // To hold each digit of the score

    // Extract each digit from the score
    for (int i = 0; i < 4; i++) {
        digits[i] = score % 10;
        score /= 10;
    }

    // Convert each digit to its 7-segment display equivalent and store it in the corresponding register
    // Assuming a function digitTo7Segment() converts a digit to its 7-segment representation
    MY_VGA.Score1 = digitTo7Segment(digits[0]);
    MY_VGA.Score2 = digitTo7Segment(digits[1]);
    MY_VGA.Score3 = digitTo7Segment(digits[2]);
    MY_VGA.Score4 = digitTo7Segment(digits[3]);
}

static void Loser(){
    MY_VGA.Status |= (1 << 0);
    exit(0);
}

static void Winner(){
    MY_VGA.Status |= (1 << 1);
    exit(0);
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
//  |  Score1       |       Score[0] on 7SEG                                  //
//  |  Score2       |       Score[1] on 7SEG                                  //
//  |  Score3       |       Score[2] on 7SEG                                  //
//  |  Score4       |       Score[3] on 7SEG                                  //
//  |  Status       |       WIN OR LOSE                                       //
//  | Register_Foods|       Register of foods                                 //
//  |  BACKGROUND   |       SW                                                //
//  -----------------                                                         //
////////////////////////////////////////////////////////////////////////////////
int main(void)
{
    init_GPIO_and_UART();
    init_Registers();
    uint8_t rand = 95;
    while (true)
    {
        if(Scoreboard == 21) Winner(); 
        rand++;
        delay_ms(1);
        moveGhostsAutomatically(rand);
        verifyButtons();
        verifyEats();
        updateScoreboard(Scoreboard);
        verifySwitchBackground();
    }

    return 0;
}

void Default_Handler(void)
{
    GPIOB.ODR = 0xFFFF;
}
