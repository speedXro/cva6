#include "dwt.h"
#include <stdint.h>

#define N      16     // block size
#define Q15 32768

// db8 low-pass filter (Q15 scaled)
static const int16_t h[16] = {
    1784, 10239, 22193, 19166,
    -518, -9305,  15, 4216,
    -569, -1443,  458,  287,
    -160,  -13,  22,  -4
};

// db8 high-pass filter derived from h (Q15 scaled)
static const int16_t g[16] = {
    -4, -22, -13, 160,
     287, -458, -1443,  569,
     4216, -15, -9305,  518,
     19166, -22193, 10239, -1784
};

// Reconstruction filters = reversed analysis filters (orthonormal case)
static const int16_t hr[16] = {
    -4,  22, -13, -160,
     287,  458, -1443, -569,
    4216,   15, -9305, -518,
   19166, 22193, 10239, 1784
};

static const int16_t gr[16] = {
   -1784, 10239, -22193, 19166,
     518, -9305,  -15, 4216,
     -569, 1443, -458, 287,
     -160, 13,  -22,  -4
};

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


// ------------ CDF 5/3 FORWARD (reversible integer lifting) ------------
// Input:  in[16]  (int8_t)
// Output: low[8], high[8] (int16_t)  -- use int16 to avoid overflow and keep lossless
void SW_dwt53_forward(int8_t in[16], int16_t low[8], int16_t high[8]) {
    int32_t s[HALF], d[HALF];

    // Split into even (s) and odd (d)
    for (int i = 0; i < HALF; i++) {
        s[i] = (int32_t)in[2*i];
        d[i] = (int32_t)in[2*i + 1];
    }

    // Predict step: d[i] -= floor((s[i] + s[i+1]) / 2)
    for (int i = 0; i < HALF; i++) {
        int next = (i + 1) % HALF;                 // periodic
        d[i] -= (s[i] + s[next]) >> 1;             // floor division by 2
    }

    // Update step: s[i] += floor((d[i-1] + d[i] + 2) / 4)
    for (int i = 0; i < HALF; i++) {
        int prev = (i - 1 + HALF) % HALF;          // periodic
        s[i] += (d[prev] + d[i] + 2) >> 2;         // +2 for rounding toward floor(&/4)
    }

    // Store as int16
    for (int i = 0; i < HALF; i++) {
        low[i]  = (int16_t)s[i];
        high[i] = (int16_t)d[i];
    }
}

