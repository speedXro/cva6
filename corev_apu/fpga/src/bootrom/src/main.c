// Copyright OpenHW Group contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "uart.h"
#include "spi.h"
#include "sd.h"
#include "gpt.h"
#include "gpio.h"
#include "upsf.h"
#include "fdct2d.h"
#include "SWDCT2DQ.h"
#include "stft_ref.h"

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

void *memset(void *s, int c, uint32_t n) {
    uint8_t *p = (uint8_t *)s;
    while (n--)
        *p++ = (uint8_t)c;
    return s;
}


void *memcpy(void *dst, const void *src, uint32_t n) {
    uint8_t *d = (uint8_t *)dst;
    const uint8_t *s = (const uint8_t *)src;
    while (n--)
        *d++ = *s++;
    return dst;
}

void *memmove(void *dst, const void *src, uint32_t n) {
    uint8_t *d = (uint8_t *)dst;
    const uint8_t *s = (const uint8_t *)src;
    if (d < s)
        while (n--) *d++ = *s++;
    else {
        d += n; s += n;
        while (n--) *--d = *--s;
    }
    return dst;
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

void FIDCT2DQ_Test(void)
{
    uint64_t i;

    const uint8_t QC = 1;
    uint8_t qm[8][8] = {
        {QC, QC, QC, QC, QC, QC, QC, QC}, 
        {QC, QC, QC, QC, QC, QC, QC, QC}, 
        {QC, QC, QC, QC, QC, QC, QC, QC}, 
        {QC, QC, QC, QC, QC, QC, QC, QC},
        {QC, QC, QC, QC, QC, QC, QC, QC},
        {QC, QC, QC, QC, QC, QC, QC, QC},
        {QC, QC, QC, QC, QC, QC, QC, QC},
        {QC, QC, QC, QC, QC, QC, QC, QC}
    };
    int32_t rm[64];

    uint64_t dur_hw, dur_sw;
    double mpxps_sw; double mpxps_hw;
    double speedup;
    uint64_t sw_m1000, hw_m1000, sp_m1000000;

    uint64_t idur_hw, idur_sw;
    double impxps_sw; double impxps_hw;
    double ispeedup;
    uint64_t isw_m1000, ihw_m1000, isp_m1000000;

    uint64_t *PSRC, *PDST;

    uint64_t fdct_results[512] __attribute__((aligned(0x40)));
    uint64_t idct_results[256] __attribute__((aligned(0x40)));

    uint64_t fdct_results_sw[512] __attribute__((aligned(0x40)));
    uint64_t idct_results_sw[512] __attribute__((aligned(0x40)));

    uint64_t tt_start, tt_stop;
    

    uint64_t points[256] __attribute__((aligned(0x40))) = {
    0xA3F2C81D7E459B06ULL, 0x2F1D8C3A9B4E2F71ULL, 0xC8D3A5914F2E8B1DULL, 0x7A3C9F25E6B14D83ULL,
    0x1C7A2F958E3D6B14ULL, 0xA59C2F713D8E1B4AULL, 0x6F2C9D53B1E4A87FULL, 0x2D5C9A31E8F4B2C6ULL,
    0x5C1A9E37B4F2D806ULL, 0xA3E7C1928D4F6B25ULL, 0x1E9C3A74F2B58D1EULL, 0x6C4A9F37B1D2E854ULL,
    0x3A7F1C96D5E2B481ULL, 0x9C3F7A2EB4D16C85ULL, 0x2F8A3E971D4C9B5FULL, 0xA6E3F2817C4B9D15ULL,
    0x8E2F4A1CB7D39506ULL, 0xF1C4A82E3D9B5F17ULL, 0xA2E8C3F41B6D9A52ULL, 0x7F3C8E14D5A2B936ULL,
    0x4C1F7E93A8D2B546ULL, 0x3E9C1F72B4A57D18ULL, 0x6F2E9C43D1B58A27ULL, 0x9E4C3F16A7B2D581ULL,
    0x1F7C4B9EA2D83651ULL, 0xC9F2A7145E8B3D26ULL, 0xF4A19C827D3E5B14ULL, 0xA6C2F9813E5D7B42ULL,
    0x9C1F4A83D7E2B516ULL, 0x4A8C3F921E6B9D45ULL, 0xF7A2C3845D1E9B67ULL, 0xA3F8C2E16B4D9571ULL,
    0xD4A28F136C5E9B72ULL, 0x3F1A8C4DB9E25F61ULL, 0x7C3A9F14E8D25B43ULL, 0x1F9C4A72A6B3D815ULL,
    0x5E2F8C319D4A7B16ULL, 0xC3F1E8526A9D4C27ULL, 0xB8F2E3154C7A9D62ULL, 0x1E3F8B549A5D2C87ULL,
    0xF3A1C85E2D9B4F71ULL, 0x6C8A3F14B2E79D45ULL, 0x9D2C5F81A4E3B716ULL, 0x3F8B1C92E7A45D26ULL,
    0xB4F2E8371C9A5D63ULL, 0x7A1F3C94D6E2B851ULL, 0xE8C3A5F12D7B4916ULL, 0x4F9A2C71B8E35D18ULL,
    0x2C8F4A96E1B57D32ULL, 0xA7D3F18C5E9B2461ULL, 0x6B1E4C97F3A28D51ULL, 0x9C5F2A83D4B71E36ULL,
    0x3E8A1F72C6D94B52ULL, 0xF2C7B4193A8E5D61ULL, 0x8D3A9F56C2E1B742ULL, 0x1B6C4F82E9A37D51ULL,
    0xD5A2C8F13B7E4916ULL, 0x4F1C9B73A6E28D52ULL, 0x7E3F5A14C8B92D61ULL, 0xB2D4F891A3C57E26ULL,
    0x6A9C3E75F1D28B41ULL, 0xC4B87F23E5A19D62ULL, 0x3D1A5F96B8C2E741ULL, 0x9F4C2B18E7A35D63ULL,
    0xA1F3C85E2D9B4671ULL, 0x5C8A2F14B7E39D42ULL, 0xE9D3A6F12C8B5714ULL, 0x4A1F7C93D5E2B861ULL,
    0x2B8C4F96E1A57D32ULL, 0xA6D2F18C5E9B3471ULL, 0x7B1E3C97F2A48D51ULL, 0x8C5F1A83D4B62E36ULL,
    0x3F8A2E72C6D94B51ULL, 0xF1C7B4193A8D5E61ULL, 0x9D2A8F56C3E1B742ULL, 0x1A6C3F82E8A47D51ULL,
    0xD4A1C8F13B6E5916ULL, 0x5F1C9B73A7E28D42ULL, 0x6E3F4A14C9B82D61ULL, 0xB1D3F891A4C57E26ULL,
    0x7A8C2E75F1D39B41ULL, 0xC3B87F23E6A18D62ULL, 0x2D1A4F96B9C3E741ULL, 0x8F3C1B18E6A25D63ULL,
    0xF2A4C85E3D8B5671ULL, 0x4C9A1F14B6E38D42ULL, 0xE8D2A6F13C9B4714ULL, 0x5A2F6C93D4E1B861ULL,
    0x1B9C3F96E2A47D32ULL, 0xA5D1F28C6E8B3471ULL, 0x6B2E4C97F3A58D51ULL, 0x9C4F2A83D5B71E36ULL,
    0x2E9A1F72C7D83B51ULL, 0xF3C6B4193B8D4E61ULL, 0x8D1A9F56C4E2B742ULL, 0x2A5C4F82E9B36D51ULL,
    0xD3A2C8F14B5E6916ULL, 0x4E2C8B73A6F19D42ULL, 0x7F2E5A14C8B93D61ULL, 0xB3D2F891A5C46E26ULL,
    0x5A9C1E75F2D38B41ULL, 0xC2B96F23E7A28D62ULL, 0x1D2A3F96B8C4E741ULL, 0x9F2C1B18E5A36D63ULL,
    0xE3A5C84E2D9B6571ULL, 0x3C8A1F24B5E49D42ULL, 0xF9D3A5F12C8B6714ULL, 0x4B1F5C93D3E2B861ULL,
    0x2A8C2F96E3A56D32ULL, 0xB5D2F18C7E9A3471ULL, 0x5B1E3C97F4A69D51ULL, 0x8C3F1A83D6B52E36ULL,
    0x1E8A3F72C5D94B51ULL, 0xF4C5B4193C8D3E61ULL, 0x7D2A8F56C5E3B742ULL, 0x3A4C5F82E8B47D51ULL,
    0xD2A3C8F15B4E7916ULL, 0x3E1C9B73A8F28D42ULL, 0x6F1E4A14C7B94D61ULL, 0xB4D1F891A6C35E26ULL,
    0x4A8C3E75F3D27B41ULL, 0xC1B85F23E8A39D62ULL, 0x3D1A2F96B7C5E741ULL, 0x8E1C2B18F5A47D63ULL,
    0xC4A6F85E1D8B7471ULL, 0x2C9A3F14B4E58D42ULL, 0xE8D4A5F23C9B5714ULL, 0x3B2F4C93D2E1B961ULL,
    0x1A9C1F96E4A65D32ULL, 0xB4D3F28C8E9A2471ULL, 0x4B2E2C97F5A78D51ULL, 0x7C2F1A83D7B43E36ULL,
    0x3F7A4E72C4D85B51ULL, 0xF5C4B4193D8C2E61ULL, 0x6D3A8F56C6E4B742ULL, 0x4B3C6F82E7A58D51ULL,
    0xD1A4C8F16B3E8916ULL, 0x2E3C9B73A9F37D42ULL, 0x5F3E3A14C6B85D61ULL, 0xB5D4F891A7B24E26ULL,
    0x3A7C4E75F4D16B41ULL, 0xC8B74F23E9A48D62ULL, 0x4D2A1F96B6C6E741ULL, 0x7E2C3B18F4A58D63ULL,
    0xD5A7F85E2D7B8471ULL, 0x1C8A4F14B3E67D42ULL, 0xE7D5A4F34C8B4714ULL, 0x2B3F3C93D1E2BA61ULL,
    0x3A8C8F96E5A74D32ULL, 0xC3D4F28C9E8A1471ULL, 0x3B3E1C97F6A87D51ULL, 0x6C1F2A83D8B34E36ULL,
    0x4E6A5E72C3D96B51ULL, 0xF6C3B4193E8C1E61ULL, 0x5D4A8F56C7E5B742ULL, 0x5B2C7F82E6B69D51ULL,
    0xD8A5C8F17B2E9916ULL, 0x1E4C9B73BAF46D42ULL, 0x4F4E2A14C5B96E61ULL, 0xB6D5F891A8B13E26ULL,
    0x2A6C5E75F5D25B41ULL, 0xC7B63F23EAA57D62ULL, 0x5D3A8F96B5C7E741ULL, 0x6E3C4B18F3A69D63ULL,
    0xE6A8F85E3C6B9471ULL, 0x8C7A5F14B2E78D42ULL, 0xE6D6A3F45D8B3714ULL, 0x1B4F2C93D8E3BB61ULL,
    0x4B7C9F96E6A83D32ULL, 0xD2E5F28CAEBA8471ULL, 0x2B4F8C97F7A96D51ULL, 0x5C8E3A83D9B25E36ULL,
    0x5F5A6E72C2DA7B51ULL, 0xF7C2B4193F8B8E61ULL, 0x4E5A8F56C8E6B742ULL, 0x6B1C8F82E5B7AD51ULL,
    0xD7A6C8F18B1EAA16ULL, 0x8E5C9B73CBF55D42ULL, 0x3F5E1A14C4BA7F61ULL, 0xB7D6F891A9A22E26ULL,
    0x1A5C6E75F6D34B41ULL, 0xC6B52F23EBA66C62ULL, 0x6E4A9F96B4C8E741ULL, 0x5E4C5B18F2A7AD63ULL,
    0xF7A9F85E4B5BAA71ULL, 0x9C6A6F14B1E89D42ULL, 0xE5D7A2F56E8B2714ULL, 0x8B5F1C93D7E4BC61ULL,
    0x5B6CAF96E7A92D32ULL, 0xE1F6F28CBFBA7471ULL, 0x1B5F7C97F8AA5D51ULL, 0x4C7F4A83DAB16E36ULL,
    0x6E4A7E72C1DB8B51ULL, 0xF8C1B419408AAE61ULL, 0x3F6A8F56C9E7B742ULL, 0x7B8C9F82E4B8BE51ULL,
    0xD6A7C8F19B8EBB16ULL, 0x9F6CAB73DCF64D42ULL, 0x2F6F8A14C3BB8061ULL, 0xB8D7F891AAA11E26ULL,
    0x8A4C7E75F7D43B41ULL, 0xC5B41F23ECA77B62ULL, 0x7F5AAFF6B3C9E741ULL, 0x4F5C6B18F1A8BE63ULL,
    0x08AAFE5E5A4ABB71ULL, 0xAC5A7F14B8E9AD42ULL, 0xE4D8A1F67F8B1714ULL, 0x9B6E8C93D6E5BD61ULL,
    0x6B5BBF96E8AA1D32ULL, 0xF8F7F28CD0BA6471ULL, 0x8B6F6C97F9BB4D51ULL, 0x3C6F5A83DBB07E36ULL,
    0x7F3A8E72C8DC9B51ULL, 0xF9C8B41941ABBD61ULL, 0x2F7A8F56CAE8B742ULL, 0x8BACACF82E3B9CF5ULL,
    0xD5A8C8F1AABECB16ULL, 0xAF7CBB73EDF74D42ULL, 0x1F7F7914C2BC9161ULL, 0xB9D8F891ABA80E26ULL,
    0x9A3C8E75F8D52B41ULL, 0xC4B38F23EDC88A62ULL, 0x806BBFF6B2CAE741ULL, 0x3F6C7B18F8A9CF63ULL,
    0x19BBFD5E6B39CC71ULL, 0xBC4A8F14B7EABE42ULL, 0xE3D9A8F780AB8714ULL, 0xAB7F5C93D5E6BE61ULL,
    0x7B4CCF96E9BB8D32ULL, 0x0908F28CE1BA5471ULL, 0x9B7F5C97FACC3D51ULL, 0x2C5E6A83DCB18E36ULL,
    0x8E2A9E72C7DDAB51ULL, 0xFACFB41942BCCC61ULL, 0x1F8A8F56CBE9B742ULL, 0x9CBCADF82F2AADD1ULL,
    0xD4A9C8F1BBBFDC16ULL, 0xB08DCB73FEF84D42ULL, 0x8F8F6814C1BDAB61ULL, 0xBAD9F891BCB9FE26ULL,
    0xAA2C9E75F9E61B41ULL, 0xC3B27F23EEC99B62ULL, 0x917CCFF6B1CBF741ULL, 0x2F7C8B18F9AADF63ULL,
    0xD5A7F85E2D7B8471ULL, 0x1C8A4F14B3E67D42ULL, 0xE7D5A4F34C8B4714ULL, 0x2B3F3C93D1E2BA61ULL,
    0x3A8C8F96E5A74D32ULL, 0xC3D4F28C9E8A1471ULL, 0x3B3E1C97F6A87D51ULL, 0x6C1F2A83D8B34E36ULL,
    0x4E6A5E72C3D96B51ULL, 0xF6C3B4193E8C1E61ULL, 0x5D4A8F56C7E5B742ULL, 0x5B2C7F82E6B69D51ULL,
    };

    for(i=0;i<512;++i) {fdct_results[i] = 0xFFFFFFFFFFFFFFFFul;}
    for(i=0;i<256;++i) {idct_results[i] = 0xFFFFFFFFFFFFFFFFul;}

    //FDCT Compute SW vs HW************************************************************
    PSRC = &points[0];
    PDST = &fdct_results_sw[0];

    LLM_FDCT_2D_Q_get_reciprocals_for_qantization_components(rm, &qm[0][0]);
    tt_start = gccs();
    for(int i=0;i<32;i++)
        LLM_FDCT_2D_Q_u8_2_s13(PSRC+i*0x8, PDST+i*0x10, rm);
    tt_stop =  gccs();
    dur_sw = tt_stop - tt_start;

    RVEXP_DMA_SelectDevice(0);
    tt_start = gccs();
    RVEXP_DMA_Transaction(points, fdct_results, 2048, 4096);
    tt_stop =  gccs();
    dur_hw = tt_stop - tt_start;

    sw_m1000 = 204800000ull / dur_sw;
    hw_m1000 = 204800000ull / dur_hw;

    sp_m1000000 = dur_sw * 1000000ull / dur_hw;

    //IDCT Compute SW vs HW************************************************************
    PSRC = &fdct_results_sw[0];
    PDST = &idct_results_sw[0];

    tt_start = gccs();
    for(int i=0;i<32;i++)
        LLM_IDCT_2D_Q_s13_2_u8(PSRC+i*0x10, PDST+i*0x8, qm);
    tt_stop =  gccs();
    idur_sw = tt_stop - tt_start;

    RVEXP_DMA_SelectDevice(1);
    tt_start = gccs();
    RVEXP_DMA_Transaction(fdct_results, idct_results, 4096, 2048);
    tt_stop =  gccs();
    idur_hw = tt_stop - tt_start;

    isw_m1000 = 204800000ull / idur_sw;
    ihw_m1000 = 204800000ull / idur_hw;

    isp_m1000000 = idur_sw * 1000000ull / idur_hw;
    

    printf("-------------------------------------------------------------------------------\n");
    printf("TUIASI FDCT2DQ RISC-V Accelerator statistics:\n");
    printf("Processing 32 blocks of 64 pixels (8 X 8-bit pixels)\n");
    printf("*******************************************************************************\n");
    printf("SW FDCT2DQ Implementation: %lu cycles @ 100 MHz -> %4lu.%03lu MPixels/s\n",
        (uint64_t)dur_sw, sw_m1000 / 1000u, sw_m1000 % 1000u);
    printf("*******************************************************************************\n");
    printf("HW FDCT2DQ Accelerator   : %lu cycles @ 100 MHz -> %4lu.%03lu MPixels/s\n",
        (uint64_t)dur_hw, hw_m1000 / 1000u, hw_m1000 % 1000u);
    printf("*******************************************************************************\n");
    printf("Hardware Acceleration Speedup = %lu.%06lu x\n",
        sp_m1000000 / 1000000u, sp_m1000000 % 1000000u);
    printf("-------------------------------------------------------------------------------\n\n");

    printf("-------------------------------------------------------------------------------\n");
    printf("TUIASI IDCT2DQ RISC-V Accelerator statistics:\n");
    printf("Processing 32 blocks of 64 pixels (8 X 16-bit pixels)\n");
    printf("*******************************************************************************\n");
    printf("SW IDCT2DQ Implementation: %lu cycles @ 100 MHz -> %4lu.%03lu MPixels/s\n",
        (uint64_t)idur_sw, isw_m1000 / 1000u, isw_m1000 % 1000u);
    printf("*******************************************************************************\n");
    printf("HW IDCT2DQ Accelerator   : %lu cycles @ 100 MHz -> %4lu.%03lu MPixels/s\n",
        (uint64_t)idur_hw, ihw_m1000 / 1000u, ihw_m1000 % 1000u);
    printf("*******************************************************************************\n");
    printf("Hardware Acceleration Speedup = %lu.%06lu x\n",
        isp_m1000000 / 1000000u, isp_m1000000 % 1000000u);
    printf("-------------------------------------------------------------------------------\n\n");
}

void STFT_Test(void)
{
    int i;

    uint64_t dur_hw, dur_sw;
    double speedup;
    uint64_t sw_m1000, hw_m1000, sp_m1000000;

    uint64_t *PSRC, *PDST;

    uint64_t tt_start, tt_stop;

    uint64_t stft_data_in_init_u64[64] __attribute__((aligned(0x40))) = {
        0xffffc943000010b4ULL, 0x000077a3ffffca66ULL, 0x00000a2c000012a3ULL, 0x00005111ffff9218ULL,
        0xffffc9bcffffc970ULL, 0x00000ac7fffff8b4ULL, 0x000053f5ffffc485ULL, 0x0000676200000294ULL,
        0x00003607ffffc311ULL, 0x0000708bffff8752ULL, 0x0000619bffffb314ULL, 0x0000598b000072aaULL,
        0x000068f7ffffeb2cULL, 0x000072de00007d80ULL, 0xffffea30ffffa9fbULL, 0xffffc150ffffa040ULL,
        0x00000b77000057b1ULL, 0xfffffaaeffff8cb5ULL, 0xffff90e800006621ULL, 0x000022030000354cULL,
        0xffffe093000053d9ULL, 0x00003c2400001fa9ULL, 0xfffff4bb0000741eULL, 0x00000a9b0000170cULL,
        0xffffd303ffff9228ULL, 0x000004da00000ef6ULL, 0xfffff835ffffad9dULL, 0xffffcd3affff81dcULL,
        0x00002ed6ffffb658ULL, 0x0000194f00003aceULL, 0xffffd6c1000050bbULL, 0x000049bb00000bd2ULL,
        0xffffa9cb000061e6ULL, 0xffffa554ffffd650ULL, 0x00001b6effffc3cfULL, 0x00002d5c000037b2ULL,
        0x00001b68fffff270ULL, 0xffff954800004cb2ULL, 0xffffe673ffffd402ULL, 0xfffff533ffff8568ULL,
        0x00005028ffffc573ULL, 0xffff8458ffffbcf2ULL, 0xffffdb3600002112ULL, 0x00007a7c00001c97ULL,
        0x0000459300003dd7ULL, 0xffffc5d0ffffd1d3ULL, 0xffffcbec00004aeeULL, 0xffffcfceffffdd2dULL,
        0xffff8dde00006898ULL, 0xffffa059ffffb7b7ULL, 0x0000400a00002e16ULL, 0xffffdf7400006d14ULL,
        0xffffc75b00003a7dULL, 0xffffcd6900006637ULL, 0x000038e3000055aaULL, 0x00007383ffff94edULL,
        0x000016c00000637dULL, 0x000004de000061e2ULL, 0xffffbcc5ffffa656ULL, 0xffffd7e7000068f1ULL,
        0x0000720cffffd72fULL, 0xfffff865ffffbf25ULL, 0xffffcd53ffffebfcULL, 0xffffb44bffffa548ULL
    };

    int16_t stft_data_in_init_i16[128] __attribute__((aligned(0x40))) = {
        4276, -14013, -13722, 30627, 4771, 2604, -28136, 20753, -13968, -13892, -1868, 2759, -15227, 21493, 660, 26466,
        -15599, 13831, -30894, 28811, -19692, 24987, 29354, 22923, -5332, 26871, 32128, 29406, -22021, -5584, -24512, -16048,
        22449, 2935, -29515, -1362, 26145, -28440, 13644, 8707, 21465, -8045, 8105, 15396, 29726, -2885, 5900, 2715,
        -28120, -11517, 3830, 1242, -21091, -1995, -32292, -12998, -18856, 11990, 15054, 6479, 20667, -10559, 3026, 18875,
        25062, -22069, -10672, -23212, -15409, 7022, 14258, 11612, -3472, 7016, 19634, -27320, -11262, -6541, -31384, -2765,
        -14989, 20520, -17166, -31656, 8466, -9418, 7319, 31356, 15831, 17811, -11821, -14896, 19182, -13332, -8915, -12338,
        26776, -29218, -18505, -24487, 11798, 16394, 27924, -8332, 14973, -14501, 26167, -12951, 21930, 14563, -27411, 29571,
        25469, 5824, 25058, 1246, -22954, -17211, 26865, -10265, -10449, 29196, -16603, -1947, -5124, -12973, -23224, -19381
    };

    uint64_t stft_data_out_u64[32] __attribute__((aligned(0x40)))= {0};
    uint32_t sw_out[64] __attribute__((aligned(0x40)))= {0};

    STFT_Config stft_config;
    STFT_Config stft_config_old;

    stft_config.enable = 1;
    stft_config.out_format = FMT_PIX8;
    stft_config.window_sel = WSEL_HANN;
    stft_config.pix_flor = 0;

    tt_start = gccs();
    stft_ref_pixel(stft_data_in_init_i16, 1, 0, sw_out);
    tt_stop = gccs();
    dur_sw = tt_stop - tt_start;

    STFT_Reset();
    STFT_Configure(stft_config, &stft_config_old);
    STFT_Start();

    tt_start = gccs();
    RVEXP_DMA_SelectDevice(2);
    RVEXP_DMA_Transaction(stft_data_in_init_u64, stft_data_out_u64, 512, 256);
    tt_stop = gccs();
    dur_hw = tt_stop - tt_start;

    STFT_Status stft_stat = STFT_GetStatus();

    STFT_Reset();
    stft_stat = STFT_GetStatus();

    sp_m1000000 = dur_sw * 1000000ull / dur_hw;

    printf("-------------------------------------------------------------------------------\n");
    printf("TUIASI STFT RISC-V Accelerator statistics:\n");
    printf("Processing 128 samples (signed 16 bits):\n");
    printf("*******************************************************************************\n");
    printf("SW STFT Implementation: %lu cycles @ 100 MHz\n",
        (uint64_t)dur_sw);
    printf("*******************************************************************************\n");
    printf("HW STFT Accelerator   : %lu cycles @ 100 MHz\n",
        (uint64_t)dur_hw);
    printf("*******************************************************************************\n");
    printf("Hardware Acceleration Speedup = %lu.%06lu x\n",
        sp_m1000000 / 1000000u, sp_m1000000 % 1000000u);
    printf("-------------------------------------------------------------------------------\n\n");
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
