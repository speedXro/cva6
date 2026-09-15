#ifndef DMA_H_
#define DMA_H_

#include <stdint.h>
#include "rvexp.h"
#include "upsf.h"

#define ALIGN           0x40u          // 64-byte AXI bus alignment
#define ALIGN_MASK      (ALIGN - 1u)   // 0x3F
#define PAYLOAD_BYTES   0x40u          // 8 × 64-bit words

//#define AXI_BRAM_BASE 0x50000000ULL

//Channels
#define CH_SRC_MM2S 0
#define CH_DST_S2MM 1

//Register Bits Positions
#define CTRL_BIT_RS        0u
#define CTRL_BIT_RESET     2u
#define CTRL_BIT_IOCIRQEN 12u
#define STS_BIT_HALTED     0u
#define STS_BIT_IDLE       1u

#define STS_BIT_ERR_IRQ  14u
#define STS_BIT_DLY_IRQ  13u
#define STS_BIT_IOC_IRQ  12u

#define STS_BIT_SGD_ERR  10u
#define STS_BIT_SGS_ERR   9u
#define STS_BIT_SGI_ERR   8u
#define STS_BIT_DMD_ERR   6u
#define STS_BIT_DMS_ERR   5u
#define STS_BIT_DMI_ERR   4u

//Register Space Addresses
#define REG_SRC_CTRL      0x00u
#define REG_SRC_STS       0x04u
#define REG_SRC_ADDR_LSB  0x18u
#define REG_SRC_ADDR_MSB  0x1Cu
#define REG_SRC_LEN       0x28u

#define REG_DST_CTRL     0x30u
#define REG_DST_STS      0x34u
#define REG_DST_ADDR_LSB 0x48u
#define REG_DST_ADDR_MSB 0x4Cu
#define REG_DST_LEN      0x58u

#define DISABLE_D_CACHE  __asm__ volatile ("fence" ::: "memory"); __asm__ volatile ("csrwi 0x7C1, 0\n" ::: "memory")
#define ENABLE_D_CACHE   __asm__ volatile ("fence" ::: "memory"); __asm__ volatile ("csrwi 0x7C1, 1\n" ::: "memory")

//#define DBG_PRINT_DMA 1

//Register Access Functions

void WriteRegister(uint32_t address, uint32_t value);
uint32_t ReadRegister(uint32_t address);
uint8_t ReadBit(uint32_t adress, int8_t bitpos);
uint32_t DMA_Length(uint32_t addr, uint32_t payload);

//DMA Functions
void DMA_Start_Channel(uint8_t channel); 
void DMA_Write_Address(uint8_t channel, uint64_t* addr, uint32_t* p_uaddr);
void DMA_Write_Length(uint8_t channel, uint32_t len);
void DMA_Wait_Transfer_Complete(uint8_t channel);
void DMA_Wait_IOC_Irq(uint8_t channel);
void DMA_Read_IRQs(uint8_t channel, uint8_t* p_err_irq, uint8_t* p_dly_irq, uint8_t* p_ioc_irq);
void DMA_Clear_IRQs(uint8_t channel);
void DMA_Read_Errors(uint8_t channel, uint8_t* p_sgd_err, uint8_t* p_sgs_err, uint8_t* p_sgi_err, uint8_t* p_dmd_err, uint8_t* p_dms_err, uint8_t* p_dmi_err);

void DMA_Reset(void);
void DMA_Init(void);
void DMA_Transaction(uint64_t* source, uint64_t* destination, uint64_t source_length, uint64_t destination_length);

#endif