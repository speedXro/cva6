#include <stdint.h>
#include "dwt_idwt_cdf_5_3.h"
#include "structs.h"

#define N 16
#define HALF (N/2)

static inline int8_t clamp_i8(int32_t x){
    if (x > 127)  return 127;
    if (x < -128) return -128;
    return (int8_t)x;
}

void SW_dwt53_forward(int8_t in[16], int16_t low[8], int16_t high[8]) 
{
    int32_t s[HALF], d[HALF];

    for (int i = 0; i < HALF; i++) 
    {
        s[i] = (int32_t)in[2*i];
        d[i] = (int32_t)in[2*i + 1];
    }

    for (int i = 0; i < HALF; i++) 
    {
        int next = (i + 1) % HALF;                 
        d[i] -= (s[i] + s[next]) >> 1;             
    }

    for (int i = 0; i < HALF; i++) 
    {
        int prev = (i - 1 + HALF) % HALF;          
        s[i] += (d[prev] + d[i] + 2) >> 2;         
    }

    for (int i = 0; i < HALF; i++) {
        low[i]  = (int16_t)s[i];
        high[i] = (int16_t)d[i];
    }
}

void HW_dwt53_forward_core(int8_t in[16], int16_t low[8], int16_t high[8])
{
    int32_t s[8];
    int32_t d[8];

    s[0] = (int32_t)in[ 0];
    s[1] = (int32_t)in[ 2];
    s[2] = (int32_t)in[ 4];
    s[3] = (int32_t)in[ 6];
    s[4] = (int32_t)in[ 8];
    s[5] = (int32_t)in[10];
    s[6] = (int32_t)in[12];
    s[7] = (int32_t)in[14];

    d[0] = (int32_t)in[1];
    d[1] = (int32_t)in[3];
    d[2] = (int32_t)in[5];
    d[3] = (int32_t)in[7];
    d[4] = (int32_t)in[9];
    d[5] = (int32_t)in[11];
    d[6] = (int32_t)in[13];
    d[7] = (int32_t)in[15];

    d[0] -= (s[0] + s[1]) >> 1;
    d[1] -= (s[1] + s[2]) >> 1;
    d[2] -= (s[2] + s[3]) >> 1;
    d[3] -= (s[3] + s[4]) >> 1;
    d[4] -= (s[4] + s[5]) >> 1;
    d[5] -= (s[5] + s[6]) >> 1;
    d[6] -= (s[6] + s[7]) >> 1;
    d[7] -= (s[7] + s[0]) >> 1;

    s[0] += (d[0] + d[7] + 2) >> 2;
    s[1] += (d[1] + d[0] + 2) >> 2;
    s[2] += (d[2] + d[1] + 2) >> 2;
    s[3] += (d[3] + d[2] + 2) >> 2;
    s[4] += (d[4] + d[3] + 2) >> 2;
    s[5] += (d[5] + d[4] + 2) >> 2;
    s[6] += (d[6] + d[5] + 2) >> 2;
    s[7] += (d[7] + d[6] + 2) >> 2;

    low[0] = (int16_t)s[0];
    low[1] = (int16_t)s[1];
    low[2] = (int16_t)s[2];
    low[3] = (int16_t)s[3];
    low[4] = (int16_t)s[4];
    low[5] = (int16_t)s[5];
    low[6] = (int16_t)s[6];
    low[7] = (int16_t)s[7];

    high[0] = (int16_t)d[0];
    high[1] = (int16_t)d[1];
    high[2] = (int16_t)d[2];
    high[3] = (int16_t)d[3];
    high[4] = (int16_t)d[4];
    high[5] = (int16_t)d[5];
    high[6] = (int16_t)d[6];
    high[7] = (int16_t)d[7];
}


