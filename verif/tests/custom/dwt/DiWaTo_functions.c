#include <stdbool.h>
#include "DiWaTo_functions.h"

bool Compute_FDWT_CDF_53(int8_t inputs[16], int16_t low[8], int16_t high[8])
{
    uint64_t result = 0;
    uint64_t dummy_rs1 = 0;
    uint64_t dummy_rs2 = 0;

    uint64_t input_u64_1;
    uint64_t input_u64_2;

    uint64_t result_low_03 = 0;
    uint64_t result_low_47 = 0;
    uint64_t result_high_03 = 0;
    uint64_t result_high_47 = 0;

    input_u64_1=0;
    input_u64_1 |= ((uint64_t)((uint8_t)inputs[0])) << (7*8);
    input_u64_1 |= ((uint64_t)((uint8_t)inputs[1])) << (6*8);
    input_u64_1 |= ((uint64_t)((uint8_t)inputs[2])) << (5*8);
    input_u64_1 |= ((uint64_t)((uint8_t)inputs[3])) << (4*8);
    input_u64_1 |= ((uint64_t)((uint8_t)inputs[4])) << (3*8);
    input_u64_1 |= ((uint64_t)((uint8_t)inputs[5])) << (2*8);
    input_u64_1 |= ((uint64_t)((uint8_t)inputs[6])) << (1*8);
    input_u64_1 |= ((uint64_t)((uint8_t)inputs[7])) << (0*8);

    input_u64_2=0;
    input_u64_2 |= ((uint64_t)((uint8_t)inputs[8]))  << (7*8);
    input_u64_2 |= ((uint64_t)((uint8_t)inputs[9]))  << (6*8);
    input_u64_2 |= ((uint64_t)((uint8_t)inputs[10])) << (5*8);
    input_u64_2 |= ((uint64_t)((uint8_t)inputs[11])) << (4*8);
    input_u64_2 |= ((uint64_t)((uint8_t)inputs[12])) << (3*8);
    input_u64_2 |= ((uint64_t)((uint8_t)inputs[13])) << (2*8);
    input_u64_2 |= ((uint64_t)((uint8_t)inputs[14])) << (1*8);
    input_u64_2 |= ((uint64_t)((uint8_t)inputs[15])) << (0*8);

    asm volatile (
		".insn r 0x7B, 0x3, 0x43, %0, %1, %2"
		: "=r" (result)
		: "r" (input_u64_1) , "r" (input_u64_2)
	  );

    if(result != 1) return false;

    asm volatile (
		".insn r 0x7B, 0x4, 0x43, %0, %1, %2"
		: "=r" (result_low_03)
		: "r" (dummy_rs1) , "r" (dummy_rs2)
	  );

    asm volatile (
		".insn r 0x7B, 0x5, 0x43, %0, %1, %2"
		: "=r" (result_low_47)
		: "r" (dummy_rs1) , "r" (dummy_rs2)
	  );

    asm volatile (
		".insn r 0x7B, 0x6, 0x43, %0, %1, %2"
		: "=r" (result_high_03)
		: "r" (dummy_rs1) , "r" (dummy_rs2)
	  );

    asm volatile (
		".insn r 0x7B, 0x7, 0x43, %0, %1, %2"
		: "=r" (result_high_47)
		: "r" (dummy_rs1) , "r" (dummy_rs2)
	  );

    low[0] = (int16_t)(result_low_03 >> (3*16));
    low[1] = (int16_t)(result_low_03 >> (2*16));
    low[2] = (int16_t)(result_low_03 >> (1*16));
    low[3] = (int16_t)(result_low_03 >> (0*16));
    low[4] = (int16_t)(result_low_47 >> (3*16));
    low[5] = (int16_t)(result_low_47 >> (2*16));
    low[6] = (int16_t)(result_low_47 >> (1*16));
    low[7] = (int16_t)(result_low_47 >> (0*16));

    high[0] = (int16_t)(result_high_03 >> (3*16));
    high[1] = (int16_t)(result_high_03 >> (2*16));
    high[2] = (int16_t)(result_high_03 >> (1*16));
    high[3] = (int16_t)(result_high_03 >> (0*16));
    high[4] = (int16_t)(result_high_47 >> (3*16));
    high[5] = (int16_t)(result_high_47 >> (2*16));
    high[6] = (int16_t)(result_high_47 >> (1*16));
    high[7] = (int16_t)(result_high_47 >> (0*16));

    return true;
}

