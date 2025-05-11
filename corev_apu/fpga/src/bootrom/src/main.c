// Copyright OpenHW Group contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "uart.h"
#include "spi.h"
#include "sd.h"
#include "gpt.h"

// 1 second at 50MHz
#define SECOND_CYCLES   (50 * 1000 * 1000)
#define WAIT_SECONDS    (5)

static inline uintptr_t get_cycle_count() {
    uintptr_t cycle;
    __asm__ volatile ("csrr %0, cycle" : "=r" (cycle));
    return cycle;
}

int main()
{
    uint32_t i, ret = 0;
    uint8_t uart_res = 0;
    uintptr_t start;
    int mode=0;
    


    init_uart(50000000, 115200); //not needed in intel setup as UART IP is already configured via HW
    print_uart("Hello World!\r\n");

    int res;
    print_uart(" booting!\r\n");
    res = gpt_find_boot_partition((uint8_t *)0x80000000UL, 2 * 16384); // 2 * 16384 // linux boot not yet supported for altera

    /*uint32_t* adresa=(uint32_t*)0x80000000;
    int a,b;
    for(i=0;i<268435456;++i)
    {
        //print_uart_addr(i);
        //print_uart("\n");
        if((i%1024) == 0)
        {
            print_uart_int(i);
            print_uart("\n");           
        }
        a=1;b=2;
        a=3*i+2;
        *adresa = a;
        b = *adresa;
        if(a!=b)
        {
            print_uart("error ");
            print_uart_addr(i);
            print_uart("\n");
        }
        adresa++;
    }*/

    print_uart("res is ");
    print_uart_addr(res);
    print_uart("\n");
    if (res == 0)
    {
        // jump to the address
        __asm__ volatile(
            "li s0, 0x80000000;"
            "la a1, _dtb;"
            "jr s0");
    }


    

    while (1)
    {
        // do nothing
    }
}

void handle_trap(void)
{
    // print_uart("trap\r\n");
}