void HW_dwt53_forward(uint64_t op1, uint64_t op2, uint64_t* p_low_03, uint64_t* p_low_47, uint64_t* p_high_03, uint64_t* p_high_47)
{
    #pragma HLS latency min=1
    int8_t inputs[16];

    int16_t low[8]; 
    int16_t high[8];

    inputs[ 0] = (int8_t)(op1 >> (7 * 8));
    inputs[ 1] = (int8_t)(op1 >> (6 * 8));
    inputs[ 2] = (int8_t)(op1 >> (5 * 8));
    inputs[ 3] = (int8_t)(op1 >> (4 * 8));
    inputs[ 4] = (int8_t)(op1 >> (3 * 8));
    inputs[ 5] = (int8_t)(op1 >> (2 * 8));
    inputs[ 6] = (int8_t)(op1 >> (1 * 8));
    inputs[ 7] = (int8_t)(op1 >> (0 * 8));

    inputs[ 8] = (uint8_t)(op2 >> (7 * 8));
    inputs[ 9] = (uint8_t)(op2 >> (6 * 8));
    inputs[10] = (uint8_t)(op2 >> (5 * 8));
    inputs[11] = (uint8_t)(op2 >> (4 * 8));
    inputs[12] = (uint8_t)(op2 >> (3 * 8));
    inputs[13] = (uint8_t)(op2 >> (2 * 8));
    inputs[14] = (uint8_t)(op2 >> (1 * 8));
    inputs[15] = (uint8_t)(op2 >> (0 * 8));

    HW_dwt53_forward_core(inputs, low, high);

    *p_low_03 = 0;

    *p_low_03 |= ((uint64_t)((uint16_t)low[0])) << (3 * 16);
    *p_low_03 |= ((uint64_t)((uint16_t)low[1])) << (2 * 16);
    *p_low_03 |= ((uint64_t)((uint16_t)low[2])) << (1 * 16);
    *p_low_03 |= ((uint64_t)((uint16_t)low[3])) << (0 * 16);

    *p_low_47 = 0;

    *p_low_47 |= ((uint64_t)((uint16_t)low[4])) << (3 * 16);
    *p_low_47 |= ((uint64_t)((uint16_t)low[5])) << (2 * 16);
    *p_low_47 |= ((uint64_t)((uint16_t)low[6])) << (1 * 16);
    *p_low_47 |= ((uint64_t)((uint16_t)low[7])) << (0 * 16);

    *p_high_03 = 0;

    *p_high_03 |= ((uint64_t)((uint16_t)high[0])) << (3 * 16);
    *p_high_03 |= ((uint64_t)((uint16_t)high[1])) << (2 * 16);
    *p_high_03 |= ((uint64_t)((uint16_t)high[2])) << (1 * 16);
    *p_high_03 |= ((uint64_t)((uint16_t)high[3])) << (0 * 16);

    *p_high_47 = 0;

    *p_high_47 |= ((uint64_t)((uint16_t)high[4])) << (3 * 16);
    *p_high_47 |= ((uint64_t)((uint16_t)high[5])) << (2 * 16);
    *p_high_47 |= ((uint64_t)((uint16_t)high[6])) << (1 * 16);
    *p_high_47 |= ((uint64_t)((uint16_t)high[7])) << (0 * 16);

}

void SW_dwt53_inverse(int16_t low[8], int16_t high[8], int8_t out[16]) 
{
    int32_t s[HALF], d[HALF];

    for (int i = 0; i < HALF; i++) 
    {
        s[i] = (int32_t)low[i];
        d[i] = (int32_t)high[i];
    }

    for (int i = 0; i < HALF; i++) 
    {
        int prev = (i - 1 + HALF) % HALF;
        s[i] -= (d[prev] + d[i] + 2) >> 2;
    }

    for (int i = 0; i < HALF; i++) 
    {
        int next = (i + 1) % HALF;
        int32_t odd = d[i] + ((s[i] + s[next]) >> 1);

        out[2*i]     = clamp_i8(s[i]);
        out[2*i + 1] = clamp_i8(odd);
    }
}

void HW_dwt53_inverse_core(int16_t low[8], int16_t high[8], int8_t out[16])
{
    int32_t s[8];
    int32_t d[8];

    s[0] = (int32_t)low[0];
    s[1] = (int32_t)low[1];
    s[2] = (int32_t)low[2];
    s[3] = (int32_t)low[3];
    s[4] = (int32_t)low[4];
    s[5] = (int32_t)low[5];
    s[6] = (int32_t)low[6];
    s[7] = (int32_t)low[7];

    d[0] = (int32_t)high[0];
    d[1] = (int32_t)high[1];
    d[2] = (int32_t)high[2];
    d[3] = (int32_t)high[3];
    d[4] = (int32_t)high[4];
    d[5] = (int32_t)high[5];
    d[6] = (int32_t)high[6];
    d[7] = (int32_t)high[7];

    s[0] -= (d[0] + d[7] + 2) >> 2;
    s[1] -= (d[1] + d[0] + 2) >> 2;
    s[2] -= (d[2] + d[1] + 2) >> 2;
    s[3] -= (d[3] + d[2] + 2) >> 2;
    s[4] -= (d[4] + d[3] + 2) >> 2;
    s[5] -= (d[5] + d[4] + 2) >> 2;
    s[6] -= (d[6] + d[5] + 2) >> 2;
    s[7] -= (d[7] + d[6] + 2) >> 2;

    out[ 0] = clamp_i8(s[0]);
    out[ 2] = clamp_i8(s[1]);
    out[ 4] = clamp_i8(s[2]);
    out[ 6] = clamp_i8(s[3]);
    out[ 8] = clamp_i8(s[4]);
    out[10] = clamp_i8(s[5]);
    out[12] = clamp_i8(s[6]);
    out[14] = clamp_i8(s[7]);

    out[ 1] = clamp_i8(d[0] + ((s[0] + s[1]) >> 1));
    out[ 3] = clamp_i8(d[1] + ((s[1] + s[2]) >> 1));
    out[ 5] = clamp_i8(d[2] + ((s[2] + s[3]) >> 1));
    out[ 7] = clamp_i8(d[3] + ((s[3] + s[4]) >> 1));
    out[ 9] = clamp_i8(d[4] + ((s[4] + s[5]) >> 1));
    out[11] = clamp_i8(d[5] + ((s[5] + s[6]) >> 1));
    out[13] = clamp_i8(d[6] + ((s[6] + s[7]) >> 1));
    out[15] = clamp_i8(d[7] + ((s[7] + s[0]) >> 1));
}

