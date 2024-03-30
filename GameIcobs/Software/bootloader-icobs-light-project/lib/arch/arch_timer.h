/**
 * author: Guillaume Patrigeon
 * update: 10-12-2018
 */

#ifndef __ARCH_TIMER_H__
#define __ARCH_TIMER_H__



typedef struct
{
	volatile unsigned int CNT;                  // Counter register

	union
	{
		volatile unsigned int STATUS;           // Status register

		struct
		{
			volatile unsigned int :1;
			volatile unsigned int UIF:1;        // Receive Buffer Full flag
			volatile unsigned int :30;
		};
	};

	union
	{
		volatile unsigned int CR1;              // Control Register 1

		struct
		{
			volatile unsigned int PE:1;          // Peripheral Enable
			volatile unsigned int UIE:1;         // Receive Buffer Full Interrupt Enable
			volatile unsigned int :30;
		};
	};

	volatile unsigned int PSC;       // Clock divider (value -1)
	volatile unsigned int ARR;
} TIMER_t;



#endif
