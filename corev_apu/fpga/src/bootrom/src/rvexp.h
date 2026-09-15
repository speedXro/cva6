#ifndef RVEXP_H_
#define RVEXP_H_

#include <stdint.h>
#include <stdbool.h>

//Constants

//Software Defines
//#define FOR_SIMULATION 1 //comment this for synthesis
//#define FOR_LINUX 1 
//#define DBG_DELAY 1

//Utils

//Hardware Defines

#define ADATA_WIDTH                  32u

#ifdef FOR_SIMULATION
    #define PRINT_WITH_STDIO 0
    #define PRINT_WITH_USPF  0
#else
    #ifdef FOR_LINUX
        #define PRINT_WITH_STDIO 1
        #define PRINT_WITH_USPF  0
    #else
        #define PRINT_WITH_STDIO 0
        #define PRINT_WITH_USPF  1
    #endif
#endif

#define WORD_LEN ADATA_WIDTH

#if(WORD_LEN == 64u)
    typedef uint64_t DATA_WTYPE;
    #define OFFSET_MULTIPLIER 8
#else
    typedef uint32_t DATA_WTYPE;
    #define OFFSET_MULTIPLIER 4
#endif

#if (WORD_LEN == 64u)
    #ifdef FOR_SIMULATION
        #define AXI_BRAM_BASE 0x50000000u
        
        typedef uintptr_t ADDR_WTYPE;
    #else
        #ifdef FOR_LINUX
            #define AXI_BRAM_BASE 0x50000000UL
            #define MAP_SIZE     0x1000      // 4 KB
        #else
            #define AXI_BRAM_BASE 0x50000000ULL
        #endif
        typedef uint64_t ADDR_WTYPE; 
    #endif
#else
    #ifdef FOR_SIMULATION
        #define AXI_BRAM_BASE 0x50000000u
        typedef uintptr_t ADDR_WTYPE;
    #else
        #ifdef FOR_LINUX
            #define AXI_BRAM_BASE 0x50000000UL
        #else
            #define AXI_BRAM_BASE 0x50000000UL
        #endif
        typedef uint32_t ADDR_WTYPE;
    #endif
#endif
#define LEN_2         (MEM_SIZE / 4)


//static volatile uint64_t* RVEXP_Init(void);
//static void RVEXP_DeInit(void);
//static inline void RVEXP_Fence(void);

#ifndef FOR_LINUX
    void RVEXP_Write_Address(ADDR_WTYPE addr, DATA_WTYPE value);
    uint32_t RVEXP_Read_Address(ADDR_WTYPE addr); 
#endif

void RVEXP_Delay(int cycles);

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

//Macros

#define STR2(x) #x
#define STR(x) STR2(x)

#define RVEXP_INSN(result, rs1, rs2, opcode, funct3, funct7) \
    asm volatile (                                               \
        ".insn r " STR(opcode) ", " STR(funct3) ", " STR(funct7) ", %0, %1, %2" \
        : "=r"(result)                                           \
        : "r"(rs1), "r"(rs2)                                     \
    )

#define DO_SET_QM(op_h,op_l,dr)                                   \
    RVEXP_INSN(dr, op_h[0], op_l[0], OPCODE, 0x4, F7_SET_QM_W_0); \
    RVEXP_INSN(dr, op_h[1], op_l[1], OPCODE, 0x5, F7_SET_QM_W_0); \
    RVEXP_INSN(dr, op_h[2], op_l[2], OPCODE, 0x6, F7_SET_QM_W_0); \
    RVEXP_INSN(dr, op_h[3], op_l[3], OPCODE, 0x7, F7_SET_QM_W_0);

