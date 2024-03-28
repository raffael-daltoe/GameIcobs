## Reset and clocks control

RSTCLK base address : 0x40011000

### Registers description

|   ADDRESS    | NAME      | DESCRIPTION                        |
|:------------:|:---------:|:----------------------------------:|
|  0x40011000  | RSTSTATUS | Reset status register              |
|  0x40011004  | BOOTOPT   | Boot option                        |
|  0x40011010  | CLKENR    | Clock enable register              |

#### RESET STATUS REGISTER (RSTSTATUS: 0x40011000)

| Bit-31 | Bit-30 | Bit-29 | Bit-28 | Bit-27 | Bit-26 | Bit-25| Bit-24| Bit-23| Bit-22| Bit-21| Bit-20| Bit-19  | Bit-18|  Bit-17 | Bit-16 |
|:------:|:------:|:------:|:------:|:------:|:------:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-------:|:-----:|:-------:|:------:|
| U-0    | U-0    | U-0    | U-0    | U-0    | U-0    | U-0   | U-0   | U-0   | U-0   | U-0   | U-0   | U-0     | U-0   | U-0     | U-0    |
| -      | -      | -      | -      | -      |-       | -     | -     | -     | -     | -     | -     | -       | -     | -       | -      |

| Bit-15 | Bit-14 | Bit-13 | Bit-12 | Bit-11 | Bit-10 | Bit-9 | Bit-8 | Bit-7 | Bit-6 | Bit-5 | Bit-4 |  Bit-3  | Bit-2 |  Bit-1  | Bit-0  |
|:------:|:------:|:------:|:------:|:------:|:------:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-------:|:-----:|:-------:|:------:|
| U-0    | U-0    | U-0    | U-0    | U-0    | U-0    | U-0   | U-0   | U-0   | U-0   | U-0   | U-0   | R/C-X   | R/C-X | R/C-X   | R/C-X  |
| -      | -      | -      | -      | -      |-       | -     | -     | -     | -     | -     | -     | SOFTRST | WDRST | HARDRST | PWRRST |

- Bit 15-4 **Unimplemented:** read as ‘0’

- Bit 3 **SOFTRST:** 
<br>Software reset flag
<br>Indicates that a software reset occurred.
<br>This bit is set by hardware only and cleared by software only.

- Bit 2 **WDRST:** 
<br>Watchdog reset flag
<br>Indicates that a watchdog reset occurred.
<br>This bit is set by hardware only and cleared by software only.

- Bit 1 **HARDRST:** 
<br>Hard reset flag
<br>Indicates that a hard reset (using HARDRESET pin) occurred.
<br>This bit is set by hardware only and cleared by software only.

- Bit 0 **PWRRST:** 
<br>Power-on reset flag
<br>Indicates that a power-on reset occurred.
<br>This bit is set by hardware only and cleared by software only.

#### BOOT OPTIONS REGISTER (BOOTOPT: 0x40011004)

| Bit-31 | Bit-30 | Bit-29 | Bit-28 | Bit-27 | Bit-26 | Bit-25| Bit-24| Bit-23| Bit-22| Bit-21| Bit-20| Bit-19  | Bit-18|  Bit-17 | Bit-16 |
|:------:|:------:|:------:|:------:|:------:|:------:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-------:|:-----:|:-------:|:------:|
| U-0    | U-0    | U-0    | U-0    | U-0    | U-0    | U-0   | U-0   | U-0   | U-0   | U-0   | U-0   | U-0     | U-0   | U-0     | U-0    |
| -      | -      | -      | -      | -      |-       | -     | -     | -     | -     | -     | -     | -       | -     | -       | -      |

<table>
<thead>
  <tr>
    <th>Bit-15</th>
    <th>Bit-14</th>
    <th>Bit-13</th>
    <th>Bit-12</th>
    <th>Bit-11</th>
    <th>Bit-10</th>
    <th>Bit-9</th>
    <th>Bit-8</th>
    <th>Bit-7</th>
    <th>Bit-6</th>
    <th>Bit-5</th>
    <th>Bit-4</th>
    <th>Bit-3</th>
    <th>Bit-2</th>
    <th>Bit-1</th>
    <th>Bit-0</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td>U-0</td>
    <td>U-0</td>
    <td>U-0</td>
    <td>U-0</td>
    <td>U-0</td>
    <td>U-0</td>
    <td>U-0</td>
    <td>S-0</td>
    <td>U-0</td>
    <td>U-0</td>
    <td>U-0</td>
    <td>U-0</td>
    <td>R-X</td>
    <td>R-X</td>
    <td>R/C-X</td>
    <td>R/C-X</td>
  </tr>
  <tr>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>SOFTRESET</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td colspan="2">BOOTMEM&lt;1:0&gt;</td>
    <td colspan="2">MEMSEL&lt;1:0&gt;</td>
  </tr>
