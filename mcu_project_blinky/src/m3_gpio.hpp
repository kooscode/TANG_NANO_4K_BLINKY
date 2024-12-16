#ifndef _M3_GPIO_H
#define _M3_GPIO_H

#define M3_GPIO_IN 0
#define M3_GPIO_OUT 1

class m3_gpio
{
    public:
        static void init(void);
        static void pinMode(unsigned char gpio_pin, unsigned char direction);
        static void pinWrite(unsigned char gpio_pin, unsigned char val);
        static unsigned char pinRead(unsigned char gpio_pin);
};

#endif
