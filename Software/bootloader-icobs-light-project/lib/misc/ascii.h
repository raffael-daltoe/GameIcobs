/**
 * author: Guillaume Patrigeon
 * update: 24-03-2017
 */

#ifndef __ASCII_H__
#define __ASCII_H__



#define ASCII_XON       ASCII_DC1
#define ASCII_XOFF      ASCII_DC3



typedef enum
{
	ASCII_NUL,          // Null
	ASCII_SOH,          // Start of header (Ctrl+A)
	ASCII_STX,          // Start of text (Ctrl+B)
	ASCII_ETX,          // End of text (Ctrl+C)
	ASCII_EOT,          // End of transmission (Ctrl+D)
	ASCII_ENQ,          // Enquiry (Ctrl+E)
	ASCII_ACK,          // Acknowledge (Ctrl+F)
	ASCII_BEL,          // Bell (Ctrl+G)
	ASCII_BS,           // Backspace (Ctrl+H)
	ASCII_HT,           // Horizontal tabulation (Ctrl+I)
	ASCII_LF,           // Line feed (Ctrl+J)
	ASCII_VT,           // Vertical tabulation (Ctrl+K)
	ASCII_FF,           // Form feed (Ctrl+L)
	ASCII_CR,           // Carriage return (Ctrl+M)
	ASCII_SO,           // Shift out (Ctrl+N)
	ASCII_SI,           // Shift in (Ctrl+O)
	ASCII_DLE,          // Data link escape (Ctrl+P)
	ASCII_DC1,          // Device control 1 (Ctrl+Q)
	ASCII_DC2,          // Device control 2 (Ctrl+R)
	ASCII_DC3,          // Device control 3 (Ctrl+S)
	ASCII_DC4,          // Device control 4 (Ctrl+T)
	ASCII_NAK,          // Negative acknowledge (Ctrl+U)
	ASCII_SYN,          // Synchronous idle (Ctrl+V)
	ASCII_ETB,          // End of transmission block (Ctrl+W)
	ASCII_CAN,          // Cancel (Ctrl+X)
	ASCII_EOM,          // End of medium (Ctrl+Y)
	ASCII_SUB,          // Substitute (Ctrl+Z)
	ASCII_ESC,          // Escape
	ASCII_FS,           // File separator
	ASCII_GS,           // Group separator
	ASCII_RS,           // Record separator
	ASCII_US,           // Unit separator
	ASCII_DEL = 127     // Delete
} ASCII;



#endif
