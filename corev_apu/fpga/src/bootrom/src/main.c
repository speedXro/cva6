// Copyright OpenHW Group contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "uart.h"
#include "spi.h"
#include "sd.h"
#include "gpt.h"
#include "gpio.h"
#include "upsf.h"

//#include <stdint.h>

// 1 second at 50MHz
#define SECOND_CYCLES   (100 * 1000 * 1000)
#define MS_CYCLES       (100 * 1000)
#define WAIT_SECONDS    (5)

uint64_t gccs(void);
void DelayMs(int d);
uint8_t ReadU8(void);
uint8_t GetNibble(char);
void Application(void);

uint64_t start;
uint64_t stop;

static inline uintptr_t get_cycle_count() {
    uintptr_t cycle;
    __asm__ volatile ("csrr %0, cycle" : "=r" (cycle));
    return cycle;
}

uint64_t gccs(void)
{
    uint64_t res;
    uint64_t result;
    __asm__ volatile ("csrr %0, cycle" : "=r" (res));

    asm volatile (
		"add %0, %1, x0"
		: "=r" (result)
		: "r" (res)
	);  

    return result;
}

void DelayMs(int d)
{
    uintptr_t t_start;

    t_start = get_cycle_count();
    while(get_cycle_count() - t_start < (d * MS_CYCLES)) {}
}

uint8_t ReadU8(void)
{
    uint8_t rxb = 0xFF;

    while(1)
    {
        if(read_serial(&rxb)==1)
        {
            return rxb;
        }
        start = get_cycle_count();
        while(get_cycle_count() - start < 100) {}
    }
    
    return 0xFF;
}

uint8_t GetNibble(char c)
{
    switch(c)
    {
        case '0': return  0;
        case '1': return  1;
        case '2': return  2;
        case '3': return  3;
        case '4': return  4;
        case '5': return  5;
        case '6': return  6;
        case '7': return  7;
        case '8': return  8;
        case '9': return  9;
        case 'A': 
        case 'a': return 10;
        case 'B': 
        case 'b': return 11;
        case 'C': 
        case 'c': return 12;
        case 'D': 
        case 'd': return 13;
        case 'E': 
        case 'e': return 14;
        case 'F': 
        case 'f': return 15;
        default:  return  0;
    }
}

void Application(void)
{
    uint16_t i,j;
    
    uint8_t ch;
    
    uint8_t exit_now=0;

    while (exit_now==0)
    {
        print_uart("Options: 0 = Boot to Linux\r\n");
        ch = ReadU8();
        if(ch == '0') exit_now=1;
    }
}


int main()
{

    init_uart(100000000, 115200); //not needed in intel setup as UART IP is already configured via HW
    print_uart("TUIASI Department of Computing\r\n");

    print_uart("\r\n");

    Application();

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
