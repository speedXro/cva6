#ifndef CDF53_H_
#define CDF53_H_

#include <stdint.h>
#include <stdbool.h>

#ifndef DMA_BUF_BASE
#define DMA_BUF_BASE    0xBFF00000UL    /* physical base of reserved RAM */
#endif
#ifndef DMA_BUF_SIZE
#define DMA_BUF_SIZE    0x00100000UL    /* 1 MiB                         */
#endif

#define ALIGN           0x40u           /* 64-byte AXI bus alignment     */
#define ALIGN_MASK      (ALIGN - 1u)    /* 0x3F                          */
#define PAYLOAD_BYTES   0x40u           /* 8 x 64-bit words              */

/* ---- Channels ---- */
#define CH_SRC_MM2S 0
#define CH_DST_S2MM 1

/* ---- Register bit positions ---- */
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

/* ---- Register space addresses ---- */
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

#define OPCODE 0x7B

#define F7_SET_QM_W_0 0x40
#define F7_GET_QM_W_0 0x50

#define F7_SET_RM_W_0 0x41
#define F7_SET_RM_W_1 0x42

#define F7_GET_RM_W_0 0x51
#define F7_GET_RM_W_1 0x52
#define F7_GET_RM_W_2 0x53
#define F7_GET_RM_W_3 0x54


#define F7_GET_AXIS_TMRS 0x60
#define F7_GET_AXIS_CNTS 0x61

#define F7_DMA_OPERATION  0x70
#define F3_DMA_SELECTION  0x03
#define F3_DMA_RESET      0x04
#define F3_DMA_INIT       0x05
#define F3_DMA_TRANSFER   0x06
#define F3_DMA_GET_STATUS 0x07

#define N 16
#define HALF (N/2)

#define DISABLE_D_CACHE  __asm__ volatile ("fence" ::: "memory"); __asm__ volatile ("csrwi 0x7C1, 0\n" ::: "memory")
#define ENABLE_D_CACHE   __asm__ volatile ("fence" ::: "memory"); __asm__ volatile ("csrwi 0x7C1, 1\n" ::: "memory")

#define STR2(x) #x
#define STR(x) STR2(x)

#define RVEXP_INSN(result, rs1, rs2, opcode, funct3, funct7) \
    asm volatile (                                               \
        ".insn r " STR(opcode) ", " STR(funct3) ", " STR(funct7) ", %0, %1, %2" \
        : "=r"(result)                                           \
        : "r"(rs1), "r"(rs2)                                     \
    )

#define SELECT_DMA(selection_result,dma_device)                                   \
    RVEXP_INSN(selection_result, dma_device, dma_device, OPCODE, F3_DMA_SELECTION, F7_DMA_OPERATION);   

#define DO_GET_AXIS_TMRS(results,dr)                                   \
    RVEXP_INSN(results[0], dr, dr, OPCODE, 0x0, F7_GET_AXIS_TMRS);     \
    RVEXP_INSN(results[1], dr, dr, OPCODE, 0x1, F7_GET_AXIS_TMRS);     \
    RVEXP_INSN(results[2], dr, dr, OPCODE, 0x2, F7_GET_AXIS_TMRS);     \
    RVEXP_INSN(results[3], dr, dr, OPCODE, 0x3, F7_GET_AXIS_TMRS);     \
    RVEXP_INSN(results[4], dr, dr, OPCODE, 0x4, F7_GET_AXIS_TMRS);     \
    RVEXP_INSN(results[5], dr, dr, OPCODE, 0x5, F7_GET_AXIS_TMRS);     \
    RVEXP_INSN(results[6], dr, dr, OPCODE, 0x6, F7_GET_AXIS_TMRS);     \
    RVEXP_INSN(results[7], dr, dr, OPCODE, 0x7, F7_GET_AXIS_TMRS);  
    
#define DO_GET_AXIS_CNTS(results,dr)                                   \
    RVEXP_INSN(results[0], dr, dr, OPCODE, 0x0, F7_GET_AXIS_CNTS);     \
    RVEXP_INSN(results[1], dr, dr, OPCODE, 0x1, F7_GET_AXIS_CNTS);     


void Get_AXIS_PerfTmrs(uint16_t ot_values[8], uint16_t in_values[8]);

uint32_t DMA_Length(uint32_t addr, uint32_t payload);

void RVEXP_DMA_SelectDevice(uint8_t device);
void RVEXP_DMA_Reset(void);
uint8_t RVEXP_DMA_Init(void);
uint8_t RVEXP_DMA_Transaction(uint64_t* source, uint64_t* destination, uint64_t source_length, uint64_t destination_length);
void RVEXP_DMA_GetStatus_Opt(uint8_t* p_complete, uint8_t* p_irc, uint8_t* p_error);

//SW
void SW_dwt53_forward(int8_t in[16], int16_t low[8], int16_t high[8]);
void SW_dwt53_inverse(int16_t low[8], int16_t high[8], int8_t out[16]);

#endif
