
/*
 -------------------------------------------------------------------------------
 Copyright 2024 Koos du Preez (kdupreez@hotmail.com) - License SPDX BSD-2-Clause
 -------------------------------------------------------------------------------
*/

#include <stdbool.h>
#include "m3_gpio.hpp"

int main()
{

  unsigned char val = 1;
  char ch;
  
  m3_gpio::init();
  m3_gpio::pinMode(0, M3_GPIO_OUT);
  m3_gpio::pinWrite(0, val);

  int timer = 0;
  unsigned char led_val = 0;

  //infinite run-loop
  while (1) 
  {
      // 300k loops ~250ms
      if (timer == 300000)
      { 
        // toggle LED every 250ms.. flashes 2x per second
        led_val = (led_val == 0) ? 1 : 0;
        timer = 0;
      }
      else
      {
        timer++;
      }

      // write LED value to GPIO[0]
      m3_gpio::pinWrite(0, led_val);
  }
  
  return 0;
}
