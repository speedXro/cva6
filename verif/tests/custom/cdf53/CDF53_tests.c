#include <stdio.h>
#include <stdlib.h>
#include "cdf53.h"
#include "CDF53_functions.h"

void gccs(uint8_t label)
{
    uint32_t res;
    __asm__ volatile ("csrr %0, cycle" : "=r" (res));
    
    asm volatile (
		"add x6, x0, %0"
		: 
		: "r" (label)
	);
    
    asm volatile (
		"add x7, %0, x0"
		: 
		: "r" (res) 
	);  
}

int main(void)
{
    int8_t input[16]    = {14,14,18,19,11,12,18,7,14,14,18,19,11,12,18,7};
    //int8_t input[16]    = {-8, -6, -4, -2, 0, 2, 4, 6, 8, 10, 12, 14, 16, 14, 12, 10};

    int16_t low_0[8]; int16_t high_0[8];
    int16_t low_1[8]; int16_t high_1[8];
    int16_t low_2[8]; int16_t high_2[8];

    int8_t output_0[16];
    int8_t output_1[16];
    int8_t output_2[16];

    //**** CDF 5/3 */
    //SW
    gccs(0x10);
    SW_dwt53_forward(input, low_0, high_0);
    gccs(0x14);

    gccs(0x18);
    SW_dwt53_inverse(low_0, high_0, output_0);
    gccs(0x1C);

    //HW friendly implementation
    gccs(0x20);
    HW_dwt53_forward_core(input, low_1, high_1);
    gccs(0x24);

    gccs(0x28);
    HW_dwt53_inverse_core(low_1, high_1, output_1);
    gccs(0x2C);

    //HW real
    gccs(0x30);
    Compute_FDWT_CDF_53(input, low_2, high_2);
    gccs(0x34);

    gccs(0x38);
    Compute_IDWT_CDF_53(low_2, high_2, output_2);
    gccs(0x3C);

    for(int i=0;i<20;++i);

    return 0;
}