void HW_dwt53_inverse(uint64_t low_03, uint64_t low_47, uint64_t high_03, uint64_t high_47, uint64_t* p_out_0, uint64_t* p_out_1)
{
    #pragma HLS latency min=1

    int16_t in_low[8];
    int16_t in_high[8];

    int8_t out[16];

    in_low[0]  = (int16_t)(low_03  >> (3 * 16));
    in_low[1]  = (int16_t)(low_03  >> (2 * 16));
    in_low[2]  = (int16_t)(low_03  >> (1 * 16));
    in_low[3]  = (int16_t)(low_03  >> (0 * 16));
    in_low[4]  = (int16_t)(low_47  >> (3 * 16));
    in_low[5]  = (int16_t)(low_47  >> (2 * 16));
    in_low[6]  = (int16_t)(low_47  >> (1 * 16));
    in_low[7]  = (int16_t)(low_47  >> (0 * 16)); 

    in_high[0] = (int16_t)(high_03 >> (3 * 16));
    in_high[1] = (int16_t)(high_03 >> (2 * 16));
    in_high[2] = (int16_t)(high_03 >> (1 * 16));
    in_high[3] = (int16_t)(high_03 >> (0 * 16));
    in_high[4] = (int16_t)(high_47 >> (3 * 16));
    in_high[5] = (int16_t)(high_47 >> (2 * 16));
    in_high[6] = (int16_t)(high_47 >> (1 * 16));
    in_high[7] = (int16_t)(high_47 >> (0 * 16)); 

    HW_dwt53_inverse_core(in_low, in_high, out);

    *p_out_0 = 0;
    *p_out_0 |= ((uint64_t)((uint8_t)(out[ 0]))) << (7 * 8);
    *p_out_0 |= ((uint64_t)((uint8_t)(out[ 1]))) << (6 * 8);
    *p_out_0 |= ((uint64_t)((uint8_t)(out[ 2]))) << (5 * 8);
    *p_out_0 |= ((uint64_t)((uint8_t)(out[ 3]))) << (4 * 8);
    *p_out_0 |= ((uint64_t)((uint8_t)(out[ 4]))) << (3 * 8);
    *p_out_0 |= ((uint64_t)((uint8_t)(out[ 5]))) << (2 * 8);
    *p_out_0 |= ((uint64_t)((uint8_t)(out[ 6]))) << (1 * 8);
    *p_out_0 |= ((uint64_t)((uint8_t)(out[ 7]))) << (0 * 8);

    *p_out_1 = 0;
    *p_out_1 |= ((uint64_t)((uint8_t)(out[ 8]))) << (7 * 8);
    *p_out_1 |= ((uint64_t)((uint8_t)(out[ 9]))) << (6 * 8);
    *p_out_1 |= ((uint64_t)((uint8_t)(out[10]))) << (5 * 8);
    *p_out_1 |= ((uint64_t)((uint8_t)(out[11]))) << (4 * 8);
    *p_out_1 |= ((uint64_t)((uint8_t)(out[12]))) << (3 * 8);
    *p_out_1 |= ((uint64_t)((uint8_t)(out[13]))) << (2 * 8);
    *p_out_1 |= ((uint64_t)((uint8_t)(out[14]))) << (1 * 8);
    *p_out_1 |= ((uint64_t)((uint8_t)(out[15]))) << (0 * 8);
}
