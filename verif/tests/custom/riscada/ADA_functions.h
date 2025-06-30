#ifndef ADA_FUNCTIONS_H_
#define ADA_FUNCTIONS_H_

#include <stdint.h>
#include <stdbool.h>
// DA functions

bool DA_SetValue(uint8_t channel, uint16_t da);
bool DA_SetValue_Broadcast(uint16_t da);

bool DA_Load_Sequence(uint8_t channel, uint8_t len, uint16_t* vals, uint16_t* durs);
bool DA_Load_Sequence_Broadcast(uint8_t len, uint16_t* vals, uint16_t* durs);

bool DA_StartSequence(uint8_t channel);
bool DA_StartSequence_Broadcast(void);

bool DA_GetValue(uint8_t channel, uint16_t* p_val);
bool DA_GetSequencesRunning(uint64_t* p_seqs_running_mask);
bool DA_GetConfigurationsRunning(uint64_t* p_configs_running_mask);

//AD functions

bool AD_ResetStatistics(uint8_t channel);
bool AD_ResetStatistics_Broadcast(void);

bool AD_Set_Threshold_and_Hysteresis(uint8_t channel, uint16_t thr, uint16_t hys);
bool AD_Set_Threshold_and_Hysteresis_Broadcast(uint16_t thr, uint16_t hys);

bool AD_Get_All_Statistics(uint8_t channel, uint16_t* p_adc_val, uint16_t* p_otd, uint16_t* p_sma, uint16_t* p_max, uint16_t* p_min);
bool AD_Get_Threshold_and_Hysteresis(uint8_t channel, uint16_t* p_thr, uint16_t* p_hys);

bool AD_Get_ADC_Val(uint8_t channel, uint32_t* p_ts, uint16_t* p_adc_val);
bool AD_Get_OverThresholdDuration(uint8_t channel, uint32_t* p_ts, uint16_t* p_otd);
bool AD_Get_SimpleMovingAverage16(uint8_t channel, uint32_t* p_ts, uint16_t* p_sma);
bool AD_Get_Max(uint8_t channel, uint32_t* p_ts, uint16_t* p_max);
bool AD_Get_Min(uint8_t channel, uint32_t* p_ts, uint16_t* p_min);


#endif //ADA_functions.h