#ifndef __PACMAN_H_
#define __PACMAN_H_

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <inttypes.h>
#define MAX_X 321
#define MIN_X 92
#define MAX_Y 503
#define MIN_Y 50

#define RANGE 20
#define GHOSTS 4

#define SIZE_X_GHOST 24
#define SIZE_Y_GHOST 24

typedef struct
{
    volatile unsigned int x;
    volatile unsigned int y;
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