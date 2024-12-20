/* 
 -------------------------------------------------------------------------------
 Dervied from Grug Huhler's minimalist UART driver: https://github.com/grughuhler/tang_4k_getting_started/blob/main/c_code/uart.c 
 Copyright 2024 Koos du Preez (kdupreez@hotmail.com) - License SPDX BSD-2-Clause
 Copyright 2024 Grug Huhler - License SPDX BSD-2-Clause
 -------------------------------------------------------------------------------
*/

#include "m3_uart.hpp"

// Must set sys_clk so we know how to compute BaudDiv
#ifndef _M3_SYSCLK
    #error "_M3_SYSCLK not set!! Please check Makefile to ensure _M3_SYSCLK is set!"
    #define _M3_SYSCLK 0
#endif

// UART Memory Base Address
#define M3_UART_BASE 0x40004000

// Offsets for M2 UART(N) Data, State, Control, Internal and BaudDiv registers
#define M3_UART_DATA(N)     (*((volatile uint32_t *) (M3_UART_BASE + 0x00 + N)))
#define M3_UART_STATE(N)    (*((volatile uint32_t *) (M3_UART_BASE + 0x04 + N)))
#define M3_UART_CTRL(N)     (*((volatile uint32_t *) (M3_UART_BASE + 0x08 + N)))
#define M3_UART_BAUDDIV(N)  (*((volatile uint32_t *) (M3_UART_BASE + 0x10 + N)))

/* GPIO Control registers values*/
#define M3_UART_CTRL_RX 0x01
#define M3_UART_CTRL_TX 0x02

/* GPIO "Buffer Full" State register values*/
#define M3_UART_STATE_TX_BF 0x01
#define M3_UART_STATE_RX_BF 0x02

void m3_uart::init(const M3_UART uart, const M3_BAUD baud_rate)
{
  /* Config baud divider register*/
  uint32_t baud_div =  _M3_SYSCLK / baud_rate;
  M3_UART_BAUDDIV(uart) = baud_div;

  /* Set M3 UART Control Registers to enable RX and TX */
  M3_UART_CTRL(uart) = M3_UART_CTRL_RX | M3_UART_CTRL_TX;
}

void m3_uart::writeByte(const M3_UART uart, const char c)
{
  //Set M3 UART Data Register
  M3_UART_DATA(uart) = c;

   /* Wait for M3 UART State Register to indicate TX buffer to be cleared */
  while (M3_UART_STATE(uart) & M3_UART_STATE_TX_BF);
}

void m3_uart::writeString(const M3_UART uart, const char *str)
{
  char c;
  // Send chars until 0x00 termination
  while ((c = *str++) != 0x00) writeByte(uart, c);
}

char m3_uart::readByte(const M3_UART uart)
{
  /* await until M3 State Register Indicates RX Buffer Full */
  while ( !(M3_UART_STATE(uart) & M3_UART_STATE_RX_BF) );
  return M3_UART_DATA(uart);
}

void m3_uart::writeHexString(const M3_UART uart, uint32_t val)
{
  char ch;
  uint32_t i;

  for (i = 0; i < 8; i++) {
    ch = (val & 0xf0000000) >> 28;
    writeByte(uart, "0123456789abcdef"[ch]);
    val = val << 4;
  }
}
