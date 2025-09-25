#include <stdint.h>



void SW_dwt53_forward(int8_t in[16], int16_t low[8], int16_t high[8]);
void SW_dwt53_inverse(int16_t low[8], int16_t high[8], int8_t out[16]);

//core functions
void HW_dwt53_forward_core(int8_t in[16], int16_t low[8], int16_t high[8]);
void HW_dwt53_inverse_core(int16_t low[8], int16_t high[8], int8_t out[16]);

//top functions
void HW_dwt53_forward(uint64_t op1, uint64_t op2, uint64_t* p_low_03, uint64_t* p_low_47, uint64_t* p_high_03, uint64_t* p_high_47);
void HW_dwt53_inverse(uint64_t low_03, uint64_t low_47, uint64_t high_03, uint64_t high_47, uint64_t* p_out_0, uint64_t* p_out_1);

