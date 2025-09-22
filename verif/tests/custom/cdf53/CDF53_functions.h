#ifndef DIWATO_FUNCTIONS_H_
#define DIWATO_FUNCTIONS_H_

#include <stdint.h>
#include <stdbool.h>

bool Compute_FDWT_CDF_53(int8_t inputs[16], int16_t low[8], int16_t high[8]);
bool Compute_IDWT_CDF_53(int16_t low[8], int16_t high[8], int8_t outputs[16]);

//uint64_t Get_Timestamp(void);

#endif