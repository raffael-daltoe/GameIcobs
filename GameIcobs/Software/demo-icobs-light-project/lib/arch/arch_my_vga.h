#ifndef __ARCH_MY_VGA_H__
#define __ARCH_MY_VGA_H__

typedef struct{
    volatile unsigned int Background;
    volatile unsigned int X0_Position; 
	volatile unsigned int Y0_Position; 					
    volatile unsigned int X1_Position; 
	volatile unsigned int Y1_Position; 
	volatile unsigned int X2_Position; 
	volatile unsigned int Y2_Position; 
    volatile unsigned int X3_Position; 
	volatile unsigned int Y3_Position; 
	volatile unsigned int X4_Position; 
	volatile unsigned int Y4_Position; 
	volatile unsigned int Register_Foods;
} MY_VGA_t;

#endif