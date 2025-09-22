#include "cdf53.h"
#include <stdint.h>

#define N      16     // block size
#define Q15 32768

static inline int8_t clamp_i8(int32_t x){
    if (x > 127)  return 127;
    if (x < -128) return -128;
    return (int8_t)x;
}

static inline int8_t clamp_int8(int32_t x) 
{
    if (x > 127)  return 127;
    if (x < -128) return -128;
    return (int8_t)x;
}


void SW_dwt53_forward(int8_t in[16], int16_t low[8], int16_t high[8]) {
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

    for (int i = 0; i < HALF; i++) 
    {
        low[i]  = (int16_t)s[i];
        high[i] = (int16_t)d[i];
    }
}

void SW_dwt53_inverse(int16_t low[8], int16_t high[8], int8_t out[16]) {
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
