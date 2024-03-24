/**
 * UART library
 * author: Guillaume Patrigeon - Theo Soriano
 * update: 16-08-2019
 */

#include <arch.h>
#include <uart.h>
#include <ibex_csr.h>
#include <system.h>

//--------------------------------------------------------

static volatile char UART1_TxBuffer[UART1_TXBUFFERSIZE];
static volatile int UART1_TxFirst, UART1_TxLast, UART1_TxCount;

static volatile char UART1_RxBuffer[UART1_RXBUFFERSIZE];
static volatile int UART1_RxFirst, UART1_RxLast, UART1_RxCount;

int UART1_get_TxCount (void){
	return UART1_TxCount;
}

void UART1_Init(unsigned int baudrate)
{
	RSTCLK.UART1EN = 1;

	UART1.PE = 0;

	UART1.CLKDIV = (SYSCLK - 2*baudrate)/(4*baudrate);

	UART1_TxFirst = UART1_TxLast = UART1_TxCount = 0;
	UART1_RxFirst = UART1_RxLast = UART1_RxCount = 0;

	UART1.RXBFIE = 1;
}

void UART1_Clean(void)
{
	UART1.TXBEIE = 0;
	UART1.RXBFIE = 0;

	UART1_TxFirst = UART1_TxLast = UART1_TxCount = 0;
	UART1_RxFirst = UART1_RxLast = UART1_RxCount = 0;

	UART1.RXBFIE = 1;
}

int UART1_IsRxNotEmpty(void)
{
	return (UART1_RxFirst != UART1_RxLast);
}

char UART1_Read(void)
{
	char c;

	if (UART1_RxFirst == UART1_RxLast)
	{
		UART1_RxCount = 0;
		return 0;
	}

	c = UART1_RxBuffer[UART1_RxLast++];
	UART1_RxCount--;

	if (UART1_RxLast >= UART1_RXBUFFERSIZE)
		UART1_RxLast = 0;

	return c;
}

void UART1_Write(const char c)
{
	if (UART1_TxCount >= UART1_TXBUFFERSIZE - 2)
		return;

	UART1.TXBEIE = 0;

	UART1_TxBuffer[UART1_TxFirst++] = c;
	UART1_TxCount++;

	if (UART1_TxFirst >= UART1_TXBUFFERSIZE)
		UART1_TxFirst = 0;

	UART1.TXBEIE = 1;
}

void UART1_IRQHandler(void) __attribute__((interrupt));
void UART1_IRQHandler(void) {
	if (UART1.RXBFIE && UART1.RXBF)
	{
		UART1_RxBuffer[UART1_RxFirst] = UART1.DATA;

		if (UART1_RxCount < UART1_RXBUFFERSIZE - 2)
		{
			UART1_RxFirst++;
			UART1_RxCount++;

			if (UART1_RxFirst >= UART1_RXBUFFERSIZE)
				UART1_RxFirst = 0;
		}
	}

	if (UART1.TXBEIE && UART1.TXBE)
	{
		if (UART1_TxFirst == UART1_TxLast)
		{
			UART1_TxCount = 0;
			UART1.TXBEIE = 0;
		}
		else
		{
			UART1.DATA = UART1_TxBuffer[UART1_TxLast++];
			UART1_TxCount--;

			if (UART1_TxLast >= UART1_TXBUFFERSIZE)
				UART1_TxLast = 0;
		}
	}
}
