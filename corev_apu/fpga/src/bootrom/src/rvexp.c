#include <stdbool.h>
#include "rvexp.h"

#include <stdint.h>

#ifdef FOR_LINUX
    #include <stdlib.h>
    #include <fcntl.h>
    #include <unistd.h>
    #include <sys/mman.h>
    #include <errno.h>
#endif

#if (PRINT_WITH_STDIO == 1)
    #include <stdio.h>
#endif

#if (PRINT_WITH_USPF == 1)
    #include "upsf.h"
#endif

//Pack/Unpack Functions
void Pack_QM_Inputs(uint8_t inputs[64], uint64_t p_ops_h[4], uint64_t p_ops_l[4])
{

    int i,k;

    uint8_t* p = inputs;

    for(k=0;k<4;++k)
    {
        p_ops_h[k] = 0u;
        p_ops_l[k] = 0u;

        if(k != 0) p+=8;
        for(i=0;i<8;++i) { p_ops_h[k] |= ((uint64_t)((uint8_t)p[i])) << ((8-i-1) * 8); }
        p+=8;
        for(i=0;i<8;++i) { p_ops_l[k] |= ((uint64_t)((uint8_t)p[i])) << ((8-i-1) * 8); }
    }

}

void Unpack_QM_Outputs(uint64_t results[8], uint8_t outputs[64])
{
    int i, j;
    int out_cnt = 0;
    for (i=0;i<8;++i)
    {
        for(j=0;j<8;++j)
        {
            outputs[out_cnt] = (uint8_t)((results[i] >> ((8-j-1)*8)) & 0xFFu);
            out_cnt++;
        }
    }
}

void Pack_RM_Inputs(uint32_t inputs[64], uint64_t p_ops_h[16], uint64_t p_ops_l[16])
{
    int i,k;

    uint32_t* p = inputs;

    for(k=0;k<16;++k)
    {
        p_ops_h[k] = 0u;
        p_ops_l[k] = 0u;
        if(k != 0) p+=2;
        for(i=0;i<2;++i) { p_ops_h[k] |= ((uint64_t)((uint32_t)p[i])) << ((2-i-1) * 32); }
        p+=2;
        for(i=0;i<2;++i) { p_ops_l[k] |= ((uint64_t)((uint32_t)p[i])) << ((2-i-1) * 32); }
    }
}

void Unpack_RM_Outputs(uint64_t results[32], uint32_t outputs[64])
{
    int i, j;
    int out_cnt = 0;

    for(i=0;i<32;++i)
    {
        for(j=0;j<2;++j) 
        {
            outputs[out_cnt] = (uint32_t)((results[i] >> ((2-j-1)*32)) & 0xFFFFFFFFu);
            out_cnt++;
        }
    }
}

//Quantization Matrix
void Set_QM(uint8_t inputs[64])
{
    uint64_t ops_h[4];
    uint64_t ops_l[4];

    uint8_t dummy_result;

    Pack_QM_Inputs(inputs, ops_h, ops_l);

    DO_SET_QM(ops_h,ops_l,dummy_result);
}

void Get_QM(uint8_t outputs[64])
{
    uint64_t dummy_rs = 0;
    uint64_t words[8];

    DO_GET_QM(words,dummy_rs);

    Unpack_QM_Outputs(words, outputs);
}

//R Matrix
void Set_RM(uint32_t input[64])
{
    uint8_t dummy_result;

    uint64_t ops_h[16];
    uint64_t ops_l[16];

    Pack_RM_Inputs(input, ops_h, ops_l);

    DO_SET_RM(ops_h,ops_l,dummy_result);
}

void Get_RM(uint32_t outputs[64])
{
    uint64_t dummy_rs = 0;
    uint64_t words[32];

    DO_GET_RM(words,dummy_rs);

    Unpack_RM_Outputs(words, outputs);
}

void DBG_DummyPrint(void)
{
    printf("Foo\n");
}

void Get_AXIS_PerfTmrs(uint16_t ot_values[8], uint16_t in_values[8])
{
    uint64_t dummy_val = 0;
    uint64_t u64values[8];
    int i;

    DO_GET_AXIS_TMRS(u64values,dummy_val);

    for(i=0;i<8;++i)
    {
        ot_values[i] = (uint16_t)((u64values[i] >> 16) & 0xFFFFu);
        in_values[i] = (uint16_t)((u64values[i] >>  0) & 0xFFFFu);
    }
}



#ifdef FOR_LINUX

static void *g_map = NULL;

static volatile DATA_WTYPE* RVEXP_Init(void)
{
    if (g_map) {
        return (volatile DATA_WTYPE*)g_map;
    }

    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0) {
        perror("open(/dev/mem)");
        return NULL;
    }

    g_map = mmap(NULL, MAP_SIZE,
                 PROT_READ | PROT_WRITE,
                 MAP_SHARED,
                 fd,
                 AXI_BRAM_BASE);

    close(fd);

    if (g_map == MAP_FAILED) {
        g_map = NULL;
        perror("mmap");
        return NULL;
    }

    return (volatile DATA_WTYPE*)g_map;
}

static void RVEXP_DeInit(void)
{
    if (g_map) {
        munmap(g_map, MAP_SIZE);
        g_map = NULL;
    }
}

static inline void RVEXP_Fence(void)
{
    asm volatile ("fence iorw, iorw" ::: "memory");
}

static inline DATA_WTYPE RVEXP_ReadWord(size_t offset)
{
    DATA_WTYPE v;

    if (offset + sizeof(DATA_WTYPE) > MAP_SIZE) {
        return 0;
    }
    v = *(volatile DATA_WTYPE *)((uint8_t *)g_map + offset);
    asm volatile ("fence iorw, iorw" ::: "memory");
    return v;
}

static inline void RVEXP_WriteWord(size_t offset, DATA_WTYPE value)
{
    if (offset + sizeof(DATA_WTYPE) > MAP_SIZE) {
        return;
    }

    *(volatile DATA_WTYPE *)((uint8_t *)g_map + offset) = value;
    asm volatile ("fence iorw, iorw" ::: "memory");
}

#else

void RVEXP_Write_Address(ADDR_WTYPE addr, DATA_WTYPE value)
{
    volatile DATA_WTYPE* loc_addr = (volatile DATA_WTYPE*)addr;
    *loc_addr=value;
    //asm volatile("fence iorw, iorw" ::: "memory");
}

DATA_WTYPE RVEXP_Read_Address(ADDR_WTYPE addr)
{
    DATA_WTYPE v = *(volatile DATA_WTYPE*)addr;
    //asm volatile("fence iorw, iorw" ::: "memory");
    return v;
}
#endif



void RVEXP_Delay(int cycles)
{
#ifdef DBG_DELAY
    for(int i=0;i<cycles;++i);
#endif
}