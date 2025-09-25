# 1 "../c_sources/dwt_idwt_cdf_5_3.c"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 339 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "/tools/Xilinx/Vitis/2024.2/common/technology/autopilot/etc/autopilot_ssdm_op.h" 1
# 263 "/tools/Xilinx/Vitis/2024.2/common/technology/autopilot/etc/autopilot_ssdm_op.h"
    void _ssdm_op_IfRead() __attribute__ ((nothrow));
    void _ssdm_op_IfWrite() __attribute__ ((nothrow));
    unsigned int __attribute__ ((bitwidth(1))) _ssdm_op_IfNbRead() __attribute__ ((nothrow));
    unsigned int __attribute__ ((bitwidth(1))) _ssdm_op_IfNbWrite() __attribute__ ((nothrow));
    unsigned int __attribute__ ((bitwidth(1))) _ssdm_op_IfCanRead() __attribute__ ((nothrow));
    unsigned int __attribute__ ((bitwidth(1))) _ssdm_op_IfCanWrite() __attribute__ ((nothrow));


    void _ssdm_StreamRead() __attribute__ ((nothrow));
    void _ssdm_StreamWrite() __attribute__ ((nothrow));
    unsigned int __attribute__ ((bitwidth(1))) _ssdm_StreamNbRead() __attribute__ ((nothrow));
    unsigned int __attribute__ ((bitwidth(1))) _ssdm_StreamNbWrite() __attribute__ ((nothrow));
    unsigned int __attribute__ ((bitwidth(1))) _ssdm_StreamCanRead() __attribute__ ((nothrow));
    unsigned int __attribute__ ((bitwidth(1))) _ssdm_StreamCanWrite() __attribute__ ((nothrow));
    void _ssdm_op_ReadReq() __attribute__ ((nothrow));
    void _ssdm_op_Read() __attribute__ ((nothrow));
    void _ssdm_op_WriteReq() __attribute__ ((nothrow));
    void _ssdm_op_Write() __attribute__ ((nothrow));
    unsigned int __attribute__ ((bitwidth(1))) _ssdm_op_NbReadReq() __attribute__ ((nothrow));
    unsigned int __attribute__ ((bitwidth(1))) _ssdm_op_CanReadReq() __attribute__ ((nothrow));
    unsigned int __attribute__ ((bitwidth(1))) _ssdm_op_NbWriteReq() __attribute__ ((nothrow));
    unsigned int __attribute__ ((bitwidth(1))) _ssdm_op_CanWriteReq() __attribute__ ((nothrow));




    void _ssdm_op_MemShiftRead() __attribute__ ((nothrow));

    void _ssdm_op_PrintNone() __attribute__ ((nothrow));
    void _ssdm_op_PrintInt() __attribute__ ((nothrow));
    void _ssdm_op_PrintDouble() __attribute__ ((nothrow));

    void _ssdm_op_Wait(int) __attribute__ ((nothrow));
    void _ssdm_op_Poll() __attribute__ ((nothrow));

    void _ssdm_op_Return() __attribute__ ((nothrow));


    void _ssdm_op_SpecSynModule() __attribute__ ((nothrow));
    void _ssdm_op_SpecTopModule() __attribute__ ((nothrow));
    void _ssdm_op_SpecProcessDecl() __attribute__ ((nothrow));
    void _ssdm_op_SpecProcessDef() __attribute__ ((nothrow));
    void _ssdm_op_SpecPort() __attribute__ ((nothrow));
    void _ssdm_op_SpecConnection() __attribute__ ((nothrow));
    void _ssdm_op_SpecChannel() __attribute__ ((nothrow));
    void _ssdm_op_SpecSensitive() __attribute__ ((nothrow));
    void _ssdm_op_SpecModuleInst() __attribute__ ((nothrow));
    void _ssdm_op_SpecPortMap() __attribute__ ((nothrow));

    void _ssdm_op_SpecReset() __attribute__ ((nothrow));

    void _ssdm_op_SpecPlatform() __attribute__ ((nothrow));
    void _ssdm_op_SpecClockDomain() __attribute__ ((nothrow));
    void _ssdm_op_SpecPowerDomain() __attribute__ ((nothrow));

    int _ssdm_op_SpecRegionBegin() __attribute__ ((nothrow));
    int _ssdm_op_SpecRegionEnd() __attribute__ ((nothrow));

    void _ssdm_op_SpecLoopName() __attribute__ ((nothrow));

    void _ssdm_op_SpecLoopTripCount() __attribute__ ((nothrow));

    int _ssdm_op_SpecStateBegin() __attribute__ ((nothrow));
    int _ssdm_op_SpecStateEnd() __attribute__ ((nothrow));

    void _ssdm_op_SpecInterface() __attribute__ ((nothrow));

    void _ssdm_op_SpecPipeline() __attribute__ ((nothrow));
    void _ssdm_op_SpecDataflowPipeline() __attribute__ ((nothrow));


    void _ssdm_op_SpecLatency() __attribute__ ((nothrow));
    void _ssdm_op_SpecParallel() __attribute__ ((nothrow));
    void _ssdm_op_SpecProtocol() __attribute__ ((nothrow));
    void _ssdm_op_SpecOccurrence() __attribute__ ((nothrow));

    void _ssdm_op_SpecResource() __attribute__ ((nothrow));
    void _ssdm_op_SpecResourceLimit() __attribute__ ((nothrow));
    void _ssdm_op_SpecCHCore() __attribute__ ((nothrow));
    void _ssdm_op_SpecFUCore() __attribute__ ((nothrow));
    void _ssdm_op_SpecIFCore() __attribute__ ((nothrow));
    void _ssdm_op_SpecIPCore() __attribute__ ((nothrow));
    void _ssdm_op_SpecMemCore() __attribute__ ((nothrow));

    void _ssdm_op_SpecExt() __attribute__ ((nothrow));




    void _ssdm_SpecArrayDimSize() __attribute__ ((nothrow));

    void _ssdm_RegionBegin() __attribute__ ((nothrow));
    void _ssdm_RegionEnd() __attribute__ ((nothrow));

    void _ssdm_InlineAll() __attribute__ ((nothrow));
    void _ssdm_InlineLoop() __attribute__ ((nothrow));
    void _ssdm_Inline() __attribute__ ((nothrow));
    void _ssdm_InlineSelf() __attribute__ ((nothrow));
    void _ssdm_InlineRegion() __attribute__ ((nothrow));

    void _ssdm_SpecArrayMap() __attribute__ ((nothrow));
    void _ssdm_SpecArrayPartition() __attribute__ ((nothrow));
    void _ssdm_SpecArrayReshape() __attribute__ ((nothrow));

    void _ssdm_SpecStream() __attribute__ ((nothrow));

    void _ssdm_op_SpecStable() __attribute__ ((nothrow));
    void _ssdm_op_SpecStableContent() __attribute__ ((nothrow));

    void _ssdm_op_SpecBindPort() __attribute__ ((nothrow));

    void _ssdm_op_SpecPipoDepth() __attribute__ ((nothrow));

    void _ssdm_SpecExpr() __attribute__ ((nothrow));
    void _ssdm_SpecExprBalance() __attribute__ ((nothrow));

    void _ssdm_SpecDependence() __attribute__ ((nothrow));

    void _ssdm_SpecLoopMerge() __attribute__ ((nothrow));
    void _ssdm_SpecLoopFlatten() __attribute__ ((nothrow));
    void _ssdm_SpecLoopRewind() __attribute__ ((nothrow));

    void _ssdm_SpecFuncInstantiation() __attribute__ ((nothrow));
    void _ssdm_SpecFuncBuffer() __attribute__ ((nothrow));
    void _ssdm_SpecFuncExtract() __attribute__ ((nothrow));
    void _ssdm_SpecConstant() __attribute__ ((nothrow));

    void _ssdm_DataPack() __attribute__ ((nothrow));
    void _ssdm_SpecDataPack() __attribute__ ((nothrow));

    void _ssdm_op_SpecBitsMap() __attribute__ ((nothrow));
    void _ssdm_op_SpecLicense() __attribute__ ((nothrow));
