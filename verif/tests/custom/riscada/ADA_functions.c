#include <stdbool.h>
#include "ADA_functions.h"

//int x=0;

bool DA_SetValue(uint8_t channel, uint16_t da)
{
    uint32_t result;
    
    uint64_t rs1 = 0u;
    uint64_t rs2 = 0u;

    rs1 = ((uint64_t)((channel >> 4) & 0xF)) << 60;
    rs2 = ((uint64_t)((channel >> 0) & 0xF)) << 60;

    da = da & 0xFFF;

    rs2 |= (uint64_t)da;
    
    asm volatile (
		".insn r 0x7B, 0x0, 0x48, %0, %1, %2"
		: "=r" (result)
		: "r" (rs1) , "r" (rs2)
	);

    return true;
}

bool DA_SetValue_Broadcast(uint16_t da)
{
    uint64_t result;
    
    uint64_t rs1 = 0u;
    uint64_t rs2 = 0u;

    da = da & 0xFFF;

    rs2 |= (uint64_t)da;

    asm volatile (
		".insn r 0x7B, 0x4, 0x48, %0, %1, %2"
		: "=r" (result)
		: "r" (rs1) , "r" (rs2)
	);

    return true;
}

bool DA_Load_Sequence(uint8_t channel, uint8_t len, uint16_t* vals, uint16_t* durs)
{
    uint64_t result;

    uint64_t rs1 = 0u;
    uint64_t rs2 = 0u;

    //Setting sequence length
    if(len == 0 || len > 10)
    {
        return false;
    }

    rs1 = ((uint64_t)((channel >> 4) & 0xF)) << 60;
    rs2 = ((uint64_t)((channel >> 0) & 0xF)) << 60;

    rs2 |= (uint64_t)len;

    asm volatile (
		".insn r 0x7B, 0x0, 0x49, %0, %1, %2"
		: "=r" (result)
		: "r" (rs1) , "r" (rs2)
	);

    //Setting vals
    rs1 = 0u;
    rs2 = 0u;

    rs1 = ((uint64_t)((channel >> 4) & 0xF)) << 60;
    rs2 = ((uint64_t)((channel >> 0) & 0xF)) << 60;

    rs1 |= ((((uint64_t) vals[0]) & 0xFFF) << (4 * 12));
    rs1 |= ((((uint64_t) vals[1]) & 0xFFF) << (3 * 12));
    rs1 |= ((((uint64_t) vals[2]) & 0xFFF) << (2 * 12));
    rs1 |= ((((uint64_t) vals[3]) & 0xFFF) << (1 * 12));
    rs1 |= ((((uint64_t) vals[4]) & 0xFFF) << (0 * 12));

    rs2 |= ((((uint64_t) vals[5]) & 0xFFF) << (4 * 12));
    rs2 |= ((((uint64_t) vals[6]) & 0xFFF) << (3 * 12));
    rs2 |= ((((uint64_t) vals[7]) & 0xFFF) << (2 * 12));
    rs2 |= ((((uint64_t) vals[8]) & 0xFFF) << (1 * 12));
    rs2 |= ((((uint64_t) vals[9]) & 0xFFF) << (0 * 12));

    asm volatile (
		".insn r 0x7B, 0x0, 0x4A, %0, %1, %2"
		: "=r" (result)
		: "r" (rs1) , "r" (rs2)
	);

    //Setting durs
    rs1 = 0u;
    rs2 = 0u;

    rs1 = ((uint64_t)((channel >> 4) & 0xF)) << 60;
    rs2 = ((uint64_t)((channel >> 0) & 0xF)) << 60;

    rs1 |= ((((uint64_t) durs[0]) & 0xFFF) << (4 * 12));
    rs1 |= ((((uint64_t) durs[1]) & 0xFFF) << (3 * 12));
    rs1 |= ((((uint64_t) durs[2]) & 0xFFF) << (2 * 12));
    rs1 |= ((((uint64_t) durs[3]) & 0xFFF) << (1 * 12));
    rs1 |= ((((uint64_t) durs[4]) & 0xFFF) << (0 * 12));

    rs2 |= ((((uint64_t) durs[5]) & 0xFFF) << (4 * 12));
    rs2 |= ((((uint64_t) durs[6]) & 0xFFF) << (3 * 12));
    rs2 |= ((((uint64_t) durs[7]) & 0xFFF) << (2 * 12));
    rs2 |= ((((uint64_t) durs[8]) & 0xFFF) << (1 * 12));
    rs2 |= ((((uint64_t) durs[9]) & 0xFFF) << (0 * 12));

    asm volatile (
		".insn r 0x7B, 0x0, 0x4B, %0, %1, %2"
		: "=r" (result)
		: "r" (rs1) , "r" (rs2)
	);

    return true;
}

