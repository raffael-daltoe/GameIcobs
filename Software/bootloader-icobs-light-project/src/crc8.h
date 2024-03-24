/**
 * author: Guillaume Patrigeon
 * update: 16-03-2019
 */

#ifndef __CRC8_H__
#define	__CRC8_H__

#ifdef __cplusplus
extern "C" {
#endif



extern unsigned char CRC8_TABLE[256];



/// Initialize the conversion table
void CRC8_Init(void);


/// Calculate next CRC value
#define CRC8_Push(crc, c)       CRC8_TABLE[(crc) ^ (c)]



#ifdef __cplusplus
}
#endif

#endif
