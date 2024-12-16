#include "m3_gpio.hpp"

/* 
  Thanks to Grug Huhler for this minimalist GPIO driver: https://github.com/grughuhler/tang_4k_getting_started/blob/main/c_code/gpio.c 
  
  Below code remains Copyright 2024 Grug Huhler - License SPDX BSD-2-Clause

*/

#define GPIO0_BASE 0x40010000
#define GPIO0_DATA_IN         (*(volatile unsigned int *) (GPIO0_BASE + 0x00))
#define GPIO0_DATA_OUT        (*(volatile unsigned int *) (GPIO0_BASE + 0x04))
#define GPIO0_OUTENSET        (*(volatile unsigned int *) (GPIO0_BASE + 0x10))
#define GPIO0_OUTENCLR        (*(volatile unsigned int *) (GPIO0_BASE + 0x14))
#define GPIO0_ALTFUNCSET      (*(volatile unsigned int *) (GPIO0_BASE + 0x18))
#define GPIO0_ALTFUNCCLR      (*(volatile unsigned int *) (GPIO0_BASE + 0x1c))
#define GPIO0_INTENSET        (*(volatile unsigned int *) (GPIO0_BASE + 0x20))
#define GPIO0_INTENCLR        (*(volatile unsigned int *) (GPIO0_BASE + 0x24))
#define GPIO0_INTTYPESET      (*(volatile unsigned int *) (GPIO0_BASE + 0x28))
#define GPIO0_INTTYPECLR      (*(volatile unsigned int *) (GPIO0_BASE + 0x2c))
#define GPIO0_INTPOLSET       (*(volatile unsigned int *) (GPIO0_BASE + 0x30))
#define GPIO0_INTPOLCLR       (*(volatile unsigned int *) (GPIO0_BASE + 0x34))
#define GPIO0_INTSTATCLEAR    (*(volatile unsigned int *) (GPIO0_BASE + 0x38))
#define GPIO0_MASKLOWBYTE(N)  (*(volatile unsigned int *) (GPIO0_BASE + 0x400 + (N)))
#define GPIO0_MASKHIGHBYTE(N) (*(volatile unsigned int *) (GPIO0_BASE + 0x800 + (N)))

void m3_gpio::init(void)
{
  int i;

  /* These are documented as having undefined value at reset */
  for (i = 0; i < 256; i++) {
    GPIO0_MASKLOWBYTE(i) = 0;
    GPIO0_MASKHIGHBYTE(i) = 0;
  }
}

void m3_gpio::pinMode(unsigned char gpio_pin, unsigned char direction)
{
  if (direction == M3_GPIO_OUT)
    GPIO0_OUTENSET = (1 << gpio_pin);
  else
    GPIO0_OUTENCLR = (1 << gpio_pin);
}

void m3_gpio::pinWrite(unsigned char gpio_pin, unsigned char val)
{
  if (val == 1)
    GPIO0_DATA_OUT |= (1 << gpio_pin);
  else
    GPIO0_DATA_OUT &= ~(1 << gpio_pin);
}

unsigned char m3_gpio::pinRead(unsigned char gpio_pin)
{
  unsigned char val;

  val = (GPIO0_DATA_IN >> gpio_pin) & 0x1;

  return val;
}