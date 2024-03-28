# Library documentation

- [IBEX](doc/IBEX.md)
- [RSTCLK](doc/RSTCLK.md)
- [GPIO](doc/GPIO.md)
- [TIMER](doc/TIMER.md)
- [UART](doc/UART.md)

### Bit access:

- R/W **Read/Write**
<br>Readable and writable by software.

- R **Read-only**
<br>Can be read, but not writable by software.

- W **Write-only**
<br>Can be written, but not readable by software.

- R/C **Read/Clear**
<br>Readable and clearable by software.

- R/S **Read/Set**
<br>Readable and settable by software.

- C **Clear**
<br>Can be cleared, but not readable by software.

- S **Set**
<br>Can be set, but not readable by software.

- U **Unimplemented**

### Reset value:

- **0** Reset value is 0.
- **1** Reset value is 1.
- **X** Reset value is unknown.
<br>Its value depends on reset conditions and on system state before reset.