bool DA_Load_Sequence_Broadcast(uint8_t len, uint16_t* vals, uint16_t* durs)
{
    uint64_t result;

    uint64_t rs1 = 0u;
    uint64_t rs2 = 0u;

    //Setting sequence length
    if(len == 0 || len > 10)
    {
        return false;
    }

    rs2 |= (uint64_t)len;

    asm volatile (
		".insn r 0x7B, 0x4, 0x49, %0, %1, %2"
		: "=r" (result)
		: "r" (rs1) , "r" (rs2)
	);

    //Setting vals
    rs1 = 0u;
    rs2 = 0u;

    rs1 |= ((((uint64_t) vals[0]) & 0xFFF) << (4 * 12));
    rs1 |= ((((uint64_t) vals[1]) & 0xFFF) << (3 * 12));
    rs1 |= ((((uint64_t) vals[2]) & 0xFFF) << (2 * 12));
    rs1 |= ((((uint64_t) vals[3]) & 0xFFF) << (1 * 12));
    rs1 |= ((((uint64_t) vals[4]) & 0xFFF) << (0 * 12));

    rs2 |= ((((uint64_t) vals[5]) & 0xFFF) << (4 * 12));
    rs2 |= ((((uint64_t) vals[6]) & 0xFFF) << (3 * 12));
    rs2 |= ((((uint64_t) vals[7]) & 0xFFF) << (2 * 12));
    rs2 |= ((((uint64_t) vals[8]) & 0xFFF) << (1 * 12));
    rs2 |= ((((uint64_t) vals[9]) & 0xFFF) << (0 * 12));

    asm volatile (
		".insn r 0x7B, 0x4, 0x4A, %0, %1, %2"
		: "=r" (result)
		: "r" (rs1) , "r" (rs2)
	);

    //Setting durs
    rs1 = 0u;
    rs2 = 0u;

    rs1 |= ((((uint64_t) durs[0]) & 0xFFF) << (4 * 12));
    rs1 |= ((((uint64_t) durs[1]) & 0xFFF) << (3 * 12));
    rs1 |= ((((uint64_t) durs[2]) & 0xFFF) << (2 * 12));
    rs1 |= ((((uint64_t) durs[3]) & 0xFFF) << (1 * 12));
    rs1 |= ((((uint64_t) durs[4]) & 0xFFF) << (0 * 12));

    rs2 |= ((((uint64_t) durs[5]) & 0xFFF) << (4 * 12));
    rs2 |= ((((uint64_t) durs[6]) & 0xFFF) << (3 * 12));
    rs2 |= ((((uint64_t) durs[7]) & 0xFFF) << (2 * 12));
    rs2 |= ((((uint64_t) durs[8]) & 0xFFF) << (1 * 12));
    rs2 |= ((((uint64_t) durs[9]) & 0xFFF) << (0 * 12));

    asm volatile (
		".insn r 0x7B, 0x4, 0x4B, %0, %1, %2"
		: "=r" (result)
		: "r" (rs1) , "r" (rs2)
	);

    return true;
}

bool DA_StartSequence(uint8_t channel)
{
    uint64_t result;
    
    uint64_t rs1 = 0u;
    uint64_t rs2 = 0u;

    rs1 = ((uint64_t)((channel >> 4) & 0xF)) << 60;
    rs2 = ((uint64_t)((channel >> 0) & 0xF)) << 60;

    asm volatile (
		".insn r 0x7B, 0x0, 0x4C, %0, %1, %2"
		: "=r" (result)
		: "r" (rs1) , "r" (rs2)
	);

    return true;
}

bool DA_StartSequence_Broadcast(void)
{
    uint64_t result;
    
    uint64_t rs1 = 0u;
    uint64_t rs2 = 0u;

    asm volatile (
		".insn r 0x7B, 0x4, 0x4C, %0, %1, %2"
		: "=r" (result)
		: "r" (rs1) , "r" (rs2)
	);

    return true;
}

