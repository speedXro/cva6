#include "dma.h"

//Register Access Functions

void WriteRegister(uint32_t address, uint32_t value)
{
    uint32_t* write_address = AXI_BRAM_BASE + address;
    uint32_t write_value = value;

    RVEXP_Write_Address(write_address, write_value);
    //printf("Written at address %p the value %p \r\n", write_address, write_value);
}

uint32_t ReadRegister(uint32_t address)
{
    uint32_t read_address = AXI_BRAM_BASE + address;
    return RVEXP_Read_Address(read_address);
}

uint8_t ReadBit(uint32_t adress, int8_t bitpos)
{
    uint32_t read_address = AXI_BRAM_BASE + adress;
    uint32_t read_value; 

    //printf("read_address = "); 
    read_value = RVEXP_Read_Address(read_address);
    //printf("Mem[%p] = %p \r\n", read_address, read_value);

    return ((read_value >> bitpos) & 1);
}

//DMA Functions

//  Init


uint32_t DMA_Length(uint32_t addr, uint32_t payload)
{
    uint32_t head_pad = (uint32_t)(addr & ALIGN_MASK);
    return head_pad + payload;
}

//New Functions

void DMA_Start_Channel(uint8_t channel)
{
    uint32_t reg_ctrl = (channel == CH_SRC_MM2S) ? REG_SRC_CTRL : REG_DST_CTRL;
    uint32_t reg_sts  = (channel == CH_SRC_MM2S) ? REG_SRC_STS  : REG_DST_STS;

    WriteRegister(reg_ctrl, (1u << CTRL_BIT_RS) | (1 << CTRL_BIT_IOCIRQEN));
    while(ReadBit(reg_sts, STS_BIT_HALTED));
}

void DMA_Write_Address(uint8_t channel, uint64_t* addr, uint32_t* p_uaddr)
{
    uint32_t reg_addr_lsb = (channel == CH_SRC_MM2S) ? REG_SRC_ADDR_LSB : REG_DST_ADDR_LSB;
    //uint32_t reg_addr_msb = (channel == CH_SRC_MM2S) ? REG_SRC_ADDR_MSB : REG_DST_ADDR_MSB;

    uintptr_t uaddr = (uintptr_t)addr;

    WriteRegister(reg_addr_lsb, uaddr);
    //WriteRegister(reg_addr_msb, 0u);

    *p_uaddr = (uint32_t)uaddr;
}

void DMA_Write_Length(uint8_t channel, uint32_t len)
{
    uint32_t reg_addr_length = (channel == CH_SRC_MM2S) ? REG_SRC_LEN : REG_DST_LEN;
    WriteRegister(reg_addr_length, len);
}

void DMA_Wait_Transfer_Complete(uint8_t channel)
{
    uint32_t reg_sts  = (channel == CH_SRC_MM2S) ? REG_SRC_STS  : REG_DST_STS;
    while(ReadBit(reg_sts, STS_BIT_IDLE) == 0);
}

void DMA_Wait_IOC_Irq(uint8_t channel)
{
    uint32_t reg_sts  = (channel == CH_SRC_MM2S) ? REG_SRC_STS  : REG_DST_STS;
    while (!ReadBit(reg_sts, STS_BIT_IOC_IRQ));
}

void DMA_Read_IRQs(uint8_t channel, uint8_t* p_err_irq, uint8_t* p_dly_irq, uint8_t* p_ioc_irq)
{
    uint32_t reg_sts  = (channel == CH_SRC_MM2S) ? REG_SRC_STS  : REG_DST_STS;
    uint32_t val = ReadRegister(reg_sts);

    *p_err_irq = ((val >> STS_BIT_ERR_IRQ) & 1u);
    *p_dly_irq = ((val >> STS_BIT_DLY_IRQ) & 1u);
    *p_ioc_irq = ((val >> STS_BIT_IOC_IRQ) & 1u);
}

void DMA_Clear_IRQs(uint8_t channel)
{
    uint32_t reg_sts  = (channel == CH_SRC_MM2S) ? REG_SRC_STS  : REG_DST_STS;
    uint32_t mask = 0u;
    mask |= (1u << STS_BIT_ERR_IRQ);
    mask |= (1u << STS_BIT_DLY_IRQ);
    mask |= (1u << STS_BIT_IOC_IRQ);
    WriteRegister(reg_sts, mask);
}

void DMA_Read_Errors(uint8_t channel, uint8_t* p_sgd_err, uint8_t* p_sgs_err, uint8_t* p_sgi_err, uint8_t* p_dmd_err, uint8_t* p_dms_err, uint8_t* p_dmi_err)
{
    uint32_t reg_sts = (channel == CH_SRC_MM2S) ? REG_SRC_STS  : REG_DST_STS;
    uint32_t val = ReadRegister(reg_sts);

    *p_sgd_err = ((val >> STS_BIT_SGD_ERR) & 1u);
    *p_sgs_err = ((val >> STS_BIT_SGS_ERR) & 1u);
    *p_sgi_err = ((val >> STS_BIT_SGI_ERR) & 1u);
    *p_dmd_err = ((val >> STS_BIT_DMD_ERR) & 1u);
    *p_dms_err = ((val >> STS_BIT_DMS_ERR) & 1u);
    *p_dmi_err = ((val >> STS_BIT_DMI_ERR) & 1u);
}

void DMA_Reset(void)
{
    WriteRegister(REG_SRC_CTRL, (1u << CTRL_BIT_RESET));
    //while(ReadBit(REG_SRC_CTRL, CTRL_BIT_RESET));
}