# 2 "<built-in>" 2
# 1 "../c_sources/dwt_idwt_cdf_5_3.c" 2
# 1 "/tools/Xilinx/Vitis/2024.2/lnx64/tools/clang-3.9-csynth/lib/clang/7.0.0/include/stdint.h" 1 3
# 63 "/tools/Xilinx/Vitis/2024.2/lnx64/tools/clang-3.9-csynth/lib/clang/7.0.0/include/stdint.h" 3
# 1 "/usr/include/stdint.h" 1 3 4
# 26 "/usr/include/stdint.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/libc-header-start.h" 1 3 4
# 33 "/usr/include/x86_64-linux-gnu/bits/libc-header-start.h" 3 4
# 1 "/usr/include/features.h" 1 3 4
# 392 "/usr/include/features.h" 3 4
# 1 "/usr/include/features-time64.h" 1 3 4
# 20 "/usr/include/features-time64.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/wordsize.h" 1 3 4
# 21 "/usr/include/features-time64.h" 2 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/timesize.h" 1 3 4
# 19 "/usr/include/x86_64-linux-gnu/bits/timesize.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/wordsize.h" 1 3 4
# 20 "/usr/include/x86_64-linux-gnu/bits/timesize.h" 2 3 4
# 22 "/usr/include/features-time64.h" 2 3 4
# 393 "/usr/include/features.h" 2 3 4
# 464 "/usr/include/features.h" 3 4
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 465 "/usr/include/features.h" 2 3 4
# 486 "/usr/include/features.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/sys/cdefs.h" 1 3 4
# 559 "/usr/include/x86_64-linux-gnu/sys/cdefs.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/wordsize.h" 1 3 4
# 560 "/usr/include/x86_64-linux-gnu/sys/cdefs.h" 2 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/long-double.h" 1 3 4
# 561 "/usr/include/x86_64-linux-gnu/sys/cdefs.h" 2 3 4
# 487 "/usr/include/features.h" 2 3 4
# 510 "/usr/include/features.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/gnu/stubs.h" 1 3 4
# 10 "/usr/include/x86_64-linux-gnu/gnu/stubs.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/gnu/stubs-64.h" 1 3 4
# 11 "/usr/include/x86_64-linux-gnu/gnu/stubs.h" 2 3 4
# 511 "/usr/include/features.h" 2 3 4
# 34 "/usr/include/x86_64-linux-gnu/bits/libc-header-start.h" 2 3 4
# 27 "/usr/include/stdint.h" 2 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/types.h" 1 3 4
# 27 "/usr/include/x86_64-linux-gnu/bits/types.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/wordsize.h" 1 3 4
# 28 "/usr/include/x86_64-linux-gnu/bits/types.h" 2 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/timesize.h" 1 3 4
# 19 "/usr/include/x86_64-linux-gnu/bits/timesize.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/wordsize.h" 1 3 4
# 20 "/usr/include/x86_64-linux-gnu/bits/timesize.h" 2 3 4
# 29 "/usr/include/x86_64-linux-gnu/bits/types.h" 2 3 4


