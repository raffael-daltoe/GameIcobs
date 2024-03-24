/**
 * author: Guillaume Patrigeon & Theo Soriano
 * update: 28-09-2021
 */

#ifndef __ARCH_RSTCLK_H__
#define __ARCH_RSTCLK_H__

typedef enum
{
	MEMSEL_ROM1,
	MEMSEL_RAM1
} MEMSEL_e;

typedef struct
{
	union
	{
		volatile unsigned int RSTSTATUS;        // Reset status register

		struct
		{
			volatile unsigned int PWRRST:1;     // Power Reset
			volatile unsigned int HARDRST:1;    // Hard Reset
			volatile unsigned int WDRST:1;      // Watchdog Reset
			volatile unsigned int SOFTRST:1;    // Software Reset
			volatile unsigned int :28;
		};
	};

	union
	{
		volatile unsigned int BOOTOPT;          // Boot option

		struct
		{
			volatile unsigned int MEMSEL:2;     // Memory selection (see BOOTMEM_e)
			volatile unsigned int BOOTMEM:2;    // Memory used for boot
			volatile unsigned int :4;
			volatile unsigned int SOFTRESET:1;
			volatile unsigned int :15;
		};
	};

	volatile unsigned int:32;
	volatile unsigned int:32;

	union
	{
		volatile unsigned int CLKENR;           // Clock enable register

		struct
		{
			volatile unsigned int GPIOAEN:1;    		// GPIOA main clock enable
			volatile unsigned int GPIOBEN:1;    		// GPIOB main clock enable
			volatile unsigned int GPIOCEN:1;    		// GPIOC main clock enable
			volatile unsigned int TIMER1EN:1;   		// TIMER1 main clock enable
			volatile unsigned int UART1EN:1;    		// UART1 main clock enables
			volatile unsigned int :27;
		};
	};
} RSTCLK_t;

#endif
