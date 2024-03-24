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
// Update: 07-06-2022
//-----------------------------------------------------------

#ifndef __IBEX_CSR_H__
#define	__IBEX_CSR_H__

#define _WFI() asm("wfi")

#define IBEX_ENABLE_INTERRUPTS   asm volatile("csrr t0, mstatus\nor t0, t0, 8\ncsrw mstatus, t0")
#define IBEX_DISABLE_INTERRUPTS  asm volatile("csrr t0, mstatus\nor t0, t0, 8\nxor t0, t0, 8\ncsrw mstatus, t0")

#define _IBEX_INTERRUPT(line)    #line
#define IBEX_SET_INTERRUPT(line) asm volatile("csrr t0, mie\nli t1, 1\nsll t1, t1, " _IBEX_INTERRUPT(line) "\nor t0, t0, t1\ncsrw mie, t0")
#define IBEX_CLR_INTERRUPT(line) asm volatile("csrr t0, mie\nli t1, 1\nsll t1, t1, " _IBEX_INTERRUPT(line) "\nor t0, t0, t1\nxor t0, t0, t1\ncsrw mie, t0")

#define IBEX_INT_SOFTINT         3
#define IBEX_INT_SYSTIMER        7
#define IBEX_INT_EXTINT          11

#define IBEX_INT_TIMER1          16

#define IBEX_INT_UART1           20


#define TIMER1_IRQHandler        IRQ_00_Handler

#define UART1_IRQHandler         IRQ_04_Handler

#endif