void DMA_Init(void)
{
    printf("Initializing DMA ...\r\n");

    DMA_Start_Channel(CH_DST_S2MM);
#ifdef DBG_PRINT_DMA
    printf("Started DMA Destination Channel!\r\n");
#endif
    DMA_Start_Channel(CH_SRC_MM2S);
#ifdef DBG_PRINT_DMA
    printf("Started DMA Source Channel!\r\n");
#endif
    printf("Initialized DMA!\r\n");
}

void DMA_Transaction(uint64_t* source, uint64_t* destination, uint64_t source_length, uint64_t destination_length)
{
    uint32_t u_d_addr = 0;
    uint32_t u_s_addr = 0;

    uint32_t len_d = 0;
    uint32_t len_s = 0;

    uint8_t d_err_irq, d_dly_irq, d_ioc_irq;
    uint8_t d_sgd_err, d_sgs_err, d_sgi_err, d_dmd_err, d_dms_err, d_dmi_err; 
    uint8_t d_err = 0, s_err = 0;

    uint32_t d_ioc_thr=0, s_ioc_thr=0;

    DISABLE_D_CACHE;

    DMA_Write_Address(CH_DST_S2MM, destination, &u_d_addr);
#ifdef DBG_PRINT_DMA
    printf("Written Destination Address: %08X\r\n", u_d_addr);
#endif

    DMA_Write_Address(CH_SRC_MM2S, source, &u_s_addr);
#ifdef DBG_PRINT_DMA
    printf("Written Source Address: %08X\r\n", u_s_addr);
#endif

    len_d = DMA_Length(u_d_addr, destination_length);
    DMA_Write_Length(CH_DST_S2MM, len_d);
#ifdef DBG_PRINT_DMA
    printf("Written Destination Length: %08X\r\n", len_d);
#endif

    //len_s = DMA_Length(u_s_addr, length);
    len_s = source_length;
    DMA_Write_Length(CH_SRC_MM2S, len_s);
#ifdef DBG_PRINT_DMA
    printf("Written Source Length: %08X\r\n", len_s);
#endif

    DMA_Wait_Transfer_Complete(CH_SRC_MM2S);
    DMA_Wait_Transfer_Complete(CH_DST_S2MM);
    DMA_Wait_IOC_Irq(CH_SRC_MM2S);
    DMA_Wait_IOC_Irq(CH_DST_S2MM);
#ifdef DBG_PRINT_DMA
    printf("Transfer Complete!\r\n");
#endif

    DMA_Read_IRQs(CH_DST_S2MM, &d_err_irq, &d_dly_irq, &d_ioc_irq);
#ifdef DBG_PRINT_DMA
    printf("Destination IRQs: err = %u , dly = %u, ioc = %u\r\n", d_err_irq, d_dly_irq, d_ioc_irq);
#endif
    if(d_err_irq == 1 || d_dly_irq == 1 || d_ioc_irq == 1)
    {
        DMA_Clear_IRQs(CH_DST_S2MM);
#ifdef DBG_PRINT_DMA
        printf("Cleared Destination IRQs!\r\n");
#endif
    }

    DMA_Read_IRQs(CH_SRC_MM2S, &d_err_irq, &d_dly_irq, &d_ioc_irq);
#ifdef DBG_PRINT_DMA
    printf("Source IRQs: err = %u , dly = %u, ioc = %u\r\n", d_err_irq, d_dly_irq, d_ioc_irq);
#endif
    if(d_err_irq == 1 || d_dly_irq == 1 || d_ioc_irq == 1)
    {
        DMA_Clear_IRQs(CH_SRC_MM2S);
#ifdef DBG_PRINT_DMA
        printf("Cleared Source IRQs!\r\n");
#endif
    }

    DMA_Read_Errors(CH_DST_S2MM, &d_sgd_err, &d_sgs_err, &d_sgi_err, &d_dmd_err, &d_dms_err, &d_dmi_err);
#ifdef DBG_PRINT_DMA
    printf("Destination Errors: sgd = %u , sgs = %u , sgi = %u , dmd = %u , dms = %u , dmi = %u\r\n", d_sgd_err, d_sgs_err, d_sgi_err, d_dmd_err, d_dms_err, d_dmi_err);
#endif
    d_err = d_sgd_err | d_sgs_err | d_sgi_err | d_dmd_err | d_dms_err | d_dmi_err;

    DMA_Read_Errors(CH_SRC_MM2S, &d_sgd_err, &d_sgs_err, &d_sgi_err, &d_dmd_err, &d_dms_err, &d_dmi_err);
#ifdef DBG_PRINT_DMA
    printf("Source Errors: sgd = %u , sgs = %u , sgi = %u , dmd = %u , dms = %u , dmi = %u\r\n", d_sgd_err, d_sgs_err, d_sgi_err, d_dmd_err, d_dms_err, d_dmi_err);
#endif
    s_err = d_sgd_err | d_sgs_err | d_sgi_err | d_dmd_err | d_dms_err | d_dmi_err;

    d_err |= s_err;

    if(d_err)
    {
        DMA_Reset();
//#ifdef DBG_PRINT_DMA
        printf("Reset DMA!\r\n");
//#endif
    }
    else
    {
#ifdef DBG_PRINT_DMA
        printf("DMA Transfer Complete with no errors\r\n");
#endif
    }

    ENABLE_D_CACHE;   
}