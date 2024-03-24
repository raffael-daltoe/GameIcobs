/* 	##########################################################
	##########################################################
	##    __    ______   ______   .______        _______.   ##
	##   |  |  /      | /  __  \  |   _  \      /       |   ##
	##   |  | |  ,----'|  |  |  | |  |_)  |    |   (----`   ##
	##   |  | |  |     |  |  |  | |   _  <      \   \       ##
	##   |  | |  `----.|  `--'  | |  |_)  | .----)   |      ##
	##   |__|  \______| \______/  |______/  |_______/       ##
	##                                                      ##
	##########################################################
	##########################################################
	----------------------------------------------------------
	Linker script
	Author: Soriano Theo
	Update: 07-06-2022
	---------------------------------------------------------- */

OUTPUT_ARCH(riscv)

/* required to correctly link newlib nano */
GROUP(-lnosys -lc_nano -lgcc -lsupc++)

SEARCH_DIR(.)
/* __DYNAMIC = 0; */

__ROM_BASE = 0x08000000;
__ROM_SIZE = 0x00001000;

__RAM_BASE = 0x10010000;
__RAM_SIZE = 0x00010000;

__STACK_SIZE = 0x00000800;  /* 2K - stack size */
__HEAP_SIZE  = 0x00000400;  /* 1K - heap size */

/* Memory */
MEMORY
{
	ROM (rx)  : ORIGIN = __ROM_BASE, LENGTH = __ROM_SIZE /* ROM1 8 kB */
    RAM (w)   : ORIGIN = __RAM_BASE, LENGTH = __RAM_SIZE /* RAM2 8 kB */
}

/* Sections */
SECTIONS
{
	.text :
	{
		KEEP(*(.vectors))
		*(.text)
		*(.text.*)

		KEEP(*(.init))
		KEEP(*(.fini))

		/* .ctors */
		*crtbegin.o(.ctors)
		*crtbegin?.o(.ctors)
		*(EXCLUDE_FILE(*crtend?.o *crtend.o) .ctors)
		*(SORT(.ctors.*))
		*(.ctors)

		/* .dtors */
		*crtbegin.o(.dtors)
		*crtbegin?.o(.dtors)
		*(EXCLUDE_FILE(*crtend?.o *crtend.o) .dtors)
		*(SORT(.dtors.*))
		*(.dtors)

        *(.lit)
        *(.shdata)

		*(.rodata)
		*(.rodata.*)
		KEEP(*(.eh_frame*))

		*(.shbss)
	} > ROM

	. = ALIGN(4);
	_text_end = .;

	.data : AT(_text_end)
	{
		_data_start = .;
		*(vtable)
		*(.data)
		*(.data.*)
		*(.sdata)
		*(.sdata.*)

		. = ALIGN(4);
		/* preinit data */
		PROVIDE_HIDDEN (__preinit_array_start = .);
		KEEP(*(.preinit_array))
		PROVIDE_HIDDEN (__preinit_array_end = .);

		. = ALIGN(4);
		/* init data */
		PROVIDE_HIDDEN (__init_array_start = .);
		KEEP(*(SORT(.init_array.*)))
		KEEP(*(.init_array))
		PROVIDE_HIDDEN (__init_array_end = .);


		. = ALIGN(4);
		/* finit data */
		PROVIDE_HIDDEN (__fini_array_start = .);
		KEEP(*(SORT(.fini_array.*)))
		KEEP(*(.fini_array))
		PROVIDE_HIDDEN (__fini_array_end = .);

		KEEP(*(.jcr*))
		. = ALIGN(4);
		/* All data end */
		_data_end = .;
	} > RAM

	.bss (NOLOAD):
	{
		. = ALIGN(4);
		_bss_start = .;
		*(.bss)
		*(.bss.*)
		*(.sbss)
		*(.sbss.*)
		*(COMMON)
		. = ALIGN(4);
		_bss_end = .;
	} > RAM

	.heap (COPY) :
	{
		. = ALIGN(8);
		__end__ = .;
		_end = .;
		PROVIDE(end = .);
		. = . + __HEAP_SIZE;
		. = ALIGN(8);
		__HeapLimit = .;
	} > RAM

	.stack (ORIGIN(RAM) + LENGTH(RAM) - __STACK_SIZE) (COPY) :
	{
		. = ALIGN(8);
		__StackLimit = .;
		. = . + __STACK_SIZE;
		. = ALIGN(8);
		__StackTop = .;
	} > RAM
	PROVIDE(__stack = __StackTop);
}
