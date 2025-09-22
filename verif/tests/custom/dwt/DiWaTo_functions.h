#ifndef DIWATO_FUNCTIONS_H_
#define DIWATO_FUNCTIONS_H_

#include <stdint.h>
#include <stdbool.h>

typedef union _I8U8
{
    int8_t  ival8;
    uint8_t uval8;
} I8U8;

typedef union _I16U16
{
	int16_t  ival16;
	uint16_t uval16;
} I16U16;


bool Compute_FDWT_CDF_53(int8_t inputs[16], int16_t low[8], int16_t high[8]);
bool Compute_IDWT_CDF_53(int16_t low[8], int16_t high[8], int8_t outputs[16]);

bool Compute_FDWT_DB_8(int8_t inputs[16], int16_t low[8], int16_t high[8]);
bool Compute_IDWT_DB_8(int16_t low[8], int16_t high[8], int8_t outputs[16]);

//uint64_t Get_Timestamp(void);

#endif