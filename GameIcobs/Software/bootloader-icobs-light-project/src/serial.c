/**
 * author: Guillaume Patrigeon
 * update: 16-03-2019
 */

#include "system.h"

typedef enum
{
	RecordType_Data,
	RecordType_End,
	RecordType_SectionAddress,
	RecordType_SectionStart,
	RecordType_LinearAddress,
	RecordType_LinearStart,
	RecordType_Error = 7,
	_NbRecordType
} RecordType_e;


typedef struct
{
    union
    {
        unsigned int header;

        struct
        {
            unsigned int id:8;
            unsigned int type:8;
            unsigned int offset:16;
        };
    };

	union
	{
    	unsigned char data[SERIAL_MAXLENGTH-4];
		unsigned short data16[(SERIAL_MAXLENGTH-4)/2];
		unsigned int data32[(SERIAL_MAXLENGTH-4)/4];
	};
} SerialMessage_t;


static int SerialDecode(int length, unsigned char* buffer);


static volatile clock_t _clock = 0;
void SerialTick(void) {
	_clock++;
}

clock_t clock(void) {
	return _clock;
}

void rst_clock(void) {
	_clock = 0;
}

int SerialReceive(void)
{
	static clock_t timeout = 0;
	static int step = 0;
	static int p = 0;
	static int length = 0;
	static unsigned char buffer[SERIAL_MAXLENGTH];
	static unsigned char crc = 0;

	int ret = 0;
	char c;

	if (_clock >= timeout)
		step = 0;

	while (SerialTest())
	{
		c = SerialRead();
		crc = CRC8_Push(crc, c);

		switch (step)
		{
			case 0:
				if (c != ASCII_SOH)
					break;

				crc = SERIAL_CRCINIT;
				p = 0;
				timeout = _clock + SERIAL_TIMEOUT;
				step = 1;
				break;

			case 1:
				length = (unsigned int)c;
				step = (length > SERIAL_MAXLENGTH) ? 0 : 2;
				break;

			case 2:
				buffer[p++] = c;
				if (p < length)
					break;

				step = 3;
				break;

			case 3:
				if (!crc)
					ret = SerialDecode(length, buffer);

				step = 0;
				break;
		}
	}

	return ret;
}


void SerialSendMessage(int length, unsigned char* message)
{
	int i;
	unsigned char crc = SERIAL_CRCINIT;

	if (length > SERIAL_MAXLENGTH)
		return;

	SerialSend(ASCII_SOH);
	SerialSend((unsigned char)length);

	crc = CRC8_Push(crc, (unsigned char)length);

	for (i=0; i<length; i++)
	{
		SerialSend(message[i]);
		crc = CRC8_Push(crc, message[i]);
	}

	SerialSend(crc);
}


static int SerialDecode(int length, unsigned char* buffer)
{
	static unsigned int base = 0;
	SerialMessage_t* message = (SerialMessage_t*)buffer;
	int ret = 0;
	int i;
	unsigned char response[2] = {buffer[0], ASCII_ACK};

	if (length < 4)
		return -2;

	switch (message->type)
	{
		case RecordType_Data:
			length -= 4;
			if (message->offset & 1 || length & 1)
				for (i=0; i<length; i++)
					((unsigned char*)(base + message->offset))[i] = message->data[i];

			else if (message->offset & 2 || length & 2)
				for (i=0; i<length/2; i++)
					((unsigned short*)(base + message->offset))[i] = message->data16[i];

			else
				for (i=0; i<length/4; i++)
					((unsigned int*)(base + message->offset))[i] = message->data32[i];
			ret = length;
			break;

		case RecordType_End:
			ret = -1;
			break;

		case RecordType_SectionAddress:
		case RecordType_LinearAddress:
			base = message->data16[0] << 16;
			break;

		case RecordType_SectionStart:
		case RecordType_LinearStart:
			break;

		default:
			response[1] = ASCII_NAK;
	}

	SerialSendMessage(2, response);
	return ret;
}
