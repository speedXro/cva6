// Copyright OpenHW Group contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "uart.h"
#include "spi.h"
#include "sd.h"
#include "gpt.h"

//#include "../../../../../verif/tests/custom/riscada/ADA_functions.h"

#include "../../../../../verif/tests/custom/dwt/DiWaTo_functions.h"
#include "../../../../../verif/tests/custom/dwt/dwt.h"

// 1 second at 50MHz
#define SECOND_CYCLES   (50 * 1000 * 1000)
#define WAIT_SECONDS    (5)

//void Application_RiscADA(void);

uint64_t gccs(void);
void Print_Array_I8(const char* label, int8_t array[16]);
void Print_Array_I16(const char* label, int16_t array[8]);
void Aplication_DWT(void);

static inline uintptr_t get_cycle_count() {
    uintptr_t cycle;
    __asm__ volatile ("csrr %0, cycle" : "=r" (cycle));
    return cycle;
}

/*static uint32_t gccs()
{
    uint32_t res;
    __asm__ volatile ("csrr %0, cycle" : "=r" (res));
    return res;
}*/

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

void Print_Array_I8(const char* label, int8_t array[16])
{
    print_uart(label);
    print_uart("\r\n");
    print_uart("[");
    for(int i=0;i<15;++i)
    {
        print_uart_int(array[i]);
        print_uart(", ");
    }
    print_uart_int(array[15]);
    print_uart("]\r\n\r\n");
}

void Print_Array_I16(const char* label, int16_t array[8])
{
    print_uart(label);
    print_uart("\r\n");
    print_uart("[");
    for(int i=0;i<7;++i)
    {
        print_uart_int(array[i]);
        print_uart(", ");
    }
    print_uart_int(array[7]);
    print_uart("]\r\n\r\n");
}

