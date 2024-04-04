#ifndef __PACMAN_H_
#define __PACMAN_H_

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <inttypes.h>

#define RANGE 20


typedef struct
{
    __uint8_t x;
    __uint8_t y;
} Position;

typedef struct
{
    int x_min;
    int y_min;
    int x_max;
    int y_max;
} Obstacle;

typedef struct 
{
    int x;
    int y;
}Food_Pos;

#endif