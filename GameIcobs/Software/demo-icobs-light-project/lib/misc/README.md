sys
================================================================

Common libraries

| File                           | Type                   | Short description                    |
|--------------------------------|------------------------|--------------------------------------|
| `ascii.h`                      | C header               | ASCII special characters             |
| `ansi.h`                       | C header               | ANSI escape sequences                |
| `types.h`                      | C header               | Standard types declaration           |
| `marcos.h`                     | C header               | Common macros definition             |
| `allocate.c` <br> `allocate.h` | C source <br> C header | Dynamic memory allocation            |
| `crc8.c` <br> `crc8.h`         | C source <br> C header | 8-bit CRC library                    |
| `rng8.c` <br> `rng8.h`         | C source <br> C header | 8-bit pseudo random number generator |
| `print.c` <br> `print.h`       | C source <br> C header | Print function                       |



How to use a library
----------------------------------------------------------------

1. In the project settings, add the *sys* folder path to the include paths list.

2. When there is one, configure the project to compile and link the library's source.

3. Include the library header file at the top of the project source(s). Example:

	```c
	#include <print.h>
	```

4. Use the library fuctions and/or macros.
