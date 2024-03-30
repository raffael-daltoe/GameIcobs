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
// system.h
// Author: Soriano Theo
// Update: 07-06-2022
//-----------------------------------------------------------


#ifndef __SYSTEM_H__
#define __SYSTEM_H__

// Architecture definition
#include <arch.h>
#include <ibex_csr.h>

// ----------------------------------------------------------------------------
// System clock frequency (in Hz)
#define SYSCLK                  50000000

// UART1 configuration
#define UART1_TXBUFFERSIZE      256
#define UART1_RXBUFFERSIZE      256

#define _LD0_MODE   GPIOB.MODEbits.P0
#define LD0         GPIOB.ODRbits.P0
#define _LD1_MODE   GPIOB.MODEbits.P1
#define LD1         GPIOB.ODRbits.P1
#define _LD2_MODE   GPIOB.MODEbits.P2
#define LD2         GPIOB.ODRbits.P2
#define _LD3_MODE   GPIOB.MODEbits.P3
#define LD3         GPIOB.ODRbits.P3
#define _LD4_MODE   GPIOB.MODEbits.P4
#define LD4         GPIOB.ODRbits.P4
#define _LD5_MODE   GPIOB.MODEbits.P5
#define LD5         GPIOB.ODRbits.P5
#define _LD6_MODE   GPIOB.MODEbits.P6
#define LD6         GPIOB.ODRbits.P6
#define _LD7_MODE   GPIOB.MODEbits.P7
#define LD7         GPIOB.ODRbits.P7
#define _LD8_MODE   GPIOB.MODEbits.P8
#define LD8         GPIOB.ODRbits.P8
#define _LD9_MODE   GPIOB.MODEbits.P9
#define LD9         GPIOB.ODRbits.P9
#define _LD10_MODE  GPIOB.MODEbits.P10
#define LD10        GPIOB.ODRbits.P10
#define _LD11_MODE  GPIOB.MODEbits.P11
#define LD11        GPIOB.ODRbits.P11
#define _LD12_MODE  GPIOB.MODEbits.P12
#define LD12        GPIOB.ODRbits.P12
#define _LD13_MODE  GPIOB.MODEbits.P13
#define LD13        GPIOB.ODRbits.P13
#define _LD14_MODE  GPIOB.MODEbits.P14
#define LD14        GPIOB.ODRbits.P14
#define _LD15_MODE  GPIOB.MODEbits.P15
#define LD15        GPIOB.ODRbits.P15

// ----------------------------------------------------------------------------
// Application headers
#include <ascii.h>
#include <ansi.h>
#include <print.h>
#include <types.h>
#include <crc8.h>
#include <uart.h>
#include <timer.h>
#include <serial.h>

// Printf-like function (does not support all formats...)
#define myprintf(...)             print(UART1_Write, __VA_ARGS__)

void SystemInit(void);

#endif
