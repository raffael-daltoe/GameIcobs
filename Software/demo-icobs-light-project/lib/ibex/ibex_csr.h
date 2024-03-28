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
// ibex_csr.h
// Author: Soriano Theo
// Update: 23-09-2020
//-----------------------------------------------------------

#ifndef __IBEX_CSR_H__
#define	__IBEX_CSR_H__

#define _WFI() asm("wfi")

#define IBEX_ENABLE_INTERRUPTS   asm("csrr t0, mstatus\nor t0, t0, 8\ncsrw mstatus, t0")
#define IBEX_DISABLE_INTERRUPTS  asm("csrr t0, mstatus\nor t0, t0, 8\nxor t0, t0, 8\ncsrw mstatus, t0")

#define _IBEX_INTERRUPT(line)    #line
#define IBEX_SET_INTERRUPT(line) asm("csrr t0, mie\nli t1, 1\nsll t1, t1, " _IBEX_INTERRUPT(line) "\nor t0, t0, t1\ncsrw mie, t0")
#define IBEX_CLR_INTERRUPT(line) asm("csrr t0, mie\nli t1, 1\nsll t1, t1, " _IBEX_INTERRUPT(line) "\nor t0, t0, t1\nxor t0, t0, t1\ncsrw mie, t0")

#define IBEX_INT_SOFTINT         3
#define IBEX_INT_SYSTIMER        7
#define IBEX_INT_EXTINT          11

#define IBEX_INT_TIMER1          16
#define IBEX_INT_TIMER2          17
#define IBEX_INT_TIMER3          18
#define IBEX_INT_TIMER4          19

#define IBEX_INT_UART1           20
#define IBEX_INT_UART2           21
#define IBEX_INT_UART3           22
#define IBEX_INT_UART4           23

#define IBEX_INT_SPI1            24
#define IBEX_INT_SPI2            25

#define IBEX_INT_I2C1            26
#define IBEX_INT_I2C2            27

#define IBEX_INT_DMA             28
#define IBEX_INT_VDMA            29

#define TIMER1_IRQHandler        IRQ_00_Handler
#define TIMER2_IRQHandler        IRQ_01_Handler
#define TIMER3_IRQHandler        IRQ_02_Handler
#define TIMER4_IRQHandler        IRQ_03_Handler

#define UART1_IRQHandler         IRQ_04_Handler
#define UART2_IRQHandler         IRQ_05_Handler
#define UART3_IRQHandler         IRQ_06_Handler
#define UART4_IRQHandler         IRQ_07_Handler

#define SPI1_IRQHandler          IRQ_08_Handler
#define SPI2_IRQHandler          IRQ_09_Handler

#define I2C1_IRQHandler          IRQ_10_Handler
#define I2C2_IRQHandler          IRQ_11_Handler

#define DMA_IRQHandler           IRQ_12_Handler

#define VDMA_IRQHandler           IRQ_13_Handler

#endif
