#ifndef COMPRESSION_H_
#define COMPRESSION_H_

#include <stdlib.h>
#include <stdint.h>
/* ---------------- Config ---------------- */
#define BLK      16
#define HALFF     (BLK/2)
#define NBYTES   1024          /* total input size (bytes) */
#define HDR0     'W'           /* per-block 3-byte header */
#define HDR1     '5'
#define VER      1

int8_t clamp_i8(int32_t x);
int16_t clamp_i16(int32_t x);

uint32_t zigzag_encode32(int32_t v);
int32_t zigzag_decode32(uint32_t u);

uint8_t* varbyte_write_u32(uint8_t *dst, uint32_t v);
uint8_t* varbyte_read_u32(uint8_t *src, uint8_t *end, uint32_t *out);

size_t SW_encode_block_53_varbyte(int8_t in[BLK], uint8_t *out, size_t out_cap);
size_t SW_decode_block_53_varbyte(uint8_t *in, size_t in_len, int8_t out[BLK]);

size_t HW_encode_block_53_varbyte(int8_t in[BLK], uint8_t *out, size_t out_cap);
size_t HW_decode_block_53_varbyte(uint8_t *in, size_t in_len, int8_t out[BLK]);

size_t my_strlen (const char *str);
void make_text_1024(uint8_t *buf);

#endif