bool DA_GetValue(uint8_t channel, uint16_t* p_val)
{
    uint64_t result;
    
    uint64_t rs1 = 0u;
    uint64_t rs2 = 0u;

    rs1 = ((uint64_t)((channel >> 4) & 0xF)) << 60;
    rs2 = ((uint64_t)((channel >> 0) & 0xF)) << 60;

    asm volatile (
		".insn r 0x7B, 0x0, 0x68, %0, %1, %2"
		: "=r" (result)
		: "r" (rs1) , "r" (rs2)
	);

    *p_val = (uint16_t)(result & 0xFFF);

    return true;
}

bool DA_GetSequencesRunning(uint64_t* p_seqs_running_mask)
{
    uint64_t result;
    
    uint64_t rs1 = 0u;
    uint64_t rs2 = 0u;

    asm volatile (
		".insn r 0x7B, 0x0, 0x69, %0, %1, %2"
		: "=r" (result)
		: "r" (rs1) , "r" (rs2)
	);

    *p_seqs_running_mask = result;

    return true;
}

bool DA_GetConfigurationsRunning(uint64_t* p_configs_running_mask)
{
    uint64_t result;
    
    uint64_t rs1 = 0u;
    uint64_t rs2 = 0u;

    asm volatile (
		".insn r 0x7B, 0x0, 0x6A, %0, %1, %2"
		: "=r" (result)
		: "r" (rs1) , "r" (rs2)
	);

    *p_configs_running_mask = result;

    return true;
}

//***********************************************************************

bool AD_ResetStatistics(uint8_t channel)
{
    uint64_t result;
    
    uint64_t rs1 = 0u;
    uint64_t rs2 = 0u;

    rs1 = ((uint64_t)((channel >> 4) & 0xF)) << 60;
    rs2 = ((uint64_t)((channel >> 0) & 0xF)) << 60;

    asm volatile (
		".insn r 0x7B, 0x0, 0x58, %0, %1, %2"
		: "=r" (result)
		: "r" (rs1) , "r" (rs2)
	);

    return true;
}

bool AD_ResetStatistics_Broadcast()
{
    uint64_t result;
    
    uint64_t rs1 = 0u;
    uint64_t rs2 = 0u;

    asm volatile (
		".insn r 0x7B, 0x4, 0x58, %0, %1, %2"
		: "=r" (result)
		: "r" (rs1) , "r" (rs2)
	);

    return true;
}

bool AD_Set_Threshold_and_Hysteresis(uint8_t channel, uint16_t thr, uint16_t hys)
{
    uint64_t result;
    
    uint64_t rs1 = 0u;
    uint64_t rs2 = 0u;

    rs1 = ((uint64_t)((channel >> 4) & 0xF)) << 60;
    rs2 = ((uint64_t)((channel >> 0) & 0xF)) << 60;

    thr &= 0xFFF;
    hys &= 0xFFF;

    rs1 |= (uint64_t)thr;
    rs2 |= (uint64_t)hys;

    asm volatile (
		".insn r 0x7B, 0x0, 0x59, %0, %1, %2"
		: "=r" (result)
		: "r" (rs1) , "r" (rs2)
	);

    return true;
}

bool AD_Set_Threshold_and_Hysteresis_Broadcast(uint16_t thr, uint16_t hys)
{
    uint64_t result;
    
    uint64_t rs1 = 0u;
    uint64_t rs2 = 0u;

    thr &= 0xFFF;
    hys &= 0xFFF;

    rs1 |= (uint64_t)thr;
    rs2 |= (uint64_t)hys;

    asm volatile (
		".insn r 0x7B, 0x4, 0x59, %0, %1, %2"
		: "=r" (result)
		: "r" (rs1) , "r" (rs2)
	);

    return true;
}

bool AD_Get_All_Statistics(uint8_t channel, uint16_t* p_adc_val, uint16_t* p_otd, uint16_t* p_sma, uint16_t* p_max, uint16_t* p_min)
{
    uint64_t result;

    uint64_t rs1 = 0u;
    uint64_t rs2 = 0u;

    rs1 = ((uint64_t)((channel >> 4) & 0xF)) << 60;
    rs2 = ((uint64_t)((channel >> 0) & 0xF)) << 60;

    asm volatile (
		".insn r 0x7B, 0x0, 0x78, %0, %1, %2"
		: "=r" (result)
		: "r" (rs1) , "r" (rs2)
	);

    *p_adc_val = (uint16_t)((result >> (0 * 12)) & 0xFFF);
    *p_otd     = (uint16_t)((result >> (1 * 12)) & 0xFFF);
    *p_sma     = (uint16_t)((result >> (2 * 12)) & 0xFFF);
    *p_max     = (uint16_t)((result >> (3 * 12)) & 0xFFF);
    *p_min     = (uint16_t)((result >> (4 * 12)) & 0xFFF);

    return true;
}