void Aplication_DWT(void)
{
    uint64_t t_start=0;
    uint64_t t_stop=0;
    uint64_t tdiff=0;

    int8_t input[16]    = {14,14,18,19,11,12,18,7,14,14,18,19,11,12,18,7};

    int16_t low_0[8]; int16_t high_0[8];
    int16_t low_1[8]; int16_t high_1[8];
    int16_t low_2[8]; int16_t high_2[8];
    int16_t low_3[8]; int16_t high_3[8];
    int16_t low_4[8]; int16_t high_4[8];
    int16_t low_5[8]; int16_t high_5[8];

    int8_t output_0[16];
    int8_t output_1[16];
    int8_t output_2[16];
    int8_t output_3[16];
    int8_t output_4[16];
    int8_t output_5[16];


    //CDF 5/3
    //SW
    t_start = gccs();
    SW_dwt53_forward(input, low_0, high_0);
    t_stop = gccs();
    print_uart("FDWT CDF 5/3 SW   :\r\n");
    tdiff = t_stop-t_start;
    print_uart_int(tdiff);
    print_uart("\r\n");

    t_start = gccs();
    SW_dwt53_inverse(low_0, high_0, output_0);
    t_stop = gccs();
    print_uart("IDWT CDF 5/3S W   :\r\n");
    tdiff = t_stop-t_start;
    print_uart_int(tdiff);
    print_uart("\r\n");

    //HW but SW
    t_start = gccs();
    HW_dwt53_forward_core(input, low_1, high_1);
    t_stop = gccs();
    print_uart("FDWT CDF 5/3 HW-SW:\r\n");
    tdiff = t_stop-t_start;
    print_uart_int(tdiff);
    print_uart("\r\n");

    t_start = gccs();
    HW_dwt53_inverse_core(low_1, high_1, output_1);
    t_stop = gccs();
    print_uart("IDWT CDF 5/3 HW-SW:\r\n");
    tdiff = t_stop-t_start;
    print_uart_int(tdiff);
    print_uart("\r\n");

    //HW real
    t_start = gccs();
    Compute_FDWT_CDF_53(input, low_2, high_2);
    t_stop = gccs();
    print_uart("FDWT CDF 5/3 HW   :\r\n");
    tdiff = t_stop-t_start;
    print_uart_int(tdiff);
    print_uart("\r\n");

    t_start = gccs();
    Compute_IDWT_CDF_53(low_2, high_2, output_2);
    t_stop = gccs();
    print_uart("IDWT CDF 5/3 HW   :\r\n");
    tdiff = t_stop-t_start;
    print_uart_int(tdiff);
    print_uart("\r\n");

    Print_Array_I8("Input:", input);

    Print_Array_I16("SW_FDWT_CDF_53_low", low_0);
    Print_Array_I16("SW_FDWT_CDF_53_high", high_0);
    Print_Array_I8("SW_IDWT_CDF_53_output", output_0);

    Print_Array_I16("HW-SW_FDWT_CDF_53_low", low_1);
    Print_Array_I16("HW-SW_FDWT_CDF_53_high", high_1);
    Print_Array_I8("HW-SW_IDWT_CDF_53_output", output_1);

    Print_Array_I16("HW_FDWT_CDF_53_low", low_2);
    Print_Array_I16("HW_FDWT_CDF_53_high", high_2);
    Print_Array_I8("HW_IDWT_CDF_53_output", output_2);

    print_uart("\r\n");

    //DB8
    //SW
    t_start = gccs();
    SW_dwt_db8_int16(input, low_3, high_3);
    t_stop = gccs();
    print_uart("FDWT DB8 SW   :\r\n");
    tdiff = t_stop-t_start;
    print_uart_int(tdiff);
    print_uart("\r\n");

    t_start = gccs();
    SW_idwt_db8_int16(low_3, high_3, output_3);
    t_stop = gccs();
    print_uart("IDWT DB8 SW   :\r\n");
    tdiff = t_stop-t_start;
    print_uart_int(tdiff);
    print_uart("\r\n");

    //HW but SW
    t_start = gccs();
    HW_dwt_db8_int16_core(input, low_4, high_4);
    t_stop = gccs();
    print_uart("FDWT DB8 HW-SW:\r\n");
    tdiff = t_stop-t_start;
    print_uart_int(tdiff);
    print_uart("\r\n");

    t_start = gccs();
    HW_idwt_db8_int16_core(low_4, high_4, output_4);
    t_stop = gccs();
    print_uart("IDWT DB8 HW-SW:\r\n");
    tdiff = t_stop-t_start;
    print_uart_int(tdiff);
    print_uart("\r\n");

    //HW real
    t_start = gccs();
    Compute_FDWT_DB_8(input, low_5, high_5);
    t_stop = gccs();
    print_uart("FDWT DB8 HW   :\r\n");
    tdiff = t_stop-t_start;
    print_uart_int(tdiff);
    print_uart("\r\n");

    t_start = gccs();
    Compute_IDWT_DB_8(low_5, high_5, output_5);
    t_stop = gccs();
    print_uart("IDWT DB8 HW   :\r\n");
    tdiff = t_stop-t_start;
    print_uart_int(tdiff);
    print_uart("\r\n");

    //prints
    Print_Array_I8("Input:", input);

    Print_Array_I16("SW_FDWT_DB_8_low", low_3);
    Print_Array_I16("SW_FDWT_DB_8_high", high_3);
    Print_Array_I8("SW_IDWT_DB_8_output", output_3);

    Print_Array_I16("HW-SW_FDWT_DB_8_low", low_4);
    Print_Array_I16("HW-SW_FDWT_DB_8_high", high_4);
    Print_Array_I8("HW-SW_IDWT_DB_8_output", output_4);

    Print_Array_I16("HW_FDWT_DB_8_low", low_5);
    Print_Array_I16("HW_FDWT_DB_8_high", high_5);
    Print_Array_I8("HW_IDWT_DB_8_output", output_5);
}

int main()
{
    init_uart(100000000, 115200); //not needed in intel setup as UART IP is already configured via HW
    print_uart("Hello World DC TUIASI!\r\n");
    print_uart("\r\n");
    
    Aplication_DWT();

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