bool Compute_IDWT_CDF_53(int16_t low[8], int16_t high[8], int8_t outputs[16])
{
    uint64_t result;

    uint64_t rs1 = 0;
    uint64_t rs2 = 0;
    uint64_t rs3 = 0;
    uint64_t rs4 = 0;

    uint64_t dummy_rs1 = 0;
    uint64_t dummy_rs2 = 0;

    uint64_t result_0 = 0;
    uint64_t result_1 = 0;

    rs1=0;
    rs1 |= ((uint64_t)((uint16_t)low[0])) << (3*16);
    rs1 |= ((uint64_t)((uint16_t)low[1])) << (2*16);
    rs1 |= ((uint64_t)((uint16_t)low[2])) << (1*16);
    rs1 |= ((uint64_t)((uint16_t)low[3])) << (0*16);

    rs2=0;
    rs2 |= ((uint64_t)((uint16_t)low[4])) << (3*16);
    rs2 |= ((uint64_t)((uint16_t)low[5])) << (2*16);
    rs2 |= ((uint64_t)((uint16_t)low[6])) << (1*16);
    rs2 |= ((uint64_t)((uint16_t)low[7])) << (0*16);

    rs3=0;
    rs3 |= ((uint64_t)((uint16_t)high[0])) << (3*16);
    rs3 |= ((uint64_t)((uint16_t)high[1])) << (2*16);
    rs3 |= ((uint64_t)((uint16_t)high[2])) << (1*16);
    rs3 |= ((uint64_t)((uint16_t)high[3])) << (0*16);

    rs4=0;
    rs4 |= ((uint64_t)((uint16_t)high[4])) << (3*16);
    rs4 |= ((uint64_t)((uint16_t)high[5])) << (2*16);
    rs4 |= ((uint64_t)((uint16_t)high[6])) << (1*16);
    rs4 |= ((uint64_t)((uint16_t)high[7])) << (0*16);

    asm volatile (
		".insn r 0x7B, 0x2, 0x44, %0, %1, %2"
		: "=r" (result)
		: "r" (rs1) , "r" (rs2)
	 );

    if(result != 2) return false;

    asm volatile (
		".insn r 0x7B, 0x3, 0x44, %0, %1, %2"
		: "=r" (result)
		: "r" (rs3) , "r" (rs4)
	 );

    if(result != 3) return false;

    asm volatile (
		".insn r 0x7B, 0x4, 0x44, %0, %1, %2"
		: "=r" (result_0)
		: "r" (dummy_rs1) , "r" (dummy_rs2)
	  );

    asm volatile (
		".insn r 0x7B, 0x5, 0x44, %0, %1, %2"
		: "=r" (result_1)
		: "r" (dummy_rs1) , "r" (dummy_rs2)
	);

    outputs[ 0] = (int16_t) (result_0 >> (7*8));
    outputs[ 1] = (int16_t) (result_0 >> (6*8));
    outputs[ 2] = (int16_t) (result_0 >> (5*8));
    outputs[ 3] = (int16_t) (result_0 >> (4*8));
    outputs[ 4] = (int16_t) (result_0 >> (3*8));
    outputs[ 5] = (int16_t) (result_0 >> (2*8));
    outputs[ 6] = (int16_t) (result_0 >> (1*8));
    outputs[ 7] = (int16_t) (result_0 >> (0*8));

    outputs[ 8] = (int16_t) (result_1 >> (7*8));
    outputs[ 9] = (int16_t) (result_1 >> (6*8));
    outputs[10] = (int16_t) (result_1 >> (5*8));
    outputs[11] = (int16_t) (result_1 >> (4*8));
    outputs[12] = (int16_t) (result_1 >> (3*8));
    outputs[13] = (int16_t) (result_1 >> (2*8));
    outputs[14] = (int16_t) (result_1 >> (1*8));
    outputs[15] = (int16_t) (result_1 >> (0*8));

    return true;
}