#define DO_GET_QM(results,dr)                                       \
    RVEXP_INSN(results[0], dr, dr, OPCODE, 0x0, F7_GET_QM_W_0);     \
    RVEXP_INSN(results[1], dr, dr, OPCODE, 0x1, F7_GET_QM_W_0);     \
    RVEXP_INSN(results[2], dr, dr, OPCODE, 0x2, F7_GET_QM_W_0);     \
    RVEXP_INSN(results[3], dr, dr, OPCODE, 0x3, F7_GET_QM_W_0);     \
    RVEXP_INSN(results[4], dr, dr, OPCODE, 0x4, F7_GET_QM_W_0);     \
    RVEXP_INSN(results[5], dr, dr, OPCODE, 0x5, F7_GET_QM_W_0);     \
    RVEXP_INSN(results[6], dr, dr, OPCODE, 0x6, F7_GET_QM_W_0);     \
    RVEXP_INSN(results[7], dr, dr, OPCODE, 0x7, F7_GET_QM_W_0);     
    
#define DO_SET_RM(op_h,op_l,dr)                                   \
    RVEXP_INSN(dr, op_h[0], op_l[0], OPCODE, 0x0, F7_SET_RM_W_0); \
    RVEXP_INSN(dr, op_h[1], op_l[1], OPCODE, 0x1, F7_SET_RM_W_0); \
    RVEXP_INSN(dr, op_h[2], op_l[2], OPCODE, 0x2, F7_SET_RM_W_0); \
    RVEXP_INSN(dr, op_h[3], op_l[3], OPCODE, 0x3, F7_SET_RM_W_0); \
    RVEXP_INSN(dr, op_h[4], op_l[4], OPCODE, 0x4, F7_SET_RM_W_0); \
    RVEXP_INSN(dr, op_h[5], op_l[5], OPCODE, 0x5, F7_SET_RM_W_0); \
    RVEXP_INSN(dr, op_h[6], op_l[6], OPCODE, 0x6, F7_SET_RM_W_0); \
    RVEXP_INSN(dr, op_h[7], op_l[7], OPCODE, 0x7, F7_SET_RM_W_0); \
    RVEXP_INSN(dr, op_h[8], op_l[8], OPCODE, 0x0, F7_SET_RM_W_1); \
    RVEXP_INSN(dr, op_h[9], op_l[9], OPCODE, 0x1, F7_SET_RM_W_1); \
    RVEXP_INSN(dr, op_h[10], op_l[10], OPCODE, 0x2, F7_SET_RM_W_1); \
    RVEXP_INSN(dr, op_h[11], op_l[11], OPCODE, 0x3, F7_SET_RM_W_1); \
    RVEXP_INSN(dr, op_h[12], op_l[12], OPCODE, 0x4, F7_SET_RM_W_1); \
    RVEXP_INSN(dr, op_h[13], op_l[13], OPCODE, 0x5, F7_SET_RM_W_1); \
    RVEXP_INSN(dr, op_h[14], op_l[14], OPCODE, 0x6, F7_SET_RM_W_1); \
    RVEXP_INSN(dr, op_h[15], op_l[15], OPCODE, 0x7, F7_SET_RM_W_1); 

