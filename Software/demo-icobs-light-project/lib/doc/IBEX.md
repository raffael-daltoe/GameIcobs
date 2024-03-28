## IBEX Core

### Interrupt vector

| ID |  Offset  |     Handler     |              Connected interrupt              |
|:--:|:--------:|:---------------:|:---------------------------------------------:|
| 00 | 00000000 | Default_Handler |  -                                            |
| 01 | 00000004 | Default_Handler |  -                                            |
| 02 | 00000008 | Default_Handler |  -                                            |
| 03 | 0000000C | Default_Handler |  -                                            |
| 04 | 00000010 | Default_Handler |  -                                            |
| 05 | 00000014 | Default_Handler |  -                                            |
| 06 | 00000018 | Default_Handler |  -                                            |
| 07 | 0000001C | Default_Handler |  -                                            |
| 08 | 00000020 | Default_Handler |  -                                            |
| 09 | 00000024 | Default_Handler |  -                                            |
| 10 | 00000028 | Default_Handler |  -                                            |
| 11 | 0000002C | Default_Handler |  -                                            |
| 12 | 00000030 | Default_Handler |  -                                            |
| 13 | 00000034 | Default_Handler |  -                                            |
| 14 | 00000038 | Default_Handler |  -                                            |
| 15 | 0000003C | Default_Handler |  -                                            |
| 16 | 00000040 | IRQ_00_Handler  |  TIMER1 global interrupt (TIMER1_IRQHandler)  |
| 17 | 00000044 | IRQ_01_Handler  |  TIMER2 global interrupt (TIMER2_IRQHandler)  |
| 18 | 00000048 | IRQ_02_Handler  |  TIMER3 global interrupt (TIMER3_IRQHandler)  |
| 19 | 0000004C | IRQ_03_Handler  |  TIMER4 global interrupt (TIMER4_IRQHandler)  |
| 20 | 00000050 | IRQ_04_Handler  |  UART1 global interrupt (UART1_IRQHandler)    |
| 21 | 00000054 | IRQ_05_Handler  |  UART2 global interrupt (UART2_IRQHandler)    |
| 22 | 00000058 | IRQ_06_Handler  |  UART3 global interrupt (UART3_IRQHandler)    |
| 23 | 0000005C | IRQ_07_Handler  |  UART4 global interrupt (UART4_IRQHandler)    |
| 24 | 00000060 | IRQ_08_Handler  |  SPI1 global interrupt (SPI1_IRQHandler)      |
| 25 | 00000064 | IRQ_09_Handler  |  SPI2 global interrupt (SPI2_IRQHandler)      |
| 26 | 00000068 | IRQ_10_Handler  |  I2C1 global interrupt (I2C1_IRQHandler)      |
| 27 | 0000006C | IRQ_11_Handler  |  I2C2 global interrupt (I2C2_IRQHandler)      |
| 28 | 00000070 | IRQ_12_Handler  |  -                                            |
| 29 | 00000074 | IRQ_13_Handler  |  -                                            |
| 30 | 00000078 | IRQ_14_Handler  |  -                                            |
| 31 | 0000007C | IRQ_NMI_Handler |  -                                            |