bool Compute_FDWT_DB_8(int8_t inputs[16], int16_t low[8], int16_t high[8])
{
    uint64_t result = 0;
    uint64_t dummy_rs1 = 0;
    uint64_t dummy_rs2 = 0;
    uint64_t input_u64_1;
    uint64_t input_u64_2;

    uint64_t result_low_03 = 0;
    uint64_t result_low_47 = 0;
    uint64_t result_high_03 = 0;
    uint64_t result_high_47 = 0;

    input_u64_1=0;
    input_u64_1 |= ((uint64_t)((uint8_t)inputs[0])) << (7*8);
    input_u64_1 |= ((uint64_t)((uint8_t)inputs[1])) << (6*8);
    input_u64_1 |= ((uint64_t)((uint8_t)inputs[2])) << (5*8);
    input_u64_1 |= ((uint64_t)((uint8_t)inputs[3])) << (4*8);
    input_u64_1 |= ((uint64_t)((uint8_t)inputs[4])) << (3*8);
    input_u64_1 |= ((uint64_t)((uint8_t)inputs[5])) << (2*8);
    input_u64_1 |= ((uint64_t)((uint8_t)inputs[6])) << (1*8);
    input_u64_1 |= ((uint64_t)((uint8_t)inputs[7])) << (0*8);

    input_u64_2=0;
    input_u64_2 |= ((uint64_t)((uint8_t)inputs[8]))  << (7*8);
    input_u64_2 |= ((uint64_t)((uint8_t)inputs[9]))  << (6*8);
    input_u64_2 |= ((uint64_t)((uint8_t)inputs[10])) << (5*8);
    input_u64_2 |= ((uint64_t)((uint8_t)inputs[11])) << (4*8);
    input_u64_2 |= ((uint64_t)((uint8_t)inputs[12])) << (3*8);
    input_u64_2 |= ((uint64_t)((uint8_t)inputs[13])) << (2*8);
    input_u64_2 |= ((uint64_t)((uint8_t)inputs[14])) << (1*8);
    input_u64_2 |= ((uint64_t)((uint8_t)inputs[15])) << (0*8);

    asm volatile (
		".insn r 0x7B, 0x3, 0x45, %0, %1, %2"
		: "=r" (result)
		: "r" (input_u64_1) , "r" (input_u64_2)
	  );

    if(result != 1) return false;

    asm volatile (
		".insn r 0x7B, 0x4, 0x45, %0, %1, %2"
		: "=r" (result_low_03)
		: "r" (dummy_rs1) , "r" (dummy_rs2)
	  );

    asm volatile (
		".insn r 0x7B, 0x5, 0x45, %0, %1, %2"
		: "=r" (result_low_47)
		: "r" (dummy_rs1) , "r" (dummy_rs2)
	  );

    asm volatile (
		".insn r 0x7B, 0x6, 0x45, %0, %1, %2"
		: "=r" (result_high_03)
		: "r" (dummy_rs1) , "r" (dummy_rs2)
	  );

    asm volatile (
		".insn r 0x7B, 0x7, 0x45, %0, %1, %2"
		: "=r" (result_high_47)
		: "r" (dummy_rs1) , "r" (dummy_rs2)
	  );

    low[0] = (int16_t)(result_low_03 >> (3*16));
    low[1] = (int16_t)(result_low_03 >> (2*16));
    low[2] = (int16_t)(result_low_03 >> (1*16));
    low[3] = (int16_t)(result_low_03 >> (0*16));
    low[4] = (int16_t)(result_low_47 >> (3*16));
    low[5] = (int16_t)(result_low_47 >> (2*16));
    low[6] = (int16_t)(result_low_47 >> (1*16));
    low[7] = (int16_t)(result_low_47 >> (0*16));

    high[0] = (int16_t)(result_high_03 >> (3*16));
    high[1] = (int16_t)(result_high_03 >> (2*16));
    high[2] = (int16_t)(result_high_03 >> (1*16));
    high[3] = (int16_t)(result_high_03 >> (0*16));
    high[4] = (int16_t)(result_high_47 >> (3*16));
    high[5] = (int16_t)(result_high_47 >> (2*16));
    high[6] = (int16_t)(result_high_47 >> (1*16));
    high[7] = (int16_t)(result_high_47 >> (0*16));

    return true;
}