void SW_dwt53_inverse(int16_t low[8], int16_t high[8], int8_t out[16]) {
    int32_t s[HALF], d[HALF];

    // Load to 32-bit work arrays
    for (int i = 0; i < HALF; i++) {
        s[i] = (int32_t)low[i];
        d[i] = (int32_t)high[i];
    }

    // Undo update: s[i] -= floor((d[i-1] + d[i] + 2) / 4)
    for (int i = 0; i < HALF; i++) {
        int prev = (i - 1 + HALF) % HALF;
        s[i] -= (d[prev] + d[i] + 2) >> 2;
    }

    // Undo predict and interleave back to samples
    for (int i = 0; i < HALF; i++) {
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

void SW_dwt_db8_int16(int8_t input[16], int16_t low[8], int16_t high[8]) 
{
    for (int i = 0; i < N/2; i++) 
    {
        int32_t sumL = 0;
        int32_t sumH = 0;
        for (int k = 0; k < 16; k++) 
        {
            int idx = (2*i + k) % N; // circular extension
            sumL += (int32_t)input[idx] * h[k];
            sumH += (int32_t)input[idx] * g[k];
        }
        // Shift back from Q15
        low[i]  = (int16_t)(sumL >> 15);
        high[i] = (int16_t)(sumH >> 15);
    }
}

void HW_dwt_db8_int16_core(int8_t input[16], int16_t low[8], int16_t high[8])
{
    int32_t sumL[8]={0};
    int32_t sumH[8]={0};

    sumL[0]+= (input[ 0]*h[ 0]) + (input[ 1]*h[ 1]);
    sumH[0]+= (input[ 0]*g[ 0]) + (input[ 1]*g[ 1]);
    sumL[1]+= (input[ 2]*h[ 0]) + (input[ 3]*h[ 1]);
    sumH[1]+= (input[ 2]*g[ 0]) + (input[ 3]*g[ 1]);
    sumL[2]+= (input[ 4]*h[ 0]) + (input[ 5]*h[ 1]);
    sumH[2]+= (input[ 4]*g[ 0]) + (input[ 5]*g[ 1]);
    sumL[3]+= (input[ 6]*h[ 0]) + (input[ 7]*h[ 1]);
    sumH[3]+= (input[ 6]*g[ 0]) + (input[ 7]*g[ 1]);
    sumL[4]+= (input[ 8]*h[ 0]) + (input[ 9]*h[ 1]);
    sumH[4]+= (input[ 8]*g[ 0]) + (input[ 9]*g[ 1]);
    sumL[5]+= (input[10]*h[ 0]) + (input[11]*h[ 1]);
    sumH[5]+= (input[10]*g[ 0]) + (input[11]*g[ 1]);
    sumL[6]+= (input[12]*h[ 0]) + (input[13]*h[ 1]);
    sumH[6]+= (input[12]*g[ 0]) + (input[13]*g[ 1]);
    sumL[7]+= (input[14]*h[ 0]) + (input[15]*h[ 1]);
    sumH[7]+= (input[14]*g[ 0]) + (input[15]*g[ 1]);


    sumL[0]+= (input[ 2]*h[ 2]) + (input[ 3]*h[ 3]);
    sumH[0]+= (input[ 2]*g[ 2]) + (input[ 3]*g[ 3]);
    sumL[1]+= (input[ 4]*h[ 2]) + (input[ 5]*h[ 3]);
    sumH[1]+= (input[ 4]*g[ 2]) + (input[ 5]*g[ 3]);
    sumL[2]+= (input[ 6]*h[ 2]) + (input[ 7]*h[ 3]);
    sumH[2]+= (input[ 6]*g[ 2]) + (input[ 7]*g[ 3]);
    sumL[3]+= (input[ 8]*h[ 2]) + (input[ 9]*h[ 3]);
    sumH[3]+= (input[ 8]*g[ 2]) + (input[ 9]*g[ 3]);
    sumL[4]+= (input[10]*h[ 2]) + (input[11]*h[ 3]);
    sumH[4]+= (input[10]*g[ 2]) + (input[11]*g[ 3]);
    sumL[5]+= (input[12]*h[ 2]) + (input[13]*h[ 3]);
    sumH[5]+= (input[12]*g[ 2]) + (input[13]*g[ 3]);
    sumL[6]+= (input[14]*h[ 2]) + (input[15]*h[ 3]);
    sumH[6]+= (input[14]*g[ 2]) + (input[15]*g[ 3]);
    sumL[7]+= (input[ 0]*h[ 2]) + (input[ 1]*h[ 3]);
    sumH[7]+= (input[ 0]*g[ 2]) + (input[ 1]*g[ 3]);




    sumL[0]+= (input[ 4]*h[ 4]) + (input[ 5]*h[ 5]);
    sumH[0]+= (input[ 4]*g[ 4]) + (input[ 5]*g[ 5]);
    sumL[1]+= (input[ 6]*h[ 4]) + (input[ 7]*h[ 5]);
    sumH[1]+= (input[ 6]*g[ 4]) + (input[ 7]*g[ 5]);
    sumL[2]+= (input[ 8]*h[ 4]) + (input[ 9]*h[ 5]);
    sumH[2]+= (input[ 8]*g[ 4]) + (input[ 9]*g[ 5]);
    sumL[3]+= (input[10]*h[ 4]) + (input[11]*h[ 5]);
    sumH[3]+= (input[10]*g[ 4]) + (input[11]*g[ 5]);
    sumL[4]+= (input[12]*h[ 4]) + (input[13]*h[ 5]);
    sumH[4]+= (input[12]*g[ 4]) + (input[13]*g[ 5]);
    sumL[5]+= (input[14]*h[ 4]) + (input[15]*h[ 5]);
    sumH[5]+= (input[14]*g[ 4]) + (input[15]*g[ 5]);
    sumL[6]+= (input[ 0]*h[ 4]) + (input[ 1]*h[ 5]);
    sumH[6]+= (input[ 0]*g[ 4]) + (input[ 1]*g[ 5]);
    sumL[7]+= (input[ 2]*h[ 4]) + (input[ 3]*h[ 5]);
    sumH[7]+= (input[ 2]*g[ 4]) + (input[ 3]*g[ 5]);


    sumL[0]+= (input[ 6]*h[ 6]) + (input[ 7]*h[ 7]);
    sumH[0]+= (input[ 6]*g[ 6]) + (input[ 7]*g[ 7]);
    sumL[1]+= (input[ 8]*h[ 6]) + (input[ 9]*h[ 7]);
    sumH[1]+= (input[ 8]*g[ 6]) + (input[ 9]*g[ 7]);
    sumL[2]+= (input[10]*h[ 6]) + (input[11]*h[ 7]);
    sumH[2]+= (input[10]*g[ 6]) + (input[11]*g[ 7]);
    sumL[3]+= (input[12]*h[ 6]) + (input[13]*h[ 7]);
    sumH[3]+= (input[12]*g[ 6]) + (input[13]*g[ 7]);
    sumL[4]+= (input[14]*h[ 6]) + (input[15]*h[ 7]);
    sumH[4]+= (input[14]*g[ 6]) + (input[15]*g[ 7]);
    sumL[5]+= (input[ 0]*h[ 6]) + (input[ 1]*h[ 7]);
    sumH[5]+= (input[ 0]*g[ 6]) + (input[ 1]*g[ 7]);
    sumL[6]+= (input[ 2]*h[ 6]) + (input[ 3]*h[ 7]);
    sumH[6]+= (input[ 2]*g[ 6]) + (input[ 3]*g[ 7]);
    sumL[7]+= (input[ 4]*h[ 6]) + (input[ 5]*h[ 7]);
    sumH[7]+= (input[ 4]*g[ 6]) + (input[ 5]*g[ 7]);


    sumL[0]+= (input[ 8]*h[ 8]) + (input[ 9]*h[ 9]);
    sumH[0]+= (input[ 8]*g[ 8]) + (input[ 9]*g[ 9]);
    sumL[1]+= (input[10]*h[ 8]) + (input[11]*h[ 9]);
    sumH[1]+= (input[10]*g[ 8]) + (input[11]*g[ 9]);
    sumL[2]+= (input[12]*h[ 8]) + (input[13]*h[ 9]);
    sumH[2]+= (input[12]*g[ 8]) + (input[13]*g[ 9]);
    sumL[3]+= (input[14]*h[ 8]) + (input[15]*h[ 9]);
    sumH[3]+= (input[14]*g[ 8]) + (input[15]*g[ 9]);
    sumL[4]+= (input[ 0]*h[ 8]) + (input[ 1]*h[ 9]);
    sumH[4]+= (input[ 0]*g[ 8]) + (input[ 1]*g[ 9]);
    sumL[5]+= (input[ 2]*h[ 8]) + (input[ 3]*h[ 9]);
    sumH[5]+= (input[ 2]*g[ 8]) + (input[ 3]*g[ 9]);
    sumL[6]+= (input[ 4]*h[ 8]) + (input[ 5]*h[ 9]);
    sumH[6]+= (input[ 4]*g[ 8]) + (input[ 5]*g[ 9]);
    sumL[7]+= (input[ 6]*h[ 8]) + (input[ 7]*h[ 9]);
    sumH[7]+= (input[ 6]*g[ 8]) + (input[ 7]*g[ 9]);



    sumL[0]+= (input[10]*h[10]) + (input[11]*h[11]);
    sumH[0]+= (input[10]*g[10]) + (input[11]*g[11]);
    sumL[1]+= (input[12]*h[10]) + (input[13]*h[11]);
    sumH[1]+= (input[12]*g[10]) + (input[13]*g[11]);
    sumL[2]+= (input[14]*h[10]) + (input[15]*h[11]);
    sumH[2]+= (input[14]*g[10]) + (input[15]*g[11]);
    sumL[3]+= (input[ 0]*h[10]) + (input[ 1]*h[11]);
    sumH[3]+= (input[ 0]*g[10]) + (input[ 1]*g[11]);
    sumL[4]+= (input[ 2]*h[10]) + (input[ 3]*h[11]);
    sumH[4]+= (input[ 2]*g[10]) + (input[ 3]*g[11]);
    sumL[5]+= (input[ 4]*h[10]) + (input[ 5]*h[11]);
    sumH[5]+= (input[ 4]*g[10]) + (input[ 5]*g[11]);
    sumL[6]+= (input[ 6]*h[10]) + (input[ 7]*h[11]);
    sumH[6]+= (input[ 6]*g[10]) + (input[ 7]*g[11]);
    sumL[7]+= (input[ 8]*h[10]) + (input[ 9]*h[11]);
    sumH[7]+= (input[ 8]*g[10]) + (input[ 9]*g[11]);


    sumL[0]+= (input[12]*h[12]) + (input[13]*h[13]);
    sumH[0]+= (input[12]*g[12]) + (input[13]*g[13]);
    sumL[1]+= (input[14]*h[12]) + (input[15]*h[13]);
    sumH[1]+= (input[14]*g[12]) + (input[15]*g[13]);
    sumL[2]+= (input[ 0]*h[12]) + (input[ 1]*h[13]);
    sumH[2]+= (input[ 0]*g[12]) + (input[ 1]*g[13]);
    sumL[3]+= (input[ 2]*h[12]) + (input[ 3]*h[13]);
    sumH[3]+= (input[ 2]*g[12]) + (input[ 3]*g[13]);
    sumL[4]+= (input[ 4]*h[12]) + (input[ 5]*h[13]);
    sumH[4]+= (input[ 4]*g[12]) + (input[ 5]*g[13]);
    sumL[5]+= (input[ 6]*h[12]) + (input[ 7]*h[13]);
    sumH[5]+= (input[ 6]*g[12]) + (input[ 7]*g[13]);
    sumL[6]+= (input[ 8]*h[12]) + (input[ 9]*h[13]);
    sumH[6]+= (input[ 8]*g[12]) + (input[ 9]*g[13]);
    sumL[7]+= (input[10]*h[12]) + (input[11]*h[13]);
    sumH[7]+= (input[10]*g[12]) + (input[11]*g[13]);


    sumL[0]+= (input[14]*h[14]) + (input[15]*h[15]);
    sumH[0]+= (input[14]*g[14]) + (input[15]*g[15]);
    sumL[1]+= (input[ 0]*h[14]) + (input[ 1]*h[15]);
    sumH[1]+= (input[ 0]*g[14]) + (input[ 1]*g[15]);
    sumL[2]+= (input[ 2]*h[14]) + (input[ 3]*h[15]);
    sumH[2]+= (input[ 2]*g[14]) + (input[ 3]*g[15]);
    sumL[3]+= (input[ 4]*h[14]) + (input[ 5]*h[15]);    
    sumH[3]+= (input[ 4]*g[14]) + (input[ 5]*g[15]);
    sumL[4]+= (input[ 6]*h[14]) + (input[ 7]*h[15]);
    sumH[4]+= (input[ 6]*g[14]) + (input[ 7]*g[15]);
    sumL[5]+= (input[ 8]*h[14]) + (input[ 9]*h[15]);
    sumH[5]+= (input[ 8]*g[14]) + (input[ 9]*g[15]);
    sumL[6]+= (input[10]*h[14]) + (input[11]*h[15]);
    sumH[6]+= (input[10]*g[14]) + (input[11]*g[15]);
    sumL[7]+= (input[12]*h[14]) + (input[13]*h[15]);
    sumH[7]+= (input[12]*g[14]) + (input[13]*g[15]);

    low[0] = (int16_t)(sumL[0] >> 15);
    low[1] = (int16_t)(sumL[1] >> 15);
    low[2] = (int16_t)(sumL[2] >> 15);
    low[3] = (int16_t)(sumL[3] >> 15);
    low[4] = (int16_t)(sumL[4] >> 15);
    low[5] = (int16_t)(sumL[5] >> 15);
    low[6] = (int16_t)(sumL[6] >> 15);
    low[7] = (int16_t)(sumL[7] >> 15);

    high[0] = (int16_t)(sumH[0] >> 15);
    high[1] = (int16_t)(sumH[1] >> 15);
    high[2] = (int16_t)(sumH[2] >> 15);
    high[3] = (int16_t)(sumH[3] >> 15);
    high[4] = (int16_t)(sumH[4] >> 15);
    high[5] = (int16_t)(sumH[5] >> 15);
    high[6] = (int16_t)(sumH[6] >> 15);
    high[7] = (int16_t)(sumH[7] >> 15);
}

void SW_idwt_db8_int16(int16_t low[8], int16_t high[8], int8_t out[16]) 
{
    const int half = N/2; // 8
    for (int n = 0; n < N; n++) {
        int64_t acc = 0; // wide to be extra safe

        // Convolve with upsampled low/high: only taps with matching parity contribute
        for (int t = 0; t < 16; t++) {
            int d = n - t;
            if ((d & 1) == 0) {                 // (n - t) even � non-zero after upsampling
                int k = (d >> 1);               // k = (n - t)/2
                // modulo for periodic extension
                k %= half;
                if (k < 0) k += half;

                acc += (int64_t)low[k]  * hr[t];
                acc += (int64_t)high[k] * gr[t];
            }
        }

        // Back from Q15
        int32_t s = (int32_t)(acc >> 15);
        out[n] = clamp_int8(s);
    }
}

void HW_idwt_db8_int16_core(int16_t low[8], int16_t high[8], int8_t out[16])
{
    int64_t acc[16]={0};

    //  0

    acc[ 0] += low[0]  * hr[0];
    acc[ 1] += low[0]  * hr[1];
    acc[ 2] += low[1]  * hr[0];
    acc[ 3] += low[1]  * hr[1];
    acc[ 4] += low[2]  * hr[0];
    acc[ 5] += low[2]  * hr[1];
    acc[ 6] += low[3]  * hr[0];
    acc[ 7] += low[3]  * hr[1];
    acc[ 8] += low[4]  * hr[0];
    acc[ 9] += low[4]  * hr[1];
    acc[10] += low[5]  * hr[0];
    acc[11] += low[5]  * hr[1];
    acc[12] += low[6]  * hr[0];
    acc[13] += low[6]  * hr[1];
    acc[14] += low[7]  * hr[0];
    acc[15] += low[7]  * hr[1];

    acc[ 0] += low[7]  * hr[2];
    acc[ 1] += low[7]  * hr[3];
    acc[ 2] += low[0]  * hr[2];
    acc[ 3] += low[0]  * hr[3];
    acc[ 4] += low[1]  * hr[2];
    acc[ 5] += low[1]  * hr[3];
    acc[ 6] += low[2]  * hr[2];
    acc[ 7] += low[2]  * hr[3];
    acc[ 8] += low[3]  * hr[2];
    acc[ 9] += low[3]  * hr[3];
    acc[10] += low[4]  * hr[2];
    acc[11] += low[4]  * hr[3];
    acc[12] += low[5]  * hr[2];
    acc[13] += low[5]  * hr[3];
    acc[14] += low[6]  * hr[2];
    acc[15] += low[6]  * hr[3];
    
    acc[ 0] += low[6]  * hr[4];
    acc[ 1] += low[6]  * hr[5];
    acc[ 2] += low[7]  * hr[4];
    acc[ 3] += low[7]  * hr[5];
    acc[ 4] += low[0]  * hr[4];
    acc[ 5] += low[0]  * hr[5];
    acc[ 6] += low[1]  * hr[4];
    acc[ 7] += low[1]  * hr[5];
    acc[ 8] += low[2]  * hr[4];
    acc[ 9] += low[2]  * hr[5];
    acc[10] += low[3]  * hr[4];
    acc[11] += low[3]  * hr[5];
    acc[12] += low[4]  * hr[4];
    acc[13] += low[4]  * hr[5];
    acc[14] += low[5]  * hr[4];
    acc[15] += low[5]  * hr[5];

    acc[ 0] += low[5]  * hr[6];
    acc[ 1] += low[5]  * hr[7];
    acc[ 2] += low[6]  * hr[6];
    acc[ 3] += low[6]  * hr[7];
    acc[ 4] += low[7]  * hr[6];
    acc[ 5] += low[7]  * hr[7];
    acc[ 6] += low[0]  * hr[6];
    acc[ 7] += low[0]  * hr[7];
    acc[ 8] += low[1]  * hr[6];
    acc[ 9] += low[1]  * hr[7];
    acc[10] += low[2]  * hr[6];
    acc[11] += low[2]  * hr[7];
    acc[12] += low[3]  * hr[6];
    acc[13] += low[3]  * hr[7];
    acc[14] += low[4]  * hr[6];
    acc[15] += low[4]  * hr[7];

    acc[ 0] += low[4]  * hr[8];
    acc[ 1] += low[4]  * hr[9];
    acc[ 2] += low[5]  * hr[8];
    acc[ 3] += low[5]  * hr[9];
    acc[ 4] += low[6]  * hr[8];
    acc[ 5] += low[6]  * hr[9];
    acc[ 6] += low[7]  * hr[8];
    acc[ 7] += low[7]  * hr[9];
    acc[ 8] += low[0]  * hr[8];
    acc[ 9] += low[0]  * hr[9];
    acc[10] += low[1]  * hr[8];
    acc[11] += low[1]  * hr[9]; 
    acc[12] += low[2]  * hr[8];
    acc[13] += low[2]  * hr[9];
    acc[14] += low[3]  * hr[8];
    acc[15] += low[3]  * hr[9];

    acc[ 0] += low[3]  * hr[10];
    acc[ 1] += low[3]  * hr[11];
    acc[ 2] += low[4]  * hr[10];
    acc[ 3] += low[4]  * hr[11];
    acc[ 4] += low[5]  * hr[10];
    acc[ 5] += low[5]  * hr[11];
    acc[ 6] += low[6]  * hr[10];
    acc[ 7] += low[6]  * hr[11];
    acc[ 8] += low[7]  * hr[10];
    acc[ 9] += low[7]  * hr[11];
    acc[10] += low[0]  * hr[10];
    acc[11] += low[0]  * hr[11];
    acc[12] += low[1]  * hr[10];
    acc[13] += low[1]  * hr[11];
    acc[14] += low[2]  * hr[10];
    acc[15] += low[2]  * hr[11];

    acc[ 0] += low[2]  * hr[12];
    acc[ 1] += low[2]  * hr[13];
    acc[ 2] += low[3]  * hr[12];
    acc[ 3] += low[3]  * hr[13];
    acc[ 4] += low[4]  * hr[12];
    acc[ 5] += low[4]  * hr[13];
    acc[ 6] += low[5]  * hr[12];
    acc[ 7] += low[5]  * hr[13];
    acc[ 8] += low[6]  * hr[12];
    acc[ 9] += low[6]  * hr[13];
    acc[10] += low[7]  * hr[12];
    acc[11] += low[7]  * hr[13];
    acc[12] += low[0]  * hr[12];
    acc[13] += low[0]  * hr[13];
    acc[14] += low[1]  * hr[12];
    acc[15] += low[1]  * hr[13];
    
    acc[ 0] += low[1]  * hr[14];
    acc[ 1] += low[1]  * hr[15];
    acc[ 2] += low[2]  * hr[14];
    acc[ 3] += low[2]  * hr[15];
    acc[ 4] += low[3]  * hr[14];
    acc[ 5] += low[3]  * hr[15];
    acc[ 6] += low[4]  * hr[14];
    acc[ 7] += low[4]  * hr[15];
    acc[ 8] += low[5]  * hr[14];
    acc[ 9] += low[5]  * hr[15];
    acc[10] += low[6]  * hr[14];
    acc[11] += low[6]  * hr[15];
    acc[12] += low[7]  * hr[14];
    acc[13] += low[7]  * hr[15];
    acc[14] += low[0]  * hr[14];
    acc[15] += low[0]  * hr[15];

    acc[ 0] += high[0]  * gr[0];
    acc[ 1] += high[0]  * gr[1];
    acc[ 2] += high[1]  * gr[0];
    acc[ 3] += high[1]  * gr[1];
    acc[ 4] += high[2]  * gr[0];
    acc[ 5] += high[2]  * gr[1];
    acc[ 6] += high[3]  * gr[0];
    acc[ 7] += high[3]  * gr[1];
    acc[ 8] += high[4]  * gr[0];
    acc[ 9] += high[4]  * gr[1];
    acc[10] += high[5]  * gr[0];
    acc[11] += high[5]  * gr[1];
    acc[12] += high[6]  * gr[0];
    acc[13] += high[6]  * gr[1];
    acc[14] += high[7]  * gr[0];
    acc[15] += high[7]  * gr[1];

    acc[ 0] += high[7]  * gr[2];
    acc[ 1] += high[7]  * gr[3];
    acc[ 2] += high[0]  * gr[2];
    acc[ 3] += high[0]  * gr[3];
    acc[ 4] += high[1]  * gr[2];
    acc[ 5] += high[1]  * gr[3];
    acc[ 6] += high[2]  * gr[2];
    acc[ 7] += high[2]  * gr[3];
    acc[ 8] += high[3]  * gr[2];
    acc[ 9] += high[3]  * gr[3];
    acc[10] += high[4]  * gr[2];
    acc[11] += high[4]  * gr[3];
    acc[12] += high[5]  * gr[2];
    acc[13] += high[5]  * gr[3];
    acc[14] += high[6]  * gr[2];
    acc[15] += high[6]  * gr[3];
    
    acc[ 0] += high[6]  * gr[4];
    acc[ 1] += high[6]  * gr[5];
    acc[ 2] += high[7]  * gr[4];
    acc[ 3] += high[7]  * gr[5];
    acc[ 4] += high[0]  * gr[4];
    acc[ 5] += high[0]  * gr[5];
    acc[ 6] += high[1]  * gr[4];
    acc[ 7] += high[1]  * gr[5];
    acc[ 8] += high[2]  * gr[4];
    acc[ 9] += high[2]  * gr[5];
    acc[10] += high[3]  * gr[4];
    acc[11] += high[3]  * gr[5];
    acc[12] += high[4]  * gr[4];
    acc[13] += high[4]  * gr[5];
    acc[14] += high[5]  * gr[4];
    acc[15] += high[5]  * gr[5];

    acc[ 0] += high[5]  * gr[6];
    acc[ 1] += high[5]  * gr[7];
    acc[ 2] += high[6]  * gr[6];
    acc[ 3] += high[6]  * gr[7];
    acc[ 4] += high[7]  * gr[6];
    acc[ 5] += high[7]  * gr[7];
    acc[ 6] += high[0]  * gr[6];
    acc[ 7] += high[0]  * gr[7];
    acc[ 8] += high[1]  * gr[6];
    acc[ 9] += high[1]  * gr[7];
    acc[10] += high[2]  * gr[6];
    acc[11] += high[2]  * gr[7];
    acc[12] += high[3]  * gr[6];
    acc[13] += high[3]  * gr[7];
    acc[14] += high[4]  * gr[6];
    acc[15] += high[4]  * gr[7];
    
    acc[ 0] += high[4]  * gr[8];
    acc[ 1] += high[4]  * gr[9];
    acc[ 2] += high[5]  * gr[8];
    acc[ 3] += high[5]  * gr[9];
    acc[ 4] += high[6]  * gr[8];
    acc[ 5] += high[6]  * gr[9];
    acc[ 6] += high[7]  * gr[8];
    acc[ 7] += high[7]  * gr[9];
    acc[ 8] += high[0]  * gr[8];
    acc[ 9] += high[0]  * gr[9];
    acc[10] += high[1]  * gr[8];
    acc[11] += high[1]  * gr[9];
    acc[12] += high[2]  * gr[8];
    acc[13] += high[2]  * gr[9];
    acc[14] += high[3]  * gr[8];
    acc[15] += high[3]  * gr[9];

    acc[ 0] += high[3]  * gr[10];
    acc[ 1] += high[3]  * gr[11];
    acc[ 2] += high[4]  * gr[10];
    acc[ 3] += high[4]  * gr[11];
    acc[ 4] += high[5]  * gr[10];
    acc[ 5] += high[5]  * gr[11];
    acc[ 6] += high[6]  * gr[10];
    acc[ 7] += high[6]  * gr[11];
    acc[ 8] += high[7]  * gr[10];
    acc[ 9] += high[7]  * gr[11];
    acc[10] += high[0]  * gr[10];
    acc[11] += high[0]  * gr[11];
    acc[12] += high[1]  * gr[10];
    acc[13] += high[1]  * gr[11];
    acc[14] += high[2]  * gr[10];
    acc[15] += high[2]  * gr[11];

    acc[ 0] += high[2]  * gr[12];
    acc[ 1] += high[2]  * gr[13];
    acc[ 2] += high[3]  * gr[12];
    acc[ 3] += high[3]  * gr[13];
    acc[ 4] += high[4]  * gr[12];
    acc[ 5] += high[4]  * gr[13];
    acc[ 6] += high[5]  * gr[12];
    acc[ 7] += high[5]  * gr[13];
    acc[ 8] += high[6]  * gr[12];
    acc[ 9] += high[6]  * gr[13];
    acc[10] += high[7]  * gr[12];
    acc[11] += high[7]  * gr[13];
    acc[12] += high[0]  * gr[12];
    acc[13] += high[0]  * gr[13];
    acc[14] += high[1]  * gr[12];
    acc[15] += high[1]  * gr[13];
    
    acc[ 0] += high[1]  * gr[14];
    acc[ 1] += high[1]  * gr[15];
    acc[ 2] += high[2]  * gr[14];
    acc[ 3] += high[2]  * gr[15];
    acc[ 4] += high[3]  * gr[14];
    acc[ 5] += high[3]  * gr[15];
    acc[ 6] += high[4]  * gr[14];
    acc[ 7] += high[4]  * gr[15];
    acc[ 8] += high[5]  * gr[14];
    acc[ 9] += high[5]  * gr[15];
    acc[10] += high[6]  * gr[14];
    acc[11] += high[6]  * gr[15];
    acc[12] += high[7]  * gr[14];
    acc[13] += high[7]  * gr[15];
    acc[14] += high[0]  * gr[14];
    acc[15] += high[0]  * gr[15];

    out[ 0] = clamp_int8((int32_t)(acc[ 0] >> 15));
    out[ 1] = clamp_int8((int32_t)(acc[ 1] >> 15));
    out[ 2] = clamp_int8((int32_t)(acc[ 2] >> 15));
    out[ 3] = clamp_int8((int32_t)(acc[ 3] >> 15));
    out[ 4] = clamp_int8((int32_t)(acc[ 4] >> 15));
    out[ 5] = clamp_int8((int32_t)(acc[ 5] >> 15));
    out[ 6] = clamp_int8((int32_t)(acc[ 6] >> 15));
    out[ 7] = clamp_int8((int32_t)(acc[ 7] >> 15));
    out[ 8] = clamp_int8((int32_t)(acc[ 8] >> 15));
    out[ 9] = clamp_int8((int32_t)(acc[ 9] >> 15));
    out[10] = clamp_int8((int32_t)(acc[10] >> 15));
    out[11] = clamp_int8((int32_t)(acc[11] >> 15));
    out[12] = clamp_int8((int32_t)(acc[12] >> 15));
    out[13] = clamp_int8((int32_t)(acc[13] >> 15));
    out[14] = clamp_int8((int32_t)(acc[14] >> 15));
    out[15] = clamp_int8((int32_t)(acc[15] >> 15));
}