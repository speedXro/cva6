#include "fdct2d.h"
#include "upsf.h"

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

//PRAM Operations

uint8_t Write_Bram_NoSel(uint64_t address, uint64_t data)
{
    uint64_t result;

    RVEXP_INSN(result, address, data, OPCODE, F3_WRITE_PRAM, F7_PRAM_OPERATION);

    return result;
}

uint64_t Read_Bram_NoSel(uint64_t address)
{
    uint64_t dummy_rs = 0;
    uint64_t result;

    RVEXP_INSN(result, address, dummy_rs, OPCODE, F3_READ_PRAM, F7_PRAM_OPERATION);

    return result;
}

uint8_t Select_PRAM(uint8_t pram_selection)
{
    uint64_t dummy_rs = 0;
    uint8_t result;
    uint64_t pram_inst = (uint64_t)pram_selection;

    RVEXP_INSN(result, pram_inst, dummy_rs, OPCODE, F3_SELECT_PRAM, F7_PRAM_OPERATION);

    return result;
}

uint8_t Write_Bram(uint8_t block, uint64_t address, uint64_t data)
{
    uint64_t result;
    Select_PRAM(block);
    RVEXP_INSN(result, address, data, OPCODE, F3_WRITE_PRAM, F7_PRAM_OPERATION);

    return result;
}

uint64_t Read_Bram(uint8_t block, uint64_t address)
{
    uint64_t dummy_rs = 0;
    uint64_t result;

    Select_PRAM(block);
    RVEXP_INSN(result, address, dummy_rs, OPCODE, F3_READ_PRAM, F7_PRAM_OPERATION);

    return result;
}

uint8_t  AD_Write_Bram(uint64_t address, uint64_t data) { return Write_Bram(BLOCK_AD, address, data); }
uint64_t AD_Read_Bram(uint64_t address)                 { return Read_Bram( BLOCK_AD, address);       }
uint8_t  UA_Write_Bram(uint64_t address, uint64_t data) { return Write_Bram(BLOCK_UA, address, data); }
uint64_t UA_Read_Bram(uint64_t address)                 { return Read_Bram( BLOCK_UA, address);       }



void Write_AD_Array(uint64_t* array, int len){Select_PRAM(BLOCK_AD); for(int i=0;i<len;++i){Write_Bram_NoSel((uint64_t)i, array[i]);}}
void Write_UA_Array(uint64_t* array, int len){Select_PRAM(BLOCK_UA); for(int i=0;i<len;++i){Write_Bram_NoSel((uint64_t)i, array[i]);}}

void Read_AD_Array(uint64_t* array, int len){Select_PRAM(BLOCK_AD); for(int i=0;i<len;++i){array[i]=Read_Bram_NoSel((uint64_t)i);}}
void Read_UA_Array(uint64_t* array, int len){Select_PRAM(BLOCK_UA); for(int i=0;i<len;++i){array[i]=Read_Bram_NoSel((uint64_t)i);}}

//Block Operations
uint8_t  Block_Start(uint8_t block)
{
    uint64_t dummy_rs = 0;
    uint64_t result;

    switch(block)
    {
        case BLOCK_AD: RVEXP_INSN(result, dummy_rs, dummy_rs, OPCODE, F3_AD_START, F7_AD_OPERATION); break;
        case BLOCK_UA: RVEXP_INSN(result, dummy_rs, dummy_rs, OPCODE, F3_UA_START, F7_UA_OPERATION); break;
        default      : RVEXP_INSN(result, dummy_rs, dummy_rs, OPCODE, F3_AD_START, F7_AD_OPERATION); break;
    }

    return result;
}

uint8_t  Block_Clear(uint8_t block)
{
    uint64_t dummy_rs = 0;
    uint64_t result;

    switch(block)
    {
        case BLOCK_AD: RVEXP_INSN(result, dummy_rs, dummy_rs, OPCODE, F3_AD_CLEAR, F7_AD_OPERATION); break;
        case BLOCK_UA: RVEXP_INSN(result, dummy_rs, dummy_rs, OPCODE, F3_UA_CLEAR, F7_UA_OPERATION); break;
        default      : RVEXP_INSN(result, dummy_rs, dummy_rs, OPCODE, F3_AD_CLEAR, F7_AD_OPERATION); break;
    }

    return result;
}

