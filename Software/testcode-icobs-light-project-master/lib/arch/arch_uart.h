/**
 * author: Guillaume Patrigeon
 * update: 16-10-2018
 */

#ifndef __ARCH_UART_H__
#define __ARCH_UART_H__



typedef struct
{
	volatile unsigned int DATA;

	union
	{
		const volatile unsigned int STATUS;         // Status register

		struct
		{
			const volatile unsigned int :1;
			const volatile unsigned int RXBF:1;     // Receive Buffer Full flag
			const volatile unsigned int TXBE:1;     // Transmit Buffer Empty flag
			const volatile unsigned int TC:1;       // Transfer Complete
			const volatile unsigned int FRERR:1;    // Framing Error
			const volatile unsigned int BRKR:1;     // Break Received
			const volatile unsigned int :26;
		};
	};

	union
	{
		volatile unsigned int CR1;                  // Control Register 1

		struct
		{
			volatile unsigned int PE:1;             // Peripheral Enable
			volatile unsigned int RXBFIE:1;         // Receive Buffer Full Interrupt Enable
			volatile unsigned int TXBEIE:1;         // Transmit Buffer Empty Interrupt Enable
			volatile unsigned int TCIE:1;           // Transfer Complete Interrupt Enable
			volatile unsigned int FRERRIE:1;        // Framing Error Interrupt Enable
			volatile unsigned int BRKRIE:1;         // Break Received Interrupt Enable
			volatile unsigned int :26;
		};
	};

	volatile unsigned int CLKDIV;                   // Clock divider (value -1)
} UART_t;



#endif