bool Compute_IDWT_DB_8(int16_t low[8], int16_t high[8], int8_t outputs[16])
{
    uint64_t result;

    uint64_t rs1 = 0;
    uint64_t rs2 = 0;
    uint64_t rs3 = 0;
    uint64_t rs4 = 0;

    uint64_t dummy_rs1 = 0;
    uint64_t dummy_rs2 = 0;

    uint64_t result_0 = 0;
    uint64_t result_1 = 0;

    rs1=0;
    rs1 |= ((uint64_t)((uint16_t)low[0])) << (3*16);
    rs1 |= ((uint64_t)((uint16_t)low[1])) << (2*16);
    rs1 |= ((uint64_t)((uint16_t)low[2])) << (1*16);
    rs1 |= ((uint64_t)((uint16_t)low[3])) << (0*16);

    rs2=0;
    rs2 |= ((uint64_t)((uint16_t)low[4])) << (3*16);
    rs2 |= ((uint64_t)((uint16_t)low[5])) << (2*16);
    rs2 |= ((uint64_t)((uint16_t)low[6])) << (1*16);
    rs2 |= ((uint64_t)((uint16_t)low[7])) << (0*16);

    rs3=0;
    rs3 |= ((uint64_t)((uint16_t)high[0])) << (3*16);
    rs3 |= ((uint64_t)((uint16_t)high[1])) << (2*16);
    rs3 |= ((uint64_t)((uint16_t)high[2])) << (1*16);
    rs3 |= ((uint64_t)((uint16_t)high[3])) << (0*16);

    rs4=0;
    rs4 |= ((uint64_t)((uint16_t)high[4])) << (3*16);
    rs4 |= ((uint64_t)((uint16_t)high[5])) << (2*16);
    rs4 |= ((uint64_t)((uint16_t)high[6])) << (1*16);
    rs4 |= ((uint64_t)((uint16_t)high[7])) << (0*16);

    asm volatile (
		".insn r 0x7B, 0x2, 0x46, %0, %1, %2"
		: "=r" (result)
		: "r" (rs1) , "r" (rs2)
	 );

    if(result != 2) return false;

    asm volatile (
		".insn r 0x7B, 0x3, 0x46, %0, %1, %2"
		: "=r" (result)
		: "r" (rs3) , "r" (rs4)
	 );

    if(result != 3) return false;

    asm volatile (
		".insn r 0x7B, 0x4, 0x46, %0, %1, %2"
		: "=r" (result_0)
		: "r" (dummy_rs1) , "r" (dummy_rs2)
	  );

    asm volatile (
		".insn r 0x7B, 0x5, 0x46, %0, %1, %2"
		: "=r" (result_1)
		: "r" (dummy_rs1) , "r" (dummy_rs2)
	);

    outputs[ 0] = (int8_t) (result_0 >> (7*8));
    outputs[ 1] = (int8_t) (result_0 >> (6*8));
    outputs[ 2] = (int8_t) (result_0 >> (5*8));
    outputs[ 3] = (int8_t) (result_0 >> (4*8));
    outputs[ 4] = (int8_t) (result_0 >> (3*8));
    outputs[ 5] = (int8_t) (result_0 >> (2*8));
    outputs[ 6] = (int8_t) (result_0 >> (1*8));
    outputs[ 7] = (int8_t) (result_0 >> (0*8));

    outputs[ 8] = (int8_t) (result_1 >> (7*8));
    outputs[ 9] = (int8_t) (result_1 >> (6*8));
    outputs[10] = (int8_t) (result_1 >> (5*8));
    outputs[11] = (int8_t) (result_1 >> (4*8));
    outputs[12] = (int8_t) (result_1 >> (3*8));
    outputs[13] = (int8_t) (result_1 >> (2*8));
    outputs[14] = (int8_t) (result_1 >> (1*8));
    outputs[15] = (int8_t) (result_1 >> (0*8));

    return true;
}

/*uint64_t Get_Timestamp(void)
{
  uint64_t rs1 = 0, rs2 = 0, result =0;

  asm volatile (
		".insn r 0x7B, 0x0, 0x47, %0, %1, %2"
		: "=r" (result)
		: "r" (rs1) , "r" (rs2)
	 );

   return result;
}*/