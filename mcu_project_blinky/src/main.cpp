/*
 -------------------------------------------------------------------------------
 Copyright 2024 Koos du Preez (kdupreez@hotmail.com) - License SPDX BSD-2-Clause
 -------------------------------------------------------------------------------
*/
#include <cstdint>
#include <stdbool.h>
#include "m3_gpio.hpp"
#include "m3_uart.hpp"

int main()
{

    // initi GPIOs
    m3_gpio::init();
    m3_gpio::pinMode(0, M3_GPIO_OUT);
    m3_gpio::pinMode(1, M3_GPIO_IN);

    //setup uart 0 with baud of 115200
    m3_uart::init(M3_UART::UART_0, M3_BAUD::BAUD_115200);
    m3_uart::writeString(M3_UART::UART_0, "<<<== HELLO TANG NANO 4K BLNKY! ==>>>\n");

    int timer = 0;
    unsigned char led_val = 0;
    bool button_pushed = false;

    //infinite run-loop
    while (1) 
    {
        //If button pushed by checking GPIO[1] and save state
        if (m3_gpio::pinRead(1) == 1)
            button_pushed = true;

        // ~250ms
        if (timer == 200000)
            { 
            // toggle LED every 250ms.. flashes 2x per second
            led_val = (led_val == 0) ? 1 : 0;
            timer = 0;

            // write . to UART0 twice a second..
            if (led_val == 1)
            {
                if (button_pushed)
                {
                    m3_uart::writeString(M3_UART::UART_0, "Button Pushed!!\n");
                    //clear push button state;
                    button_pushed = false;
                }
                else
                {
                    m3_uart::writeString(M3_UART::UART_0, "Waiting..\n");
                }   
            }
        }
        else
        {
            timer++;
        }

        // write LED value to GPIO[0]
        m3_gpio::pinWrite(0, led_val);

    } //end while(1)

    return 0;
}
