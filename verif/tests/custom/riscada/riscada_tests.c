#include <stdint.h>
#include <stdio.h>
#include "ADA_functions.h"

int delaay(int del)
{
    int d=0;
    for(d=0;d<del;++d);
    return d;
}

void Test_DA_SetVal_GetVal()
{
    uint8_t i;
    uint16_t getval=0;

    uint16_t vals[16] = {
        0x100, 0x200, 0x300, 0x400,
        0x500, 0x600, 0x700, 0x800,
        0x900, 0xA00, 0xB00, 0xC00,
        0xD00, 0xE00, 0xF00, 0xFFF
    };

    for(i=0;i<16;++i)
    {
        DA_SetValue(0, vals[i]);
        delaay(4);
        DA_GetValue(0, &getval);
        if(vals[i] == getval) continue;
        else return;
    }

    
}

int main(int argc, char* arg[])
{
    Test_DA_SetVal_GetVal();

    delaay(100);

    return 0;
}