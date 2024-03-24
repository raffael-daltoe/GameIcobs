/**
 * author: Guillaume Patrigeon
 * update: 11-02-2018
 */

#include "crc8.h"

#define CRCPOL 7

unsigned char CRC8_TABLE[256];

void CRC8_Init(void)
{
	int i, j;
	unsigned int k;

	for (i=0; i<256; i++)
	{
		k = i;

		for (j=0; j<8; j++)
		{
			k <<= 1;
			if (k & 0x100)
				k ^= CRCPOL;
		}

		CRC8_TABLE[i] = k;
	}
}
