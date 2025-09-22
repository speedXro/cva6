#include <string.h>
#include "compression.h"
#include "cdf53.h"
#include "CDF53_functions.h"


 int8_t clamp_i8(int32_t x)
 {
    if (x > 127) return 127;
    if (x < -128) return -128;
    return (int8_t)x;
 }
 int16_t clamp_i16(int32_t x)
 {
    if (x > 32767) return 32767;
    if (x < -32768) return -32768;
    return (int16_t)x;
 }

 uint32_t zigzag_encode32(int32_t v)
 {
    return (uint32_t)((v << 1) ^ (v >> 31));
 }
 int32_t zigzag_decode32(uint32_t u)
 {
    return (int32_t)((u >> 1) ^ (-(int32_t)(u & 1)));
 }

 uint8_t* varbyte_write_u32(uint8_t *dst, uint32_t v)
 {
    while (v > 0x7Fu)
    {
        *dst++ = (uint8_t)((v & 0x7Fu) | 0x80u);
        v >>= 7;
    }
    *dst++ = (uint8_t)(v & 0x7Fu);
    return dst;
 }
 uint8_t* varbyte_read_u32(uint8_t *src, uint8_t *end, uint32_t *out)
 {
    uint32_t v = 0; int shift = 0;
    while (src < end)
    {
        uint8_t b = *src++;
        v |= (uint32_t)(b & 0x7Fu) << shift;
        if ((b & 0x80u) == 0){ *out = v; return src; }
        shift += 7;
        if (shift > 28) break;
    }
    return NULL; 
}

 size_t SW_encode_block_53_varbyte(int8_t in[BLK], uint8_t *out, size_t out_cap)
 {
    if (out_cap < 3) return 0;
    uint8_t *dst = out;
    *dst++ = HDR0; *dst++ = HDR1; *dst++ = VER;

    int16_t low[HALFF], high[HALFF];
    SW_dwt53_forward(in, low, high);

    for (int i = 0; i < HALFF; i++)
    {
        uint32_t z = zigzag_encode32(low[i]);
        dst = varbyte_write_u32(dst, z);
    }
    for (int i = 0; i < HALFF; i++)
    {
        uint32_t z = zigzag_encode32(high[i]);
        dst = varbyte_write_u32(dst, z);
    }
    return (size_t)(dst - out);
 }

 size_t SW_decode_block_53_varbyte(uint8_t *in, size_t in_len, int8_t out[BLK])
 {
    if (in_len < 3) return 0;
    if (in[0] != HDR0 || in[1] != HDR1 || in[2] != VER) return 0;

    uint8_t *src = in + 3;
    uint8_t *end = in + in_len;

    int16_t low[HALFF], high[HALFF];
    for (int i = 0; i < HALFF; i++)
    {
        uint32_t z; src = varbyte_read_u32(src, end, &z);
        if (!src) return 0;
        low[i] = clamp_i16(zigzag_decode32(z));
    }
    for (int i = 0; i < HALFF; i++)
    {
        uint32_t z; src = varbyte_read_u32(src, end, &z);
        if (!src) return 0;
        high[i] = clamp_i16(zigzag_decode32(z));
    }

    SW_dwt53_inverse(low, high, out);
    return (size_t)(src - in);
}

 size_t HW_encode_block_53_varbyte(int8_t in[BLK], uint8_t *out, size_t out_cap)
 {
    if (out_cap < 3) return 0;
    uint8_t *dst = out;
    *dst++ = HDR0; *dst++ = HDR1; *dst++ = VER;

    int16_t low[HALFF], high[HALFF];
    Compute_FDWT_CDF_53(in, low, high);

    for (int i = 0; i < HALFF; i++)
    {
        uint32_t z = zigzag_encode32(low[i]);
        dst = varbyte_write_u32(dst, z);
    }
    for (int i = 0; i < HALFF; i++)
    {
        uint32_t z = zigzag_encode32(high[i]);
        dst = varbyte_write_u32(dst, z);
    }
    return (size_t)(dst - out);
}

 size_t HW_decode_block_53_varbyte(uint8_t *in, size_t in_len, int8_t out[BLK])
 {
    if (in_len < 3) return 0;
    if (in[0] != HDR0 || in[1] != HDR1 || in[2] != VER) return 0;

    uint8_t *src = in + 3;
    uint8_t *end = in + in_len;

    int16_t low[HALFF], high[HALFF];
    for (int i = 0; i < HALFF; i++)
    {
        uint32_t z; src = varbyte_read_u32(src, end, &z);
        if (!src) return 0;
        low[i] = clamp_i16(zigzag_decode32(z));
    }
    for (int i = 0; i < HALFF; i++)
    {
        uint32_t z; src = varbyte_read_u32(src, end, &z);
        if (!src) return 0;
        high[i] = clamp_i16(zigzag_decode32(z));
    }

    Compute_IDWT_CDF_53(low, high, out);
    return (size_t)(src - in);
}

size_t my_strlen (const char *str) 
{
    const char *p;

    if (str == NULL)
        return 0;

    p = str;
    while (*p != '\0')  
        p++; 

    return p - str;
}

void make_text_1024(uint8_t *buf)
{
    const char *para =
        "To be, or not to be, that is the question—Whether 'tis nobler in the mind to suffer "
        "The slings and arrows of outrageous fortune, Or to take arms against a sea of troubles "
        "And by opposing end them. To die—to sleep, No more; and by a sleep to say we end "
        "The heart-ache and the thousand natural shocks That flesh is heir to: 'tis a consummation "
        "Devoutly to be wish'd. To die, to sleep—To sleep—perchance to dream: ay, there's the rub: "
        "For in that sleep of death what dreams may come, When we have shuffled off this mortal coil, "
        "Must give us pause—there's the respect That makes calamity of so long life.";
    size_t L = my_strlen(para);
    for (int i = 0; i < NBYTES; i++) buf[i] = (uint8_t)para[i % L];
}