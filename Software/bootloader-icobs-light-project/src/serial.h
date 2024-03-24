/**
 * author: Guillaume Patrigeon
 * update: 16-03-2019
 */

#ifndef __SERIAL_H__
#define __SERIAL_H__

#define SERIAL_TIMEOUT          100
#define SERIAL_MAXLENGTH        80
#define SERIAL_CRCINIT          12

#define SerialSend              UART1_Write
#define SerialRead              UART1_Read
#define SerialTest              UART1_IsRxNotEmpty

void SerialTick(void);
clock_t clock(void);
void rst_clock(void);

void SerialSendMessage(int length, unsigned char* message);
int SerialReceive(void);

#endif