typedef unsigned char __u_char;
typedef unsigned short int __u_short;
typedef unsigned int __u_int;
typedef unsigned long int __u_long;


typedef signed char __int8_t;
typedef unsigned char __uint8_t;
typedef signed short int __int16_t;
typedef unsigned short int __uint16_t;
typedef signed int __int32_t;
typedef unsigned int __uint32_t;

typedef signed long int __int64_t;
typedef unsigned long int __uint64_t;






typedef __int8_t __int_least8_t;
typedef __uint8_t __uint_least8_t;
typedef __int16_t __int_least16_t;
typedef __uint16_t __uint_least16_t;
typedef __int32_t __int_least32_t;
typedef __uint32_t __uint_least32_t;
typedef __int64_t __int_least64_t;
typedef __uint64_t __uint_least64_t;



typedef long int __quad_t;
typedef unsigned long int __u_quad_t;







typedef long int __intmax_t;
typedef unsigned long int __uintmax_t;
# 141 "/usr/include/x86_64-linux-gnu/bits/types.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/typesizes.h" 1 3 4
# 142 "/usr/include/x86_64-linux-gnu/bits/types.h" 2 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/time64.h" 1 3 4
# 143 "/usr/include/x86_64-linux-gnu/bits/types.h" 2 3 4


typedef unsigned long int __dev_t;
typedef unsigned int __uid_t;
typedef unsigned int __gid_t;
typedef unsigned long int __ino_t;
typedef unsigned long int __ino64_t;
typedef unsigned int __mode_t;
typedef unsigned long int __nlink_t;
typedef long int __off_t;
typedef long int __off64_t;
typedef int __pid_t;
typedef struct { int __val[2]; } __fsid_t;
typedef long int __clock_t;
typedef unsigned long int __rlim_t;
typedef unsigned long int __rlim64_t;
typedef unsigned int __id_t;
typedef long int __time_t;
typedef unsigned int __useconds_t;
typedef long int __suseconds_t;
typedef long int __suseconds64_t;

