/*
 -------------------------------------------------------------------------------
 Copyright 2024 Koos du Preez (kdupreez@hotmail.com) - License SPDX BSD-2-Clause
 -------------------------------------------------------------------------------
*/

#ifndef _M3_UART_H
#define _M3_UART_H

#include <cstdint>

#define M3_UARTX (0)
#define M3_UARTY (0x1000)

enum M3_BAUD : uint32_t
{
    BAUD_4800 = 4800, 
    BAUD_9600 = 9600, 
    BAUD_19200 = 19200,
    BAUD_38400 = 38400,
    BAUD_57600 = 57600, 
    BAUD_115200 = 115200
};

enum M3_UART : uint16_t
{
    UART_0 = 0x00,
    UART_1 = 0x1000 
};

class m3_uart
{
    public:
        static void init(const M3_UART uart, const M3_BAUD baud_rate);
        static void writeByte(const M3_UART uart, const char c);
        static void writeString(const M3_UART uart, const char *str);
        static char readByte(const M3_UART uart);
        static void writeHexString(const M3_UART uart, uint32_t val);
};

#endif

    
