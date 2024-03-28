#ifndef __ARCH_MY_VGA_H__
#define __ARCH_MY_VGA_H__

typedef struct{
    volatile unsigned int Background;
    volatile unsigned int Y1_Position;
    volatile unsigned int X1_Position;
    volatile unsigned int Y2_Position;
    volatile unsigned int X2_Position;
    
} MY_VGA_t;

#endif
