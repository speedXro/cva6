#include <stdio.h>
#include <stdint.h>

#include "dwt_idwt_cdf_5_3.h"
#include "structs.h"

int main(void)
{
    I8U8 ins[16];
    uint64_t op1=0, op2=0;
    uint64_t low_03,low_47,high_03,high_47;
    I16U16 lows[8];
    I16U16 highs[8];
    uint64_t out_0=0, out_1=0;
    I8U8 invs[16];

    int8_t input[16]    = {14,14,18,19,11,12,18,7,14,14,18,19,11,12,18,7};
    int16_t direct_h[8] = {0};
    int16_t direct_l[8] = {0};
    int8_t inverse[16]  = {0};

    int16_t dir_h[8] = {0};
    int16_t dir_l[8] = {0};
    int8_t inv[16]={0};


    printf("Input    : "); for(int i=0;i<16;++i) {printf("%03d ", input[i]);} printf("\n\n");

    //CDF 5/3
    
    ins[ 0].ival8 = input[ 0];
    ins[ 1].ival8 = input[ 1];
    ins[ 2].ival8 = input[ 2];
    ins[ 3].ival8 = input[ 3];
    ins[ 4].ival8 = input[ 4];
    ins[ 5].ival8 = input[ 5];
    ins[ 6].ival8 = input[ 6];
    ins[ 7].ival8 = input[ 7];
    ins[ 8].ival8 = input[ 8];
    ins[ 9].ival8 = input[ 9];
    ins[10].ival8 = input[10];
    ins[11].ival8 = input[11];
    ins[12].ival8 = input[12];
    ins[13].ival8 = input[13];
    ins[14].ival8 = input[14];
    ins[15].ival8 = input[15];

    op1  = 0u;
    op1 |= ((uint64_t)(ins[ 0].uval8)) << (7 * 8);
    op1 |= ((uint64_t)(ins[ 1].uval8)) << (6 * 8);
    op1 |= ((uint64_t)(ins[ 2].uval8)) << (5 * 8);
    op1 |= ((uint64_t)(ins[ 3].uval8)) << (4 * 8);
    op1 |= ((uint64_t)(ins[ 4].uval8)) << (3 * 8);
    op1 |= ((uint64_t)(ins[ 5].uval8)) << (2 * 8);
    op1 |= ((uint64_t)(ins[ 6].uval8)) << (1 * 8);
    op1 |= ((uint64_t)(ins[ 7].uval8)) << (0 * 8);

    op2  = 0u;
    op2 |= ((uint64_t)(ins[ 0].uval8)) << (7 * 8);
    op2 |= ((uint64_t)(ins[ 1].uval8)) << (6 * 8);
    op2 |= ((uint64_t)(ins[ 2].uval8)) << (5 * 8);
    op2 |= ((uint64_t)(ins[ 3].uval8)) << (4 * 8);
    op2 |= ((uint64_t)(ins[ 4].uval8)) << (3 * 8);
    op2 |= ((uint64_t)(ins[ 5].uval8)) << (2 * 8);
    op2 |= ((uint64_t)(ins[ 6].uval8)) << (1 * 8);
    op2 |= ((uint64_t)(ins[ 7].uval8)) << (0 * 8);

    HW_dwt53_forward(op1, op2, &low_03, &low_47, &high_03, &high_47);

    lows[0].uval16 = (uint16_t)(low_03 >> (3 * 16));
    lows[1].uval16 = (uint16_t)(low_03 >> (2 * 16));
    lows[2].uval16 = (uint16_t)(low_03 >> (1 * 16));
    lows[3].uval16 = (uint16_t)(low_03 >> (0 * 16));
    lows[4].uval16 = (uint16_t)(low_47 >> (3 * 16));
    lows[5].uval16 = (uint16_t)(low_47 >> (2 * 16));
    lows[6].uval16 = (uint16_t)(low_47 >> (1 * 16));
    lows[7].uval16 = (uint16_t)(low_47 >> (0 * 16));

    highs[0].uval16 = (uint16_t)(high_03 >> (3 * 16));
    highs[1].uval16 = (uint16_t)(high_03 >> (2 * 16));
    highs[2].uval16 = (uint16_t)(high_03 >> (1 * 16));
    highs[3].uval16 = (uint16_t)(high_03 >> (0 * 16));
    highs[4].uval16 = (uint16_t)(high_47 >> (3 * 16));
    highs[5].uval16 = (uint16_t)(high_47 >> (2 * 16));
    highs[6].uval16 = (uint16_t)(high_47 >> (1 * 16));
    highs[7].uval16 = (uint16_t)(high_47 >> (0 * 16));

    dir_l[0] = lows[0].ival16;
    dir_l[1] = lows[1].ival16;
    dir_l[2] = lows[2].ival16;
    dir_l[3] = lows[3].ival16;
    dir_l[4] = lows[4].ival16;
    dir_l[5] = lows[5].ival16;
    dir_l[6] = lows[6].ival16;
    dir_l[7] = lows[7].ival16;

    dir_h[0] = highs[0].ival16;
    dir_h[1] = highs[1].ival16;
    dir_h[2] = highs[2].ival16;
    dir_h[3] = highs[3].ival16;
    dir_h[4] = highs[4].ival16;
    dir_h[5] = highs[5].ival16;
    dir_h[6] = highs[6].ival16;
    dir_h[7] = highs[7].ival16;

    printf("CDF 5/3\n");
    printf("Direct_L : "); for(int i=0;i< 8;++i) {printf("%03d ", dir_l[i]);} printf("\n");
    printf("Direct_H : "); for(int i=0;i< 8;++i) {printf("%03d ", dir_h[i]);} printf("\n");

    HW_dwt53_inverse(low_03, low_47, high_03, high_47, &out_0, &out_1);

    invs[ 0].uval8 = (uint8_t)(out_0 >> (7 * 8));
    invs[ 1].uval8 = (uint8_t)(out_0 >> (6 * 8));
    invs[ 2].uval8 = (uint8_t)(out_0 >> (5 * 8));
    invs[ 3].uval8 = (uint8_t)(out_0 >> (4 * 8));
    invs[ 4].uval8 = (uint8_t)(out_0 >> (3 * 8));
    invs[ 5].uval8 = (uint8_t)(out_0 >> (2 * 8));
    invs[ 6].uval8 = (uint8_t)(out_0 >> (1 * 8));
    invs[ 7].uval8 = (uint8_t)(out_0 >> (0 * 8));

    invs[ 8].uval8 = (uint8_t)(out_1 >> (7 * 8));
    invs[ 9].uval8 = (uint8_t)(out_1 >> (6 * 8));
    invs[10].uval8 = (uint8_t)(out_1 >> (5 * 8));
    invs[11].uval8 = (uint8_t)(out_1 >> (4 * 8));
    invs[12].uval8 = (uint8_t)(out_1 >> (3 * 8));
    invs[13].uval8 = (uint8_t)(out_1 >> (2 * 8));
    invs[14].uval8 = (uint8_t)(out_1 >> (1 * 8));
    invs[15].uval8 = (uint8_t)(out_1 >> (0 * 8));

    inv[ 0] = invs[ 0].ival8;
    inv[ 1] = invs[ 1].ival8;
    inv[ 2] = invs[ 2].ival8;
    inv[ 3] = invs[ 3].ival8;
    inv[ 4] = invs[ 4].ival8;
    inv[ 5] = invs[ 5].ival8;
    inv[ 6] = invs[ 6].ival8;
    inv[ 7] = invs[ 7].ival8;
    inv[ 8] = invs[ 8].ival8;
    inv[ 9] = invs[ 9].ival8;
    inv[10] = invs[10].ival8;
    inv[11] = invs[11].ival8;
    inv[12] = invs[12].ival8;
    inv[13] = invs[13].ival8;
    inv[14] = invs[14].ival8;
    inv[15] = invs[15].ival8;

    printf("Inverse  : "); for(int i=0;i<16;++i) {printf("%03d ", inv[i]);} printf("\n\n");

    return 0;
}

