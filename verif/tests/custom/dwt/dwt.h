#ifndef DWT_H_
#define DWT_H_

#include <stdint.h>

#define N 16
#define HALF (N/2)

void SW_dwt53_forward(int8_t in[16], int16_t low[8], int16_t high[8]);
void SW_dwt53_inverse(int16_t low[8], int16_t high[8], int8_t out[16]);

void HW_dwt53_forward_core(int8_t in[16], int16_t low[8], int16_t high[8]);
void HW_dwt53_inverse_core(int16_t low[8], int16_t high[8], int8_t out[16]);

void SW_dwt_db8_int16(int8_t input[16], int16_t low[8], int16_t high[8]);
void SW_idwt_db8_int16(int16_t low[8], int16_t high[8], int8_t out[16]);

void HW_dwt_db8_int16_core(int8_t input[16], int16_t low[8], int16_t high[8]);
void HW_idwt_db8_int16_core(int16_t low[8], int16_t high[8], int8_t out[16]);
#endif