</tbody>
</table>

- Bit 15-9 **Unimplemented:** read as ‘0’

- Bit 8 **SOFTRESET:**
<br>Soft reset: set as '1' to launch soft reset.
<br>This bit is set by software only and cleared by hardware only.

- Bit 7-4 **Unimplemented:** read as ‘0’

- Bit 3-2 **BOOTMEM:** 
<br>Boot memory
<br>Indicates the current boot memory option.

- Bit 1-0 **MEMSEL:**
<br>Memory selection
<br>Keep last value after reset, cleared after power-on reset:
    - **00:** Internal ROM1 will be selected as boot memory after next reset.
    - **01:** Internal RAM1 will be selected as boot memory after next reset.
    - **1X:** Forbidden - ROM1 will be selected as boot memory.

#### CLOCK ENABLE REGISTER (CLKENR: 0x40011010)

<table>
<thead>
  <tr>
    <th>Bit-31</th>
    <th>Bit-30</th>
    <th>Bit-29</th>
    <th>Bit-28</th>
    <th>Bit-27</th>
    <th>Bit-26</th>
    <th>Bit-25</th>
    <th>Bit-24</th>
    <th>Bit-23</th>
    <th>Bit-22</th>
    <th>Bit-21</th>
    <th>Bit-20</th>
    <th>Bit-19</th>
    <th>Bit-18</th>
    <th>Bit-17</th>
    <th>Bit-16</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td>U-0</td>
    <td>U-0</td>
    <td>U-0</td>
    <td>U-0</td>
    <td>U-0</td>
    <td>U-0</td>
    <td>U-0</td>
    <td>U-0</td>
    <td>U-0</td>
    <td>U-0</td>
    <td>U-0</td>
    <td>U-0</td>
    <td>U-0</td>
    <td>R/W-0</td>
    <td>R/W-0</td>
    <td>R/W-0</td>
  </tr>
  <tr>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>MONITOREN</td>
    <td>I2C2EN</td>
    <td>I2C1EN</td>
  </tr>
</tbody>
</table>

<table>
<thead>
  <tr>
    <th>Bit-15</th>
    <th>Bit-14</th>
    <th>Bit-13</th>
    <th>Bit-12</th>
    <th>Bit-11</th>
    <th>Bit-10</th>
    <th>Bit-9</th>
    <th>Bit-8</th>
    <th>Bit-7</th>
    <th>Bit-6</th>
    <th>Bit-5</th>
    <th>Bit-4</th>
    <th>Bit-3</th>
    <th>Bit-2</th>
    <th>Bit-1</th>
    <th>Bit-0</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td>R/W-0</td>
    <td>R/W-0</td>
    <td>R/W-0</td>
    <td>R/W-0</td>
    <td>R/W-0</td>
    <td>R/W-0</td>
    <td>R/W-0</td>
    <td>R/W-0</td>
    <td>R/W-0</td>
    <td>R/W-0</td>
    <td>R/W-0</td>
    <td>R/W-0</td>
    <td>R/W-0</td>
    <td>R/W-0</td>
    <td>R/W-0</td>
    <td>R/W-0</td>
  </tr>
  <tr>
    <td>SPI2EN</td>
    <td>SPI1EN</td>
    <td>UART4EN</td>
    <td>UART3EN</td>
    <td>UART2EN</td>
    <td>UART1EN</td>
    <td>TIMER4EN</td>
    <td>TIMER3EN</td>
    <td>TIMER2EN</td>
    <td>TIMER1EN</td>
    <td>PPSOUTEN</td>
    <td>PPSINEN</td>
    <td>GPIODEN</td>
    <td>GPIOCEN</td>
    <td>GPIOBEN</td>
    <td>GPIOAEN</td>
  </tr>
</tbody>
</table>

- Bit 18 **MONITOREN:**
<br>MONITOR main clock enable

- Bit 17 **I2C2EN:**
<br>I2C2 main clock enable

- Bit 16 **I2C1EN:**
<br>I2C1 main clock enable

- Bit 15 **SPI2EN:**
<br>SPI2 main clock enable

- Bit 14 **SPI1EN:**
<br>SPI1 main clock enable

