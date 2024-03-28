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
// Update: 23-09-2020
//-----------------------------------------------------------

#ifndef __SYSTEM_H__
#define __SYSTEM_H__

// Architecture definition
#include <arch.h>
#include <ibex_csr.h>

// UART1 configuration
#define UART1_TXBUFFERSIZE      128
#define UART1_RXBUFFERSIZE      32

// ----------------------------------------------------------------------------
// Application headers
#include <ascii.h>
#include <ansi.h>
#include <print.h>
#include <types.h>
#include <uart.h>
#include <timer.h>

// Printf-like function (does not support all formats...)
#define myprintf(...)             print(UART1_Write, __VA_ARGS__)

#endif