#define DO_GET_RM(results,dr)                                       \
    RVEXP_INSN(results[0], dr, dr, OPCODE, 0x0, F7_GET_RM_W_0);     \
    RVEXP_INSN(results[1], dr, dr, OPCODE, 0x1, F7_GET_RM_W_0);     \
    RVEXP_INSN(results[2], dr, dr, OPCODE, 0x2, F7_GET_RM_W_0);     \
    RVEXP_INSN(results[3], dr, dr, OPCODE, 0x3, F7_GET_RM_W_0);     \
    RVEXP_INSN(results[4], dr, dr, OPCODE, 0x4, F7_GET_RM_W_0);     \
    RVEXP_INSN(results[5], dr, dr, OPCODE, 0x5, F7_GET_RM_W_0);     \
    RVEXP_INSN(results[6], dr, dr, OPCODE, 0x6, F7_GET_RM_W_0);     \
    RVEXP_INSN(results[7], dr, dr, OPCODE, 0x7, F7_GET_RM_W_0);     \
    RVEXP_INSN(results[8], dr, dr, OPCODE, 0x0, F7_GET_RM_W_1);     \
    RVEXP_INSN(results[9], dr, dr, OPCODE, 0x1, F7_GET_RM_W_1);     \
    RVEXP_INSN(results[10], dr, dr, OPCODE, 0x2, F7_GET_RM_W_1);     \
    RVEXP_INSN(results[11], dr, dr, OPCODE, 0x3, F7_GET_RM_W_1);     \
    RVEXP_INSN(results[12], dr, dr, OPCODE, 0x4, F7_GET_RM_W_1);     \
    RVEXP_INSN(results[13], dr, dr, OPCODE, 0x5, F7_GET_RM_W_1);     \
    RVEXP_INSN(results[14], dr, dr, OPCODE, 0x6, F7_GET_RM_W_1);     \
    RVEXP_INSN(results[15], dr, dr, OPCODE, 0x7, F7_GET_RM_W_1);     \
    RVEXP_INSN(results[16], dr, dr, OPCODE, 0x0, F7_GET_RM_W_2);     \
    RVEXP_INSN(results[17], dr, dr, OPCODE, 0x1, F7_GET_RM_W_2);     \
    RVEXP_INSN(results[18], dr, dr, OPCODE, 0x2, F7_GET_RM_W_2);     \
    RVEXP_INSN(results[19], dr, dr, OPCODE, 0x3, F7_GET_RM_W_2);     \
    RVEXP_INSN(results[20], dr, dr, OPCODE, 0x4, F7_GET_RM_W_2);     \
    RVEXP_INSN(results[21], dr, dr, OPCODE, 0x5, F7_GET_RM_W_2);     \
    RVEXP_INSN(results[22], dr, dr, OPCODE, 0x6, F7_GET_RM_W_2);     \
    RVEXP_INSN(results[23], dr, dr, OPCODE, 0x7, F7_GET_RM_W_2);     \
    RVEXP_INSN(results[24], dr, dr, OPCODE, 0x0, F7_GET_RM_W_3);     \
    RVEXP_INSN(results[25], dr, dr, OPCODE, 0x1, F7_GET_RM_W_3);     \
    RVEXP_INSN(results[26], dr, dr, OPCODE, 0x2, F7_GET_RM_W_3);     \
    RVEXP_INSN(results[27], dr, dr, OPCODE, 0x3, F7_GET_RM_W_3);     \
    RVEXP_INSN(results[28], dr, dr, OPCODE, 0x4, F7_GET_RM_W_3);     \
    RVEXP_INSN(results[29], dr, dr, OPCODE, 0x5, F7_GET_RM_W_3);     \
    RVEXP_INSN(results[30], dr, dr, OPCODE, 0x6, F7_GET_RM_W_3);     \
    RVEXP_INSN(results[31], dr, dr, OPCODE, 0x7, F7_GET_RM_W_3);     


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

    
    //Pack/Unpack Functions
    void Pack_QM_Inputs(uint8_t inputs[64], uint64_t p_ops_h[4], uint64_t p_ops_l[4]);
    void Unpack_QM_Outputs(uint64_t results[8], uint8_t outputs[64]);

    void Pack_RM_Inputs(uint32_t inputs[64], uint64_t p_ops_h[16], uint64_t p_ops_l[16]);
    void Unpack_RM_Outputs(uint64_t results[32], uint32_t outputs[64]);

    //Quantization Matrix
    void Set_QM(uint8_t input[64]);
    void Get_QM(uint8_t outputs[64]);

    // R Matrix
    void Set_RM(uint32_t input[64]);
    void Get_RM(uint32_t outputs[64]);

    
    void Get_AXIS_PerfTmrs(uint16_t ot_values[8], uint16_t in_values[8]);

    void DBG_DummyPrint(void);

#endif