#include <stdio.h>
#include <stdlib.h>
#include "dwt.h"
#include "DiWaTo_functions.h"

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
    //int8_t input[16]    = {14,14,18,19,11,12,18,7,14,14,18,19,11,12,18,7};
    int8_t input[16]    = {-8, -6, -4, -2, 0, 2, 4, 6, 8, 10, 12, 14, 16, 14, 12, 10};

    int16_t low_0[8]; int16_t high_0[8];
    int16_t low_1[8]; int16_t high_1[8];
    int16_t low_2[8]; int16_t high_2[8];

    int8_t output_0[16];
    int8_t output_1[16];
    int8_t output_2[16];

    /*int16_t low_4[8]; int16_t high_4[8];
    int16_t low_5[8]; int16_t high_5[8];
    int16_t low_6[8]; int16_t high_6[8];

    int8_t output_4[16];
    int8_t output_5[16];
    int8_t output_6[16];*/

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

    //*** DB8 */
    /*//SW
    gccs(0x40);
    SW_dwt_db8_int16(input, low_4, high_4);
    gccs(0x44);

    gccs(0x48);
    SW_idwt_db8_int16(low_4, high_4, output_4);
    gccs(0x4C);

    //HW friendly implementation
    gccs(0x50);
    HW_dwt_db8_int16_core(input, low_5, high_5);
    gccs(0x54);

    gccs(0x58);
    HW_idwt_db8_int16_core(low_5, high_5, output_5);
    gccs(0x5C);

    //HW real
    gccs(0x60);
    Compute_FDWT_DB_8(input, low_6, high_6);
    gccs(0x64);

    gccs(0x68);
    Compute_IDWT_DB_8(low_6, high_6, output_6);
    gccs(0x6C);*/

    for(int i=0;i<20;++i);

    return 0;
}