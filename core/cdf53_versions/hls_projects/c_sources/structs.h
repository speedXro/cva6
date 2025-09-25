#ifndef STRUCTS_H_
#define STRUCTS_H_

#include <stdint.h>

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

#endif