- Bit 13 **UART4EN:**
<br>UART4 main clock enable

- Bit 12 **UART3EN:**
<br>UART3 main clock enable

- Bit 11 **UART2EN:**
<br>UART2 main clock enable

- Bit 10 **UART1EN:**
<br>UART1 main clock enable

- Bit 9 **TIMER4EN:**
<br>TIMER4 main clock enable

- Bit 8 **TIMER3EN:**
<br>TIMER3 main clock enable

- Bit 7 **TIMER2EN:**
<br>TIMER2 main clock enable

- Bit 6 **TIMER1EN:**
<br>TIMER1 main clock enable

- Bit 5 **PPSOUTEN:**
<br>PPSOUT main clock enable

- Bit 4 **PPSINEN:**
<br>PPSIN main clock enable

- Bit 3 **GPIODEN:**
<br>GPIOD main clock enable

- Bit 2 **GPIOCEN:**
<br>GPIOC main clock enable

- Bit 1 **GPIOBEN:**
<br>GPIOB main clock enable

- Bit 0 **GPIOAEN:**
<br>GPIOA main clock enable

### Register map

<table>
<thead>
  <tr>
    <th rowspan="2">Register</th>
    <th rowspan="2">Offset</th>
    <th colspan="32">Bits</th>
    <th rowspan="2">Reset value</th>
  </tr>
  <tr>
    <td>31</td>
    <td>30</td>
    <td>29</td>
    <td>28</td>
    <td>27</td>
    <td>26</td>
    <td>25</td>
    <td>24</td>
    <td>23</td>
    <td>22</td>
    <td>21</td>
    <td>20</td>
    <td>19</td>
    <td>18</td>
    <td>17</td>
    <td>16</td>
    <td>15</td>
    <td>14</td>
    <td>13</td>
    <td>12</td>
    <td>11</td>
    <td>10</td>
    <td>9</td>
    <td>8</td>
    <td>7</td>
    <td>6</td>
    <td>5</td>
    <td>4</td>
    <td>3</td>
    <td>2</td>
    <td>1</td>
    <td>0</td>
  </tr>
</thead>
<tbody>
  <tr>
    <td>RSTSTATUS</td>
    <td>000</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>SOFTRST</td>
    <td>WDRST</td>
    <td>HARDRST</td>
    <td>PWRRST</td>
    <td>000X</td>
  </tr>
  <tr>
    <td>BOOTOPT</td>
    <td>004</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td colspan="2">BOOTMEM&lt;1:0&gt;</td>
    <td colspan="2">MEMSEL&lt;1:0&gt;</td>
    <td>000X</td>
  </tr>
  <tr>
    <td>CLKENR</td>
    <td>010</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>MONITOREN</td>
    <td>I2C2EN</td>
    <td>I2C1EN</td>
    <td>SPI2EN</td>
    <td>SPI1EN</td>
    <td>UART4EN</td>
    <td>UART3EN</td>
    <td>UART2EN</td>
    <td>UART1EN</td>
    <td>TIMER4EN</td>
    <td>TIMER3EN</td>
    <td>TIMER2EN</td>
    <td>TIMER1EN</td>
    <td>PPSOUTEN</td>
    <td>PPSINEN</td>
    <td>GPIODEN</td>
    <td>GPIOCEN</td>
    <td>GPIOBEN</td>
    <td>GPIOAEN</td>
    <td>0000</td>
  </tr>
</tbody>
</table>

### Utilisation

```c
//software reset after boot procedure
RSTCLK.MEMSEL = MEMSEL_RAM1;
RSTCLK.SOFTRESET = 1;

//peripherals clock enable
RSTCLK.GPIOAEN = 1;
RSTCLK.GPIOBEN = 1;
RSTCLK.GPIOCEN = 1;
RSTCLK.GPIODEN = 1;
RSTCLK.PPSINEN = 1;
RSTCLK.PPSOUTEN = 1;
RSTCLK.TIMER1EN = 1;
RSTCLK.TIMER2EN = 1;
RSTCLK.TIMER3EN = 1;
RSTCLK.TIMER4EN = 1;
RSTCLK.UART1EN = 1;
RSTCLK.UART2EN = 1;
RSTCLK.UART3EN = 1;
RSTCLK.UART4EN = 1;
RSTCLK.SPI1EN = 1;
RSTCLK.SPI2EN = 1;
RSTCLK.I2C1EN = 1;
RSTCLK.I2C2EN = 1;
```
