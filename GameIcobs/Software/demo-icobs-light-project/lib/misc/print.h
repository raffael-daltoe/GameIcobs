/**
 * author: Guillaume Patrigeon
 * update: 25-06-2019
 */

#ifndef __PRINT_H__
#define __PRINT_H__

#ifdef __cplusplus
extern "C" {
#endif

#include <stdarg.h>


/**
 * Build a formatted text and send it to the output stream
 * Supported format specifiers:
 * - %c:   character
 * - %s:   string of characters
 * - %d:   signed integer
 * - %i:   signed integer
 * - %u:   unsigned integer
 * - %l:   signed long integer
 * - %lu:  unsigned long integer
 * - %ll:  signed long long integer
 * - %llu: unsigned long long integer
 * - %x:   unsigned integer in hexadecimal format (lower case)
 * - %X:   unsigned integer in hexadecimal format (upper case)
 */
void print(void (*output)(char), const char* str, ...);
void vprint(void (*output)(char), const char* str, va_list ap);



#ifdef __cplusplus
}
#endif

#endif