typedef int __daddr_t;
typedef int __key_t;


typedef int __clockid_t;


typedef void * __timer_t;


typedef long int __blksize_t;




typedef long int __blkcnt_t;
typedef long int __blkcnt64_t;


typedef unsigned long int __fsblkcnt_t;
typedef unsigned long int __fsblkcnt64_t;


typedef unsigned long int __fsfilcnt_t;
typedef unsigned long int __fsfilcnt64_t;


typedef long int __fsword_t;

typedef long int __ssize_t;


typedef long int __syscall_slong_t;

typedef unsigned long int __syscall_ulong_t;



typedef __off64_t __loff_t;
typedef char *__caddr_t;


typedef long int __intptr_t;


typedef unsigned int __socklen_t;




typedef int __sig_atomic_t;
# 28 "/usr/include/stdint.h" 2 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/wchar.h" 1 3 4
# 29 "/usr/include/stdint.h" 2 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/wordsize.h" 1 3 4
# 30 "/usr/include/stdint.h" 2 3 4




# 1 "/usr/include/x86_64-linux-gnu/bits/stdint-intn.h" 1 3 4
# 24 "/usr/include/x86_64-linux-gnu/bits/stdint-intn.h" 3 4
typedef __int8_t int8_t;
typedef __int16_t int16_t;
typedef __int32_t int32_t;
typedef __int64_t int64_t;
# 35 "/usr/include/stdint.h" 2 3 4


# 1 "/usr/include/x86_64-linux-gnu/bits/stdint-uintn.h" 1 3 4
# 24 "/usr/include/x86_64-linux-gnu/bits/stdint-uintn.h" 3 4
typedef __uint8_t uint8_t;
typedef __uint16_t uint16_t;
typedef __uint32_t uint32_t;
typedef __uint64_t uint64_t;
# 38 "/usr/include/stdint.h" 2 3 4





typedef __int_least8_t int_least8_t;
typedef __int_least16_t int_least16_t;
typedef __int_least32_t int_least32_t;
typedef __int_least64_t int_least64_t;


typedef __uint_least8_t uint_least8_t;
typedef __uint_least16_t uint_least16_t;
typedef __uint_least32_t uint_least32_t;
typedef __uint_least64_t uint_least64_t;





typedef signed char int_fast8_t;

typedef long int int_fast16_t;
typedef long int int_fast32_t;
typedef long int int_fast64_t;
# 71 "/usr/include/stdint.h" 3 4
typedef unsigned char uint_fast8_t;

typedef unsigned long int uint_fast16_t;
typedef unsigned long int uint_fast32_t;
typedef unsigned long int uint_fast64_t;
# 87 "/usr/include/stdint.h" 3 4
typedef long int intptr_t;


