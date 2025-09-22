// Copyright OpenHW Group contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "uart.h"
#include "spi.h"
#include "sd.h"
#include "gpt.h"

#include "../../../../../verif/tests/custom/riscada/ADA_functions.h"

// 1 second at 50MHz
#define SECOND_CYCLES   (50 * 1000 * 1000)
#define WAIT_SECONDS    (5)

void Application_RiscADA(void);

uintptr_t start;
uintptr_t stop;

uint16_t DA_values[16] = {
    0x100,0x200,0x300,0x400,
    0x500,0x600,0x700,0x800,
    0x900,0xA00,0xB00,0xC00,
    0xD00,0xE00,0xF00,0x000
};

static inline uintptr_t get_cycle_count() {
    uintptr_t cycle;
    __asm__ volatile ("csrr %0, cycle" : "=r" (cycle));
    return cycle;
}

void Application_RiscADA(void)
{
    uint16_t i;
    
    uint16_t DA_get=0;
    uint16_t AD_get=0;
    uint32_t ts=0;

    uint8_t rxb;
    uint32_t retts=0;
    uint16_t retda=0;
    uint16_t retad=0;

    uint8_t exit_now=0;

    for(i=0;i<16;++i)
    {
        DA_get=0;
        AD_get=0;
        DA_SetValue(0, DA_values[i]);
        print_uart_int(DA_values[i]);
        print_uart("\r\n");
        start = get_cycle_count();
        while(get_cycle_count() - start < SECOND_CYCLES/10) {}
        DA_GetValue(0, &DA_get);
        print_uart_int(DA_get);
        print_uart("\r\n");
        AD_Get_ADC_Val(0, &ts, &AD_get);
        print_uart_int(AD_get);
        print_uart("\r\n");
        start = get_cycle_count();
        while(get_cycle_count() - start < SECOND_CYCLES/10) {}
    }

    while (exit_now==0)
    {
        if(read_serial(&rxb)==1)
        {
            switch(rxb)
            {
                case '0': DA_SetValue(0,0x000); break;
                case '1': DA_SetValue(0,0x100); break;
                case '2': DA_SetValue(0,0x200); break;
                case '3': DA_SetValue(0,0x300); break;
                case '4': DA_SetValue(0,0x400); break;
                case '5': DA_SetValue(0,0x500); break;
                case '6': DA_SetValue(0,0x600); break;
                case '7': DA_SetValue(0,0x700); break;
                case '8': DA_SetValue(0,0x800); break;
                case '9': DA_SetValue(0,0x900); break;
                case 'A': DA_SetValue(0,0xA00); break;
                case 'B': DA_SetValue(0,0xB00); break;
                case 'C': DA_SetValue(0,0xC00); break;
                case 'D': DA_SetValue(0,0xD00); break; 
                case 'E': DA_SetValue(0,0xE00); break;
                case 'F': DA_SetValue(0,0xF00); break;
                case 'G': DA_SetValue(0,0xFFF); break;
                case 'j':
                case 'J': DA_SetValue(0,0x000); exit_now = 1; break;
                default : DA_SetValue(0,0x000); break;
            }
            DA_GetValue(0, &retda);
            
            start = get_cycle_count();
            while(get_cycle_count() - start < 10000) {}
            
            AD_Get_ADC_Val(0, &retts, &retad);
            
            print_uart("Configured value is ");
            print_uart_int(retda);
            print_uart("\n");

            print_uart_int(retts);
            print_uart(" : ");
            print_uart("Measured value is ");
            print_uart_int(retad);
            print_uart("\n\n");
        }
        start = get_cycle_count();
        while(get_cycle_count() - start < 100) {}
    }
    
    
}


int main()
{
    init_uart(100000000, 115200); //not needed in intel setup as UART IP is already configured via HW
    print_uart("Hello World DC TUIASI!\r\n");
    print_uart("\r\n");
    
    Application_RiscADA();

    int res;
    print_uart(" booting!\r\n");
    res = gpt_find_boot_partition((uint8_t *)0x80000000UL, 2 * 16384); // 2 * 16384 // linux boot not yet supported for altera

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