uint64_t  Block_Get_Write_Counter(void)
{
    uint64_t dummy_rs = 0;
    uint64_t result;

    RVEXP_INSN(result, dummy_rs, dummy_rs, OPCODE, F3_AD_GET_WR_CNT, F7_AD_OPERATION); 

    return result;
}

uint64_t Block_Get_Read_Counter(void)
{
    uint64_t dummy_rs = 0;
    uint64_t result;

    RVEXP_INSN(result, dummy_rs, dummy_rs, OPCODE, F3_UA_GET_RD_CNT, F7_UA_OPERATION); 

    return result;
}


//AD,SF,FD,FI
uint8_t  AD_Aq_Start(void) {return Block_Start(BLOCK_AD);}
uint8_t  UA_Start(void)    {return Block_Start(BLOCK_UA);}

uint8_t  AD_Aq_Clear(void) {return Block_Clear(BLOCK_AD);}
uint8_t  UA_Clear(void)    {return Block_Clear(BLOCK_UA);}

void AD_Get_Statuses(uint8_t* p_ad_full) 
{
    uint64_t dummy_rs = 0;
    uint64_t result;

    RVEXP_INSN(result, dummy_rs, dummy_rs, OPCODE, F3_AD_GET_STATS, F7_AD_OPERATION);

    *p_ad_full = (uint8_t)(result & 0x1u);
}
void UA_Get_Statuses(uint8_t* p_sf_empty) 
{
    uint64_t dummy_rs = 0;
    uint64_t result;

    RVEXP_INSN(result, dummy_rs, dummy_rs, OPCODE, F3_UA_GET_STATS, F7_UA_OPERATION);

    *p_sf_empty = (uint8_t)(result & 0x1u);
}

uint64_t AD_Get_Write_Counter(void) {return Block_Get_Write_Counter();}

uint64_t UA_Get_Read_Counter(void) {return Block_Get_Read_Counter();}


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

uint8_t STFT_Configure(STFT_Config new_config, STFT_Config* p_old)
{
    uint64_t rs1 = 0;
    uint64_t dummy_rs2 = 0;
    uint64_t instr_result;

    rs1 |= ((uint64_t)new_config.window_sel)  & 0x3u;
    rs1 |= (((uint64_t)new_config.enable)     & 0x1u) << 2;
    rs1 |= (((uint64_t)new_config.out_format) & 0x3u) << 3;
    rs1 |= (((uint64_t)new_config.pix_flor)   & 0x3u) << 5;
    
    RVEXP_INSN(instr_result, rs1, dummy_rs2, OPCODE, F3_STFT_CFG, F7_STFT_OPERATION);

    p_old->window_sel = instr_result & 0x3u;
    p_old->enable     = (instr_result >> 2) & 0x1u;
    p_old->out_format = (instr_result >> 3) & 0x3u;
    p_old->pix_flor   = (instr_result >> 5) & 0x3u;

    return 0;
}

uint8_t STFT_Start(void)
{
    uint64_t dummy_rs = 0;
    uint64_t instr_result;

    RVEXP_INSN(instr_result, dummy_rs, dummy_rs, OPCODE, F3_STFT_START, F7_STFT_OPERATION);

    return instr_result;
}

uint8_t STFT_Reset(void)
{
    uint64_t dummy_rs = 0;
    uint64_t instr_result;

    RVEXP_INSN(instr_result, dummy_rs, dummy_rs, OPCODE, F3_STFT_RESET, F7_STFT_OPERATION);

    return instr_result;
}

STFT_Status STFT_GetStatus(void)
{
    uint64_t dummy_rs = 0;
    uint64_t instr_result;
    STFT_Status status;

    RVEXP_INSN(instr_result, dummy_rs, dummy_rs, OPCODE, F3_STFT_STATUS, F7_STFT_OPERATION);

    status.ctrl_busy   = (instr_result >> 0) & 0x1u;
    status.frame_done  = (instr_result >> 1) & 0x1u;
    status.frame_full  = (instr_result >> 2) & 0x1u;
    status.frame_count = (instr_result >> 8) & 0xFF;

    return status;
}