typedef unsigned long int uintptr_t;
# 101 "/usr/include/stdint.h" 3 4
typedef __intmax_t intmax_t;
typedef __uintmax_t uintmax_t;
# 64 "/tools/Xilinx/Vitis/2024.2/lnx64/tools/clang-3.9-csynth/lib/clang/7.0.0/include/stdint.h" 2 3
# 2 "../c_sources/dwt_idwt_cdf_5_3.c" 2
# 1 "../c_sources/dwt_idwt_cdf_5_3.h" 1




void SW_dwt53_forward(int8_t in[16], int16_t low[8], int16_t high[8]);
void SW_dwt53_inverse(int16_t low[8], int16_t high[8], int8_t out[16]);


void HW_dwt53_forward_core(int8_t in[16], int16_t low[8], int16_t high[8]);
void HW_dwt53_inverse_core(int16_t low[8], int16_t high[8], int8_t out[16]);


__attribute__((sdx_kernel("HW_dwt53_forward", 0))) void HW_dwt53_forward(uint64_t op1, uint64_t op2, uint64_t* p_low_03, uint64_t* p_low_47, uint64_t* p_high_03, uint64_t* p_high_47);
void HW_dwt53_inverse(uint64_t low_03, uint64_t low_47, uint64_t high_03, uint64_t high_47, uint64_t* p_out_0, uint64_t* p_out_1);
# 3 "../c_sources/dwt_idwt_cdf_5_3.c" 2
# 1 "../c_sources/structs.h" 1





typedef union _I8U8
{
    int8_t ival8;
    uint8_t uval8;
} I8U8;

typedef union _I16U16
{
 int16_t ival16;
 uint16_t uval16;
} I16U16;
# 4 "../c_sources/dwt_idwt_cdf_5_3.c" 2




static inline int8_t clamp_i8(int32_t x){
    if (x > 127) return 127;
    if (x < -128) return -128;
    return (int8_t)x;
}

void SW_dwt53_forward(int8_t in[16], int16_t low[8], int16_t high[8])
{
    int32_t s[(16/2)], d[(16/2)];

    VITIS_LOOP_18_1: for (int i = 0; i < (16/2); i++)
    {
        s[i] = (int32_t)in[2*i];
        d[i] = (int32_t)in[2*i + 1];
    }

    VITIS_LOOP_24_2: for (int i = 0; i < (16/2); i++)
    {
        int next = (i + 1) % (16/2);
        d[i] -= (s[i] + s[next]) >> 1;
    }

    VITIS_LOOP_30_3: for (int i = 0; i < (16/2); i++)
    {
        int prev = (i - 1 + (16/2)) % (16/2);
        s[i] += (d[prev] + d[i] + 2) >> 2;
    }

    VITIS_LOOP_36_4: for (int i = 0; i < (16/2); i++) {
        low[i] = (int16_t)s[i];
        high[i] = (int16_t)d[i];
    }
}