bool AD_Get_Threshold_and_Hysteresis(uint8_t channel, uint16_t* p_thr, uint16_t* p_hys)
{
    uint64_t result;

    uint64_t rs1 = 0u;
    uint64_t rs2 = 0u;

    rs1 = ((uint64_t)((channel >> 4) & 0xF)) << 60;
    rs2 = ((uint64_t)((channel >> 0) & 0xF)) << 60;

    asm volatile (
		".insn r 0x7B, 0x0, 0x79, %0, %1, %2"
		: "=r" (result)
		: "r" (rs1) , "r" (rs2)
	);

    *p_hys     = (uint16_t)((result >> (0 * 12)) & 0xFFF);
    *p_thr     = (uint16_t)((result >> (1 * 12)) & 0xFFF);

    return true;
}

bool AD_Get_ADC_Val(uint8_t channel, uint32_t* p_ts, uint16_t* p_adc_val)
{
    uint64_t result;

    uint64_t rs1 = 0u;
    uint64_t rs2 = 0u;

    rs1 = ((uint64_t)((channel >> 4) & 0xF)) << 60;
    rs2 = ((uint64_t)((channel >> 0) & 0xF)) << 60;

    asm volatile (
		".insn r 0x7B, 0x0, 0x7B, %0, %1, %2"
		: "=r" (result)
		: "r" (rs1) , "r" (rs2)
	);

    *p_ts      = (uint32_t)(result >> 32);
    *p_adc_val = (uint16_t)(result & 0xFFF);

    return true;
}

bool AD_Get_OverThresholdDuration(uint8_t channel, uint32_t* p_ts, uint16_t* p_otd)
{
    uint64_t result;

    uint64_t rs1 = 0u;
    uint64_t rs2 = 0u;

    rs1 = ((uint64_t)((channel >> 4) & 0xF)) << 60;
    rs2 = ((uint64_t)((channel >> 0) & 0xF)) << 60;

    asm volatile (
		".insn r 0x7B, 0x0, 0x7C, %0, %1, %2"
		: "=r" (result)
		: "r" (rs1) , "r" (rs2)
	);

    *p_ts      = (uint32_t)(result >> 32);
    *p_otd     = (uint16_t)(result & 0xFFF);

    return true;
}

bool AD_Get_SimpleMovingAverage16(uint8_t channel, uint32_t* p_ts, uint16_t* p_sma)
{
    uint64_t result;

    uint64_t rs1 = 0u;
    uint64_t rs2 = 0u;

    rs1 = ((uint64_t)((channel >> 4) & 0xF)) << 60;
    rs2 = ((uint64_t)((channel >> 0) & 0xF)) << 60;

    asm volatile (
		".insn r 0x7B, 0x0, 0x7D, %0, %1, %2"
		: "=r" (result)
		: "r" (rs1) , "r" (rs2)
	);

    *p_ts      = (uint32_t)(result >> 32);
    *p_sma     = (uint16_t)(result & 0xFFF);

    return true;
}

bool AD_Get_Min(uint8_t channel, uint32_t* p_ts, uint16_t* p_min)
{
    uint64_t result;

    uint64_t rs1 = 0u;
    uint64_t rs2 = 0u;

    rs1 = ((uint64_t)((channel >> 4) & 0xF)) << 60;
    rs2 = ((uint64_t)((channel >> 0) & 0xF)) << 60;

    asm volatile (
		".insn r 0x7B, 0x0, 0x7E, %0, %1, %2"
		: "=r" (result)
		: "r" (rs1) , "r" (rs2)
	);

    *p_ts      = (uint32_t)(result >> 32);
    *p_min     = (uint16_t)(result & 0xFFF);

    return true;
}

bool AD_Get_Max(uint8_t channel, uint32_t* p_ts, uint16_t* p_max)
{
    uint64_t result;

    uint64_t rs1 = 0u;
    uint64_t rs2 = 0u;

    rs1 = ((uint64_t)((channel >> 4) & 0xF)) << 60;
    rs2 = ((uint64_t)((channel >> 0) & 0xF)) << 60;

    asm volatile (
		".insn r 0x7B, 0x0, 0x7E, %0, %1, %2"
		: "=r" (result)
		: "r" (rs1) , "r" (rs2)
	);

    *p_ts      = (uint32_t)(result >> 32);
    *p_max     = (uint16_t)(result & 0xFFF);

    return true;
}



