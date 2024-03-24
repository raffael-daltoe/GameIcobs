/**
 * UART library
 * author: Guillaume Patrigeon - Theo Soriano
 * update: 16-08-2019
 */

#ifndef __UART_H__
#define	__UART_H__

#ifdef __cplusplus
extern "C"{
#endif

//--------------------------------------------------------
int UART1_get_TxCount (void);

/// Initialize UART1 module
void UART1_Init(unsigned int baudrate);

/// Enable UART1 module
#define UART1_Enable()       UART1.PE = 1

/// Disable UART1 module
#define UART1_Disable()      UART1.PE = 0

/// Empty both TX and RX buffers
void UART1_Clean(void);

/// Check if there is data in RX buffer, return 1 if there is at last 1 byte in buffer
int UART1_IsRxNotEmpty(void);

/// Read the first byte from RX buffer
char UART1_Read(void);

/// Write a byte into TX buffer
void UART1_Write(const char c);

#ifdef __cplusplus
}
#endif

#endif