void HW_dwt53_forward_core(int8_t in[16], int16_t low[8], int16_t high[8])
{
    int32_t s[8];
    int32_t d[8];

    s[0] = (int32_t)in[ 0];
    s[1] = (int32_t)in[ 2];
    s[2] = (int32_t)in[ 4];
    s[3] = (int32_t)in[ 6];
    s[4] = (int32_t)in[ 8];
    s[5] = (int32_t)in[10];
    s[6] = (int32_t)in[12];
    s[7] = (int32_t)in[14];

    d[0] = (int32_t)in[1];
    d[1] = (int32_t)in[3];
    d[2] = (int32_t)in[5];
    d[3] = (int32_t)in[7];
    d[4] = (int32_t)in[9];
    d[5] = (int32_t)in[11];
    d[6] = (int32_t)in[13];
    d[7] = (int32_t)in[15];

    d[0] -= (s[0] + s[1]) >> 1;
    d[1] -= (s[1] + s[2]) >> 1;
    d[2] -= (s[2] + s[3]) >> 1;
    d[3] -= (s[3] + s[4]) >> 1;
    d[4] -= (s[4] + s[5]) >> 1;
    d[5] -= (s[5] + s[6]) >> 1;
    d[6] -= (s[6] + s[7]) >> 1;
    d[7] -= (s[7] + s[0]) >> 1;

    s[0] += (d[0] + d[7] + 2) >> 2;
    s[1] += (d[1] + d[0] + 2) >> 2;
    s[2] += (d[2] + d[1] + 2) >> 2;
    s[3] += (d[3] + d[2] + 2) >> 2;
    s[4] += (d[4] + d[3] + 2) >> 2;
    s[5] += (d[5] + d[4] + 2) >> 2;
    s[6] += (d[6] + d[5] + 2) >> 2;
    s[7] += (d[7] + d[6] + 2) >> 2;

    low[0] = (int16_t)s[0];
    low[1] = (int16_t)s[1];
    low[2] = (int16_t)s[2];
    low[3] = (int16_t)s[3];
    low[4] = (int16_t)s[4];
    low[5] = (int16_t)s[5];
    low[6] = (int16_t)s[6];
    low[7] = (int16_t)s[7];

    high[0] = (int16_t)d[0];
    high[1] = (int16_t)d[1];
    high[2] = (int16_t)d[2];
    high[3] = (int16_t)d[3];
    high[4] = (int16_t)d[4];
    high[5] = (int16_t)d[5];
    high[6] = (int16_t)d[6];
    high[7] = (int16_t)d[7];
}


__attribute__((sdx_kernel("HW_dwt53_forward", 0))) void HW_dwt53_forward(uint64_t op1, uint64_t op2, uint64_t* p_low_03, uint64_t* p_low_47, uint64_t* p_high_03, uint64_t* p_high_47)
{
#line 1 "directive"
#pragma HLSDIRECTIVE TOP name=HW_dwt53_forward
# 104 "../c_sources/dwt_idwt_cdf_5_3.c"

#pragma HLS latency min=1
 int8_t inputs[16];

    int16_t low[8];
    int16_t high[8];

    inputs[ 0] = (int8_t)(op1 >> (7 * 8));
    inputs[ 1] = (int8_t)(op1 >> (6 * 8));
    inputs[ 2] = (int8_t)(op1 >> (5 * 8));
    inputs[ 3] = (int8_t)(op1 >> (4 * 8));
    inputs[ 4] = (int8_t)(op1 >> (3 * 8));
    inputs[ 5] = (int8_t)(op1 >> (2 * 8));
    inputs[ 6] = (int8_t)(op1 >> (1 * 8));
    inputs[ 7] = (int8_t)(op1 >> (0 * 8));

    inputs[ 8] = (uint8_t)(op2 >> (7 * 8));
    inputs[ 9] = (uint8_t)(op2 >> (6 * 8));
    inputs[10] = (uint8_t)(op2 >> (5 * 8));
    inputs[11] = (uint8_t)(op2 >> (4 * 8));
    inputs[12] = (uint8_t)(op2 >> (3 * 8));
    inputs[13] = (uint8_t)(op2 >> (2 * 8));
    inputs[14] = (uint8_t)(op2 >> (1 * 8));
    inputs[15] = (uint8_t)(op2 >> (0 * 8));

    HW_dwt53_forward_core(inputs, low, high);

    *p_low_03 = 0;

    *p_low_03 |= ((uint64_t)((uint16_t)low[0])) << (3 * 16);
    *p_low_03 |= ((uint64_t)((uint16_t)low[1])) << (2 * 16);
    *p_low_03 |= ((uint64_t)((uint16_t)low[2])) << (1 * 16);
    *p_low_03 |= ((uint64_t)((uint16_t)low[3])) << (0 * 16);

    *p_low_47 = 0;

    *p_low_47 |= ((uint64_t)((uint16_t)low[4])) << (3 * 16);
    *p_low_47 |= ((uint64_t)((uint16_t)low[5])) << (2 * 16);
    *p_low_47 |= ((uint64_t)((uint16_t)low[6])) << (1 * 16);
    *p_low_47 |= ((uint64_t)((uint16_t)low[7])) << (0 * 16);

    *p_high_03 = 0;

    *p_high_03 |= ((uint64_t)((uint16_t)high[0])) << (3 * 16);
    *p_high_03 |= ((uint64_t)((uint16_t)high[1])) << (2 * 16);
    *p_high_03 |= ((uint64_t)((uint16_t)high[2])) << (1 * 16);
    *p_high_03 |= ((uint64_t)((uint16_t)high[3])) << (0 * 16);

    *p_high_47 = 0;

    *p_high_47 |= ((uint64_t)((uint16_t)high[4])) << (3 * 16);
    *p_high_47 |= ((uint64_t)((uint16_t)high[5])) << (2 * 16);
    *p_high_47 |= ((uint64_t)((uint16_t)high[6])) << (1 * 16);
    *p_high_47 |= ((uint64_t)((uint16_t)high[7])) << (0 * 16);

}

