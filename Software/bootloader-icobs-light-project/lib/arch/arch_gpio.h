/**
 * author: Guillaume Patrigeon
 * update: 14-02-2018
 */

#ifndef __ARCH_GPIO_H__
#define __ARCH_GPIO_H__



typedef enum
{
	GPIO_MODE_INPUT,
	GPIO_MODE_OUTPUT
} GPIO_MODE_e;


typedef enum
{
	GPIO_OTYPE_PUSHPULL,
	GPIO_OTYPE_OPENDRAIN
} GPIO_OTYPE_e;



/**
 * (input data)           IDR
 * (output data)          ODR
 * (pin mode)            MODE : GPIO_MODE_INPUT / GPIO_MODE_OUTPUT
 * (output type)        OTYPE : GPIO_OTYPE_PUSHPULL / GPIO_OTYPE_OPENDRAIN
 */
typedef struct
{
	union
	{
		const volatile unsigned int IDR;        // Input data register

		struct
		{
			const volatile unsigned int P0:1;
			const volatile unsigned int P1:1;
			const volatile unsigned int P2:1;
			const volatile unsigned int P3:1;
			const volatile unsigned int P4:1;
			const volatile unsigned int P5:1;
			const volatile unsigned int P6:1;
			const volatile unsigned int P7:1;
			const volatile unsigned int P8:1;
			const volatile unsigned int P9:1;
			const volatile unsigned int P10:1;
			const volatile unsigned int P11:1;
			const volatile unsigned int P12:1;
			const volatile unsigned int P13:1;
			const volatile unsigned int P14:1;
			const volatile unsigned int P15:1;
			const volatile unsigned int :16;
		} IDRbits;                              // Input data
	};

	union
	{
		volatile unsigned int ODR;              // Output data register

		struct
		{
			volatile unsigned int P0:1;
			volatile unsigned int P1:1;
			volatile unsigned int P2:1;
			volatile unsigned int P3:1;
			volatile unsigned int P4:1;
			volatile unsigned int P5:1;
			volatile unsigned int P6:1;
			volatile unsigned int P7:1;
			volatile unsigned int P8:1;
			volatile unsigned int P9:1;
			volatile unsigned int P10:1;
			volatile unsigned int P11:1;
			volatile unsigned int P12:1;
			volatile unsigned int P13:1;
			volatile unsigned int P14:1;
			volatile unsigned int P15:1;
			volatile unsigned int :16;
		} ODRbits;                              // Output data
	};

	union
	{
		volatile unsigned int MODER;            // Mode register

		struct
		{
			volatile unsigned int P0:1;
			volatile unsigned int P1:1;
			volatile unsigned int P2:1;
			volatile unsigned int P3:1;
			volatile unsigned int P4:1;
			volatile unsigned int P5:1;
			volatile unsigned int P6:1;
			volatile unsigned int P7:1;
			volatile unsigned int P8:1;
			volatile unsigned int P9:1;
			volatile unsigned int P10:1;
			volatile unsigned int P11:1;
			volatile unsigned int P12:1;
			volatile unsigned int P13:1;
			volatile unsigned int P14:1;
			volatile unsigned int P15:1;
			volatile unsigned int :16;
		} MODEbits;                             // Mode (see GPIO_MODE_xxx)
	};

	union
	{
		volatile unsigned int OTYPER;           // Output type register

		struct
		{
			volatile unsigned int P0:1;
			volatile unsigned int P1:1;
			volatile unsigned int P2:1;
			volatile unsigned int P3:1;
			volatile unsigned int P4:1;
			volatile unsigned int P5:1;
			volatile unsigned int P6:1;
			volatile unsigned int P7:1;
			volatile unsigned int P8:1;
			volatile unsigned int P9:1;
			volatile unsigned int P10:1;
			volatile unsigned int P11:1;
			volatile unsigned int P12:1;
			volatile unsigned int P13:1;
			volatile unsigned int P14:1;
			volatile unsigned int P15:1;
			volatile unsigned int :16;
		} OTYPEbits;                            // Output type (see GPIO_OTYPE_xxx)
	};
} GPIO_t;



#endif
