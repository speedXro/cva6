// Copyright OpenHW Group contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "uart.h"
#include "spi.h"
#include "sd.h"
#include "gpt.h"
#include "../../../../../verif/tests/custom/cdf53/CDF53_functions.h"
#include "../../../../../verif/tests/custom/cdf53/cdf53.h"
#include "../../../../../verif/tests/custom/cdf53/compression.h"

// 1 second at 50MHz
#define SECOND_CYCLES   (50 * 1000 * 1000)
#define WAIT_SECONDS    (5)

uint64_t gccs(void);

int Application_CDF53_Compression_SW(void);
int Application_CDF53_Compression_HW(void);


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

int Application_CDF53_Compression_SW(void)
{
    uint64_t t_start=0;
    uint64_t t_stop=0;
    uint64_t tdiff=0;

    uint8_t text[NBYTES];
    make_text_1024(text);

 
    uint8_t stream[NBYTES * 4];
    uint8_t *p = stream;

    t_start = gccs();
    for (int b = 0; b < NBYTES/BLK; b++)
    {
        int8_t blk[BLK];
        for (int i = 0; i < BLK; i++)
        {
            blk[i] = (int8_t)((int)text[b*BLK + i] - 128);
        }
        size_t used = SW_encode_block_53_varbyte(blk, p, (size_t)(NBYTES*4 - (p - stream)));
        if (used == 0)
        {
            return 1;
        }
        p += used;
    }
    size_t enc_size = (size_t)(p - stream);
    t_stop = gccs();
    tdiff = t_stop-t_start;
    print_uart("Compression SW :\r\n");
    print_uart_int(tdiff);
    print_uart("\r\n");

    uint8_t *src = stream;
    uint8_t *end = stream + enc_size;
    t_start = gccs();
    for (int b = 0; b < NBYTES/BLK; b++){
        int8_t recon_blk[BLK];
        size_t used = SW_decode_block_53_varbyte(src, (size_t)(end - src), recon_blk);
        if (used == 0)
        {
            return 1;
        }
        for (int i = 0; i < BLK; i++)
        {
            int recon_byte = (int)recon_blk[i] + 128;
            if (recon_byte != (int)text[b*BLK + i])
            {
                return 1;
            }
        }
        src += used;
    }
    t_stop = gccs();
    tdiff = t_stop-t_start;
    print_uart("De-Compression SW :\r\n");
    print_uart_int(tdiff);
    print_uart("\r\n");

    return 0;
}

int Application_CDF53_Compression_HW(void)
{
    uint64_t t_start=0;
    uint64_t t_stop=0;
    uint64_t tdiff=0;

    uint8_t text[NBYTES];
    make_text_1024(text);

    uint8_t stream[NBYTES * 4];
    uint8_t *p = stream;

    t_start = gccs();
    for (int b = 0; b < NBYTES/BLK; b++)
    {
        int8_t blk[BLK];
        for (int i = 0; i < BLK; i++)
        {
            blk[i] = (int8_t)((int)text[b*BLK + i] - 128);
        }
        size_t used = HW_encode_block_53_varbyte(blk, p, (size_t)(NBYTES*4 - (p - stream)));
        if (used == 0)
        {
            return 1;
        }
        p += used;
    }
    size_t enc_size = (size_t)(p - stream);
    t_stop = gccs();
    tdiff = t_stop-t_start;
    print_uart("Compression HW :\r\n");
    print_uart_int(tdiff);
    print_uart("\r\n");

    uint8_t *src = stream;
    uint8_t *end = stream + enc_size;
    t_start = gccs();
    for (int b = 0; b < NBYTES/BLK; b++){
        int8_t recon_blk[BLK];
        size_t used = HW_decode_block_53_varbyte(src, (size_t)(end - src), recon_blk);
        if (used == 0)
        {
            return 1;
        }
        for (int i = 0; i < BLK; i++){
            int recon_byte = (int)recon_blk[i] + 128;
            if (recon_byte != (int)text[b*BLK + i]){
                return 1;
            }
        }
        src += used;
    }
    t_stop = gccs();
    tdiff = t_stop-t_start;
    print_uart("De-Compression HW :\r\n");
    print_uart_int(tdiff);
    print_uart("\r\n");

    return 0;
}


int main()
{
    int result_SW, result_HW;

    init_uart(100000000, 115200); //not needed in intel setup as UART IP is already configured via HW
    print_uart("Hello World DC TUIASI!\r\n");
    print_uart("\r\n");
    
    result_SW = Application_CDF53_Compression_SW();
    result_HW = Application_CDF53_Compression_HW();

    if(result_SW == 0) print_uart("SW_SUCESS\r\n"); else print_uart("SW_ERROR\r\n");
    if(result_HW == 0) print_uart("HW_SUCESS\r\n"); else print_uart("HW_ERROR\r\n");

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