void SW_dwt53_inverse(int16_t low[8], int16_t high[8], int8_t out[16])
{
    int32_t s[(16/2)], d[(16/2)];

    VITIS_LOOP_165_1: for (int i = 0; i < (16/2); i++)
    {
        s[i] = (int32_t)low[i];
        d[i] = (int32_t)high[i];
    }

    VITIS_LOOP_171_2: for (int i = 0; i < (16/2); i++)
    {
        int prev = (i - 1 + (16/2)) % (16/2);
        s[i] -= (d[prev] + d[i] + 2) >> 2;
    }

    VITIS_LOOP_177_3: for (int i = 0; i < (16/2); i++)
    {
        int next = (i + 1) % (16/2);
        int32_t odd = d[i] + ((s[i] + s[next]) >> 1);

        out[2*i] = clamp_i8(s[i]);
        out[2*i + 1] = clamp_i8(odd);
    }
}

void HW_dwt53_inverse_core(int16_t low[8], int16_t high[8], int8_t out[16])
{
    int32_t s[8];
    int32_t d[8];

    s[0] = (int32_t)low[0];
    s[1] = (int32_t)low[1];
    s[2] = (int32_t)low[2];
    s[3] = (int32_t)low[3];
    s[4] = (int32_t)low[4];
    s[5] = (int32_t)low[5];
    s[6] = (int32_t)low[6];
    s[7] = (int32_t)low[7];

    d[0] = (int32_t)high[0];
    d[1] = (int32_t)high[1];
    d[2] = (int32_t)high[2];
    d[3] = (int32_t)high[3];
    d[4] = (int32_t)high[4];
    d[5] = (int32_t)high[5];
    d[6] = (int32_t)high[6];
    d[7] = (int32_t)high[7];

    s[0] -= (d[0] + d[7] + 2) >> 2;
    s[1] -= (d[1] + d[0] + 2) >> 2;
    s[2] -= (d[2] + d[1] + 2) >> 2;
    s[3] -= (d[3] + d[2] + 2) >> 2;
    s[4] -= (d[4] + d[3] + 2) >> 2;
    s[5] -= (d[5] + d[4] + 2) >> 2;
    s[6] -= (d[6] + d[5] + 2) >> 2;
    s[7] -= (d[7] + d[6] + 2) >> 2;

    out[ 0] = clamp_i8(s[0]);
    out[ 2] = clamp_i8(s[1]);
    out[ 4] = clamp_i8(s[2]);
    out[ 6] = clamp_i8(s[3]);
    out[ 8] = clamp_i8(s[4]);
    out[10] = clamp_i8(s[5]);
    out[12] = clamp_i8(s[6]);
    out[14] = clamp_i8(s[7]);

    out[ 1] = clamp_i8(d[0] + ((s[0] + s[1]) >> 1));
    out[ 3] = clamp_i8(d[1] + ((s[1] + s[2]) >> 1));
    out[ 5] = clamp_i8(d[2] + ((s[2] + s[3]) >> 1));
    out[ 7] = clamp_i8(d[3] + ((s[3] + s[4]) >> 1));
    out[ 9] = clamp_i8(d[4] + ((s[4] + s[5]) >> 1));
    out[11] = clamp_i8(d[5] + ((s[5] + s[6]) >> 1));
    out[13] = clamp_i8(d[6] + ((s[6] + s[7]) >> 1));
    out[15] = clamp_i8(d[7] + ((s[7] + s[0]) >> 1));
}

void HW_dwt53_inverse(uint64_t low_03, uint64_t low_47, uint64_t high_03, uint64_t high_47, uint64_t* p_out_0, uint64_t* p_out_1)
{
#pragma HLS latency min=1

 int16_t in_low[8];
    int16_t in_high[8];

    int8_t out[16];

    in_low[0] = (int16_t)(low_03 >> (3 * 16));
    in_low[1] = (int16_t)(low_03 >> (2 * 16));
    in_low[2] = (int16_t)(low_03 >> (1 * 16));
    in_low[3] = (int16_t)(low_03 >> (0 * 16));
    in_low[4] = (int16_t)(low_47 >> (3 * 16));
    in_low[5] = (int16_t)(low_47 >> (2 * 16));
    in_low[6] = (int16_t)(low_47 >> (1 * 16));
    in_low[7] = (int16_t)(low_47 >> (0 * 16));

    in_high[0] = (int16_t)(high_03 >> (3 * 16));
    in_high[1] = (int16_t)(high_03 >> (2 * 16));
    in_high[2] = (int16_t)(high_03 >> (1 * 16));
    in_high[3] = (int16_t)(high_03 >> (0 * 16));
    in_high[4] = (int16_t)(high_47 >> (3 * 16));
    in_high[5] = (int16_t)(high_47 >> (2 * 16));
    in_high[6] = (int16_t)(high_47 >> (1 * 16));
    in_high[7] = (int16_t)(high_47 >> (0 * 16));

    HW_dwt53_inverse_core(in_low, in_high, out);

    *p_out_0 = 0;
    *p_out_0 |= ((uint64_t)((uint8_t)(out[ 0]))) << (7 * 8);
    *p_out_0 |= ((uint64_t)((uint8_t)(out[ 1]))) << (6 * 8);
    *p_out_0 |= ((uint64_t)((uint8_t)(out[ 2]))) << (5 * 8);
    *p_out_0 |= ((uint64_t)((uint8_t)(out[ 3]))) << (4 * 8);
    *p_out_0 |= ((uint64_t)((uint8_t)(out[ 4]))) << (3 * 8);
    *p_out_0 |= ((uint64_t)((uint8_t)(out[ 5]))) << (2 * 8);
    *p_out_0 |= ((uint64_t)((uint8_t)(out[ 6]))) << (1 * 8);
    *p_out_0 |= ((uint64_t)((uint8_t)(out[ 7]))) << (0 * 8);

    *p_out_1 = 0;
    *p_out_1 |= ((uint64_t)((uint8_t)(out[ 8]))) << (7 * 8);
    *p_out_1 |= ((uint64_t)((uint8_t)(out[ 9]))) << (6 * 8);
    *p_out_1 |= ((uint64_t)((uint8_t)(out[10]))) << (5 * 8);
    *p_out_1 |= ((uint64_t)((uint8_t)(out[11]))) << (4 * 8);
    *p_out_1 |= ((uint64_t)((uint8_t)(out[12]))) << (3 * 8);
    *p_out_1 |= ((uint64_t)((uint8_t)(out[13]))) << (2 * 8);
    *p_out_1 |= ((uint64_t)((uint8_t)(out[14]))) << (1 * 8);
    *p_out_1 |= ((uint64_t)((uint8_t)(out[15]))) << (0 * 8);
}
