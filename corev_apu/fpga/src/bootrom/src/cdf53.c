#include "cdf53.h"
#include "upsf.h"

#define Q15 32768

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

uint32_t DMA_Length(uint32_t addr, uint32_t payload)
{
    uint32_t head_pad = (uint32_t)(addr & ALIGN_MASK);
    return head_pad + payload;
}

void RVEXP_DMA_SelectDevice(uint8_t device)
{
	uint64_t dma_device = (uint64_t)device;
	uint64_t selection_result = 0;
	
	SELECT_DMA(selection_result,dma_device);
}

void RVEXP_DMA_Reset(void)
{
	uint64_t dummy_rs = 0;
	uint64_t dummy_rd = 0;
	RVEXP_INSN(dummy_rd, dummy_rs, dummy_rs, OPCODE, F3_DMA_RESET, F7_DMA_OPERATION);
}

uint8_t RVEXP_DMA_Init(void)
{
	uint64_t dummy_rs = 0;
	uint64_t dummy_rd = 0;

    printf("DMA Init Error!\n");

	RVEXP_INSN(dummy_rd, dummy_rs, dummy_rs, OPCODE, F3_DMA_INIT, F7_DMA_OPERATION);

    return (uint8_t)dummy_rd;
}

uint8_t RVEXP_DMA_Transaction(uint64_t* source, uint64_t* destination, uint64_t source_length, uint64_t destination_length)
{
	uint32_t len_d = 0;
    uint32_t len_s = 0;

	uint32_t u_d_addr;
	uint32_t u_s_addr;
	
	uint64_t d_data = 0;
	uint64_t s_data = 0;
	
	uint64_t dummy_rd = 0;
	
	uintptr_t ps;
    uintptr_t pd;

    uint8_t done = 0;
    uint8_t status_complete, status_irc, status_err;

    ps = (uintptr_t)source;
    pd = (uintptr_t)destination;

    u_d_addr = (uint32_t)pd;
	u_s_addr = (uint32_t)ps;

    /* Make sure the CPU's stores into the source buffer are globally
     * visible before the DMA reads it (FENCE is U-mode legal). */
    asm volatile ("fence iorw, iorw" ::: "memory");
	
	DISABLE_D_CACHE;
	
	len_d = DMA_Length(u_d_addr, (uint32_t)destination_length);
	len_s = source_length;
	
	d_data = (((uint64_t)u_d_addr) << 32) | ((uint64_t)len_d);
	s_data = (((uint64_t)u_s_addr) << 32) | ((uint64_t)len_s);
	
	RVEXP_INSN(dummy_rd, d_data, s_data, OPCODE, F3_DMA_TRANSFER, F7_DMA_OPERATION);
	
    //printf("Transfer done");

    /*while(done == 0)
    {
        RVEXP_DMA_GetStatus_Opt(&status_complete, &status_irc, &status_err);
        if(status_complete) done = 1;
    }

    printf("Done!\n");*/

    ENABLE_D_CACHE;

    return (uint8_t)dummy_rd;
}

void RVEXP_DMA_GetStatus_Opt(uint8_t* p_complete, uint8_t* p_irc, uint8_t* p_error)
{
    uint64_t dummy_rs = 0;

    uint64_t status;
	uint32_t status_src;
    uint32_t status_dst;

    uint8_t complete_src, complete_dst;
    uint8_t irc_src=0, irc_dst=0;
    uint8_t err_src=0, err_dst=0;
    
    

    RVEXP_INSN(status, dummy_rs, dummy_rs, OPCODE, F3_DMA_GET_STATUS, F7_DMA_OPERATION);
	
	status_dst = (uint32_t)(status >> 32);
	status_src = (uint32_t)(status & 0xFFFFFFFF);
    
    complete_src = ((status_src & (1 << STS_BIT_IDLE)) != 0);
    complete_dst = ((status_dst & (1 << STS_BIT_IDLE)) != 0);

    irc_src = ((status_src & (1 << STS_BIT_IOC_IRQ)) != 0);
    irc_dst = ((status_dst & (1 << STS_BIT_IOC_IRQ)) != 0);

    err_src = ((status_src & ((1 << STS_BIT_SGD_ERR)|(1 << STS_BIT_SGS_ERR)|(1 << STS_BIT_SGI_ERR)|(1 << STS_BIT_DMD_ERR)|(1 << STS_BIT_DMS_ERR)|(1 << STS_BIT_DMI_ERR))) != 0);
    err_dst = ((status_dst & ((1 << STS_BIT_SGD_ERR)|(1 << STS_BIT_SGS_ERR)|(1 << STS_BIT_SGI_ERR)|(1 << STS_BIT_DMD_ERR)|(1 << STS_BIT_DMS_ERR)|(1 << STS_BIT_DMI_ERR))) != 0);

    *p_complete = ((complete_src != 0) && (complete_dst != 0));
    *p_irc      = ((irc_src      != 0) || (irc_dst      != 0));
    *p_error    = ((err_src      != 0) || (err_dst      != 0));
}

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

