#include "gpio.h"

void write_gpio(uintptr_t addr, uint8_t value)
{
    volatile uint8_t *loc_addr = (volatile uint8_t *)addr;
    *loc_addr = value;
}

uint8_t read_gpio(uintptr_t addr)
{
    return *(volatile uint8_t *)addr;
}

void init_gpio()
{
    /*volatile uint32_t*write_reg_address=GPIO_TRI;
    *write_reg_address=0x0000;
    write_reg_address=GPIO2_TRI;
    *write_reg_address=0x001F;*/
    write_gpio(GPIO_TRI,0x00);
    write_gpio(GPIO2_TRI,